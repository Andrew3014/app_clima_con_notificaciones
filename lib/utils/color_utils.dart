import 'package:flutter/material.dart';

Color getTextColorForWeather(String weatherMain, int hour) {
  // Noche: texto claro, Día: texto oscuro si fondo es claro
  bool isNight = hour < 6 || hour > 19;
  if (weatherMain.toLowerCase().contains('clear')) {
    return isNight ? Colors.white : Colors.black87;
  } else if (weatherMain.toLowerCase().contains('cloud')) {
    return isNight ? Colors.white : Colors.black87;
  } else if (weatherMain.toLowerCase().contains('rain') || weatherMain.toLowerCase().contains('drizzle')) {
    return Colors.white;
  } else if (weatherMain.toLowerCase().contains('thunderstorm')) {
    return Colors.white;
  } else if (weatherMain.toLowerCase().contains('snow')) {
    return Colors.black87;
  } else {
    return isNight ? Colors.white : Colors.black87;
  }
}

String getLottieAssetForWeather(String main) {
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
