import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../utils/color_utils.dart';

class HourlyForecastCard extends StatelessWidget {
  final List<Map<String, dynamic>> hourlyData;
  final Color cardColor;
  final Color textColor;
  const HourlyForecastCard({super.key, required this.hourlyData, this.cardColor = Colors.white, this.textColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hourlyData.length,
        itemBuilder: (context, index) {
          final hour = hourlyData[index]['hour'] as String;
          double parseToDouble(dynamic value) {
            if (value == null) return 0.0;
            if (value is num) return value.toDouble();
            if (value is String) return double.tryParse(value) ?? 0.0;
            return 0.0;
          }
          final temp = parseToDouble(hourlyData[index]['temp']);
          final icon = hourlyData[index]['icon'] as String;
          final pop = hourlyData[index]['pop'] is String ? int.tryParse(hourlyData[index]['pop']) : hourlyData[index]['pop'] as int?;
          final desc = hourlyData[index]['desc'] as String?;
          final wind = hourlyData[index]['wind'] != null ? parseToDouble(hourlyData[index]['wind']) : null;
          final humidity = hourlyData[index]['humidity'] != null ? parseToDouble(hourlyData[index]['humidity']) : null;
          final feelsLike = hourlyData[index]['feels_like'] != null ? parseToDouble(hourlyData[index]['feels_like']) : null;
          final uvi = hourlyData[index]['uvi'] != null ? parseToDouble(hourlyData[index]['uvi']) : null;
          final visibility = hourlyData[index]['visibility'] != null ? parseToDouble(hourlyData[index]['visibility']) : null;
          return Container(
            width: 80,
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(hour, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
                  // Reemplazo el icono por la animación Lottie si existe
                  SizedBox(
                    height: 36,
                    width: 36,
                    child: Lottie.asset(
                      getLottieAssetForWeather(desc ?? icon, pop: pop, icon: icon),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Image.network('https://openweathermap.org/img/wn/$icon@2x.png', width: 36, height: 36),
                    ),
                  ),
                  if (desc != null)
                    Text(desc, style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 11), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                  Text('${temp.toStringAsFixed(0)}°', style: TextStyle(color: textColor, fontSize: 15)),
                  if (feelsLike != null)
                    Text('ST: ${feelsLike.toStringAsFixed(0)}°', style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 11)),
                  if (pop != null)
                    Text('$pop%', style: TextStyle(color: Colors.lightBlueAccent, fontSize: 12)),
                  if (wind != null)
                    Text('V: ${wind.toStringAsFixed(1)}m/s', style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 11)),
                  if (humidity != null)
                    Text('H: $humidity%', style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 11)),
                  if (uvi != null)
                    Text('UV: $uvi', style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 11)),
                  if (visibility != null)
                    Text('Vis: ${visibility ~/ 1000}km', style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 11)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Animación precisa según icono y probabilidad de lluvia para cada hora
  String getLottieAssetForWeather(String descOrIcon, {int? pop, String? icon}) {
    // Prioridad: icono > descripción
    if (icon != null && icon.isNotEmpty) {
      if (icon.startsWith('01')) return 'assets/lottie/sunny.json'; // Sol
      if (icon.startsWith('02') || icon.startsWith('03') || icon.startsWith('04')) {
        if ((pop ?? 0) > 40) return 'assets/lottie/rain.json'; // Lluvia si pop > 40
        if ((pop ?? 0) > 30) return 'assets/lottie/cloudy_day.json'; // Nublado si pop > 30
        return 'assets/lottie/cloudy_day.json'; // Nubes
      }
      if ((icon.startsWith('09') || icon.startsWith('10'))) {
        if ((pop ?? 0) > 40) return 'assets/lottie/rain.json'; // Lluvia si pop > 40
        if ((pop ?? 0) > 30) return 'assets/lottie/cloudy_day.json'; // Nublado si pop > 30
        return 'assets/lottie/cloudy_day.json';
      }
      if (icon.startsWith('11')) return 'assets/lottie/thunderstorm.json'; // Tormenta
      if (icon.startsWith('13')) return 'assets/lottie/snow.json'; // Nieve
    }
    final d = descOrIcon.toLowerCase();
    if (d.contains('claro') || d.contains('clear')) return 'assets/lottie/sunny.json';
    if (d.contains('nube') || d.contains('cloud')) {
      if ((pop ?? 0) > 40) return 'assets/lottie/rain.json';
      if ((pop ?? 0) > 30) return 'assets/lottie/cloudy_day.json';
      return 'assets/lottie/cloudy_day.json';
    }
    if ((d.contains('lluvia') || d.contains('rain') || d.contains('drizzle'))) {
      if ((pop ?? 0) > 40) return 'assets/lottie/rain.json';
      if ((pop ?? 0) > 30) return 'assets/lottie/cloudy_day.json';
      return 'assets/lottie/cloudy_day.json';
    }
    if (d.contains('tormenta') || d.contains('thunderstorm')) return 'assets/lottie/thunderstorm.json';
    if (d.contains('nieve') || d.contains('snow')) return 'assets/lottie/snow.json';
    return 'assets/lottie/default_weather.json';
  }
}
