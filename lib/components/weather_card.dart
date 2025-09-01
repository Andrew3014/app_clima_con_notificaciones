import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WeatherCard extends StatelessWidget {
  final String city;
  final double temp;
  final String description;
  final String main;
  final String icon;
  final int humidity;
  final int pressure;
  final double windSpeed;

  const WeatherCard({
    super.key,
    required this.city,
    required this.temp,
    required this.description,
    required this.main,
    required this.icon,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
  });

  @override
  Widget build(BuildContext context) {
    String lottieAsset = _getLottieAsset(main);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(city, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 100,
              child: Lottie.asset(lottieAsset, fit: BoxFit.contain),
            ),
            Text('$temp°C', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            Text(description, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(children: [const Icon(Icons.water_drop), Text('$humidity%')]),
                Column(children: [const Icon(Icons.air), Text('$windSpeed m/s')]),
                Column(children: [const Icon(Icons.speed), Text('$pressure hPa')]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getLottieAsset(String main) {
    switch (main.toLowerCase()) {
      case 'clear':
      case 'sunny':
        return 'assets/lottie/sunny.json';
      case 'clouds':
        return 'assets/lottie/cloudy_day.json';
      case 'rain':
      case 'drizzle':
        return 'assets/lottie/rain.json';
      case 'thunderstorm':
        return 'assets/lottie/thunderstorm.json';
      case 'snow':
        return 'assets/lottie/snow.json';
      case 'night':
      case 'clear_night':
        return 'assets/lottie/clear_night.json';
      default:
        return 'assets/lottie/default_weather.json';
    }
  }
}
