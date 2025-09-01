import 'package:flutter/material.dart';

LinearGradient getWeatherGradient(String weatherMain) {
  switch (weatherMain.toLowerCase()) {
    case 'clear':
      return const LinearGradient(colors: [Colors.orange, Colors.yellow]);
    case 'clouds':
      return const LinearGradient(colors: [Colors.blueGrey, Colors.lightBlueAccent]);
    case 'rain':
      return const LinearGradient(colors: [Colors.blue, Colors.grey]);
    case 'thunderstorm':
      return const LinearGradient(colors: [Colors.deepPurple, Colors.indigo]);
    case 'snow':
      return const LinearGradient(colors: [Colors.white, Colors.lightBlueAccent]);
    default:
      return const LinearGradient(colors: [Colors.blueGrey, Colors.white]);
  }
}

