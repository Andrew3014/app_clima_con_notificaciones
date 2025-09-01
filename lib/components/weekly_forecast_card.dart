import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../utils/color_utils.dart';

class WeeklyForecastCard extends StatelessWidget {
  final List<Map<String, dynamic>> dailyData;
  final Color textColor;
  final Color cardColor;
  final bool isDayTime;
  final int currentHour;
  const WeeklyForecastCard({super.key, required this.dailyData, this.textColor = Colors.white, this.cardColor = Colors.white, this.isDayTime = true, this.currentHour = 12});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pronóstico semanal', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            ...dailyData.map((day) {
              double parseToDouble(dynamic value) {
                if (value == null) return 0.0;
                if (value is num) return value.toDouble();
                if (value is String) return double.tryParse(value) ?? 0.0;
                return 0.0;
              }
              final min = parseToDouble(day['min']);
              final max = parseToDouble(day['max']);
              final wind = day['wind'] != null ? parseToDouble(day['wind']) : null;
              final humidity = day['humidity'] != null ? parseToDouble(day['humidity']) : null;
              final feelsLike = day['feels_like'] != null ? parseToDouble(day['feels_like']) : null;
              final uvi = day['uvi'] != null ? parseToDouble(day['uvi']) : null;
              final pop = day['pop'] is String ? double.tryParse(day['pop']) : (day['pop'] != null ? (day['pop'] as num).toDouble() : null);
              return InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(day['day'], style: TextStyle(fontSize: 32, color: textColor, fontWeight: FontWeight.bold)),
                              SizedBox(
                                height: 100,
                                child: Lottie.asset(
                                  getLottieAssetForWeather(day['desc'] ?? day['icon'], pop: pop?.toInt(), icon: day['icon']),
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => Image.network('https://openweathermap.org/img/wn/${day['icon']}@4x.png', width: 100, height: 100),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(day['desc'] ?? '', style: TextStyle(fontSize: 20, color: textColor)),
                              const SizedBox(height: 8),
                              Text('${min.toStringAsFixed(0)}° / ${max.toStringAsFixed(0)}°', style: TextStyle(fontSize: 24, color: textColor)),
                              if (wind != null)
                                Text('Viento: ${wind.toStringAsFixed(1)} m/s', style: TextStyle(color: textColor)),
                              if (humidity != null)
                                Text('Humedad: ${humidity.toStringAsFixed(0)}%', style: TextStyle(color: textColor)),
                              if (uvi != null)
                                Text('UV: ${uvi.toStringAsFixed(1)}', style: TextStyle(color: textColor)),
                              if (pop != null)
                                Text('Prob. precipitación: ${pop.toStringAsFixed(0)}%', style: TextStyle(color: textColor)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: Text(day['day'], style: TextStyle(color: textColor, fontWeight: FontWeight.w600))),
                    SizedBox(
                      height: 32,
                      width: 32,
                      child: Lottie.asset(
                        getLottieAssetForWeather(day['desc'] ?? day['icon'], pop: pop?.toInt(), icon: day['icon']),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Image.network('https://openweathermap.org/img/wn/${day['icon']}@2x.png', width: 32, height: 32),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (day['desc'] != null)
                      Expanded(child: Text(day['desc'], style: TextStyle(color: Color.fromRGBO(textColor.red, textColor.green, textColor.blue, 0.8), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Text('${min.toStringAsFixed(0)}° / ${max.toStringAsFixed(0)}°', style: TextStyle(color: textColor)),
                    if (feelsLike != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text('ST: ${feelsLike.toStringAsFixed(0)}°', style: TextStyle(color: Color.fromRGBO(textColor.red, textColor.green, textColor.blue, 0.7), fontSize: 12)),
                      ),
                    if (wind != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text('V: ${wind.toStringAsFixed(1)}m/s', style: TextStyle(color: Color.fromRGBO(textColor.red, textColor.green, textColor.blue, 0.7), fontSize: 12)),
                      ),
                    if (humidity != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text('H: ${humidity.toStringAsFixed(0)}%', style: TextStyle(color: Color.fromRGBO(textColor.red, textColor.green, textColor.blue, 0.7), fontSize: 12)),
                      ),
                    if (uvi != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text('UV: ${uvi.toStringAsFixed(1)}', style: TextStyle(color: Color.fromRGBO(textColor.red, textColor.green, textColor.blue, 0.7), fontSize: 12)),
                      ),
                    if (pop != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text('PP: ${pop.toStringAsFixed(0)}%', style: TextStyle(color: Color.fromRGBO(textColor.red, textColor.green, textColor.blue, 0.7), fontSize: 12)),
                      ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Determina si es de día para ese día (puedes mejorar esto si tienes sunrise/sunset por día)
  bool _isDayForDay(Map<String, dynamic> day) {
    // Si tienes la fecha, puedes comparar con la hora actual
    if (day['dt'] != null && day['dt'] is DateTime) {
      final hour = (day['dt'] as DateTime).hour;
      return hour >= 6 && hour < 18;
    }
    return isDayTime;
  }

  // Animación precisa según icono y probabilidad de lluvia
  String getLottieAssetForWeather(String descOrIcon, {int? pop, String? icon}) {
    // Prioridad: icono > descripción
    if (icon != null && icon.isNotEmpty) {
      if (icon.startsWith('01')) return 'assets/lottie/sunny.json'; // Sol
      if (icon.startsWith('02') || icon.startsWith('03') || icon.startsWith('04')) return 'assets/lottie/cloudy_day.json'; // Nubes
      if ((icon.startsWith('09') || icon.startsWith('10')) && (pop ?? 0) >= 30) return 'assets/lottie/rain.json'; // Lluvia solo si pop >= 30
      if (icon.startsWith('11')) return 'assets/lottie/thunderstorm.json'; // Tormenta
      if (icon.startsWith('13')) return 'assets/lottie/snow.json'; // Nieve
      // Si es icono de lluvia pero pop < 30, mostrar nubes
      if ((icon.startsWith('09') || icon.startsWith('10')) && (pop ?? 0) < 30) return 'assets/lottie/cloudy_day.json';
    }
    final d = descOrIcon.toLowerCase();
    if (d.contains('claro') || d.contains('clear')) return 'assets/lottie/sunny.json';
    if (d.contains('nube') || d.contains('cloud')) return 'assets/lottie/cloudy_day.json';
    if ((d.contains('lluvia') || d.contains('rain') || d.contains('drizzle')) && (pop ?? 0) >= 30) return 'assets/lottie/rain.json';
    if ((d.contains('lluvia') || d.contains('rain') || d.contains('drizzle')) && (pop ?? 0) < 30) return 'assets/lottie/cloudy_day.json';
    if (d.contains('tormenta') || d.contains('thunderstorm')) return 'assets/lottie/thunderstorm.json';
    if (d.contains('nieve') || d.contains('snow')) return 'assets/lottie/snow.json';
    return 'assets/lottie/default_weather.json';
  }
}
