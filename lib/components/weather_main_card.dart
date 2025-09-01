import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WeatherMainCard extends StatelessWidget {
  final String city;
  final String description;
  final double temp;
  final String icon;
  final Color textColor;
  final Color cardColor;
  final double? feelsLike;
  final int? humidity;
  final int? pressure;
  final double? windSpeed;
  final int? visibility;
  final double? uv;
  final String? sunrise;
  final String? sunset;
  final String weatherMain; // Nuevo: tipo de clima para animación
  const WeatherMainCard({
    super.key,
    required this.city,
    required this.description,
    required this.temp,
    required this.icon,
    this.textColor = Colors.white,
    this.cardColor = Colors.white,
    this.feelsLike,
    this.humidity,
    this.pressure,
    this.windSpeed,
    this.visibility,
    this.uv,
    this.sunrise,
    this.sunset,
    required this.weatherMain, // Nuevo
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(city, style: TextStyle(fontSize: 32, color: textColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          // Animación Lottie del clima
          SizedBox(
            height: 90,
            child: Lottie.asset(_getLottieAsset(weatherMain)),
          ),
          const SizedBox(height: 8),
          Text('${temp.toStringAsFixed(0)}°', style: TextStyle(fontSize: 64, color: textColor, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(description, style: TextStyle(fontSize: 20, color: textColor.withOpacity(0.85))),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 4,
            children: [
              if (feelsLike != null)
                _InfoItem(icon: Icons.thermostat_auto, label: 'Sensación', value: '${feelsLike!.toStringAsFixed(0)}°'),
              if (humidity != null)
                _InfoItem(icon: Icons.water_drop, label: 'Humedad', value: '$humidity%'),
              if (pressure != null)
                _InfoItem(icon: Icons.speed, label: 'Presión', value: '$pressure hPa'),
              if (windSpeed != null)
                _InfoItem(icon: Icons.air, label: 'Viento', value: '${windSpeed!.toStringAsFixed(1)} m/s'),
              if (visibility != null)
                _InfoItem(icon: Icons.remove_red_eye, label: 'Visibilidad', value: '${(visibility!/1000).toStringAsFixed(1)} km'),
              if (uv != null)
                _InfoItem(icon: Icons.wb_sunny, label: 'UV', value: uv!.toStringAsFixed(1)),
              if (sunrise != null)
                _InfoItem(icon: Icons.wb_twighlight, label: 'Amanecer', value: sunrise!),
              if (sunset != null)
                _InfoItem(icon: Icons.nights_stay, label: 'Atardecer', value: sunset!),
            ],
          ),
        ],
      ),
    );
  }

  String _getLottieAsset(String main) {
    final m = main.toLowerCase();
    if (m.contains('clear')) return 'assets/lottie/sunny.json';
    if (m.contains('cloud')) return 'assets/lottie/cloudy_day.json';
    if (m.contains('rain') || m.contains('drizzle')) return 'assets/lottie/rain.json';
    if (m.contains('thunderstorm')) return 'assets/lottie/thunderstorm.json';
    if (m.contains('snow')) return 'assets/lottie/snow.json';
    return 'assets/lottie/default_weather.json';
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoItem({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 4),
        Text('$label: ', style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}
