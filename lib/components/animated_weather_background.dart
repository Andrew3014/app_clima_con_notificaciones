import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimatedWeatherBackground extends StatelessWidget {
  final String weatherMain;
  final int hour;
  final bool isDay;
  const AnimatedWeatherBackground({super.key, required this.weatherMain, required this.hour, this.isDay = true});

  String _getAnimationAsset() {
    final main = weatherMain.toLowerCase();
    // Mejorar robustez: considerar más descripciones y variantes
    if (main.contains('tormenta') || main.contains('thunderstorm')) {
      return 'assets/lottie/thunderstorm.json';
    } else if (main.contains('nieve') || main.contains('snow')) {
      return 'assets/lottie/snow.json';
    } else if (main.contains('lluvia') || main.contains('rain') || main.contains('drizzle')) {
      return 'assets/lottie/rain.json';
    } else if (main.contains('despejado') || main.contains('clear')) {
      return isDay ? 'assets/lottie/sunny.json' : 'assets/lottie/clear_night.json';
    } else if (main.contains('pocas nubes') || main.contains('few clouds')) {
      return isDay ? 'assets/lottie/sunny.json' : 'assets/lottie/clear_night.json';
    } else if (main.contains('nubes dispersas') || main.contains('scattered clouds')) {
      return isDay ? 'assets/lottie/cloudy_day.json' : 'assets/lottie/cloudy_night.json';
    } else if (main.contains('nubes') || main.contains('cloud')) {
      return isDay ? 'assets/lottie/cloudy_day.json' : 'assets/lottie/cloudy_night.json';
    } else {
      return 'assets/lottie/default_weather.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.7, // Aumenta la opacidad para que la animación sea más visible
        child: Align(
          alignment: Alignment.topCenter,
          child: FractionallySizedBox(
            widthFactor: 0.95,
            heightFactor: 0.65,
            child: Lottie.asset(
              _getAnimationAsset(),
              fit: BoxFit.contain,
              repeat: true,
            ),
          ),
        ),
      ),
    );
  }
}
