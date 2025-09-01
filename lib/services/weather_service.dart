import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherService {
  static const String apiKey = '4554d700ead9e817391a18a3c7d75a5d';

  Future<WeatherData?> fetchWeather(String city) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=es';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  Future<List<String>> fetchCitySuggestions(String query) async {
    final url =
        'https://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$apiKey&lang=es';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map<String>((item) {
        final name = item['name'] ?? '';
        final country = item['country'] ?? '';
        final state = item['state'] != null ? ', ${item['state']}' : '';
        return '$name$state, $country';
      }).toList();
    } else {
      return [];
    }
  }

  Future<String?> getCityFromCoords(double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/geo/1.0/reverse?lat=$lat&lon=$lon&limit=1&appid=$apiKey&lang=es';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      if (data.isNotEmpty && data[0]['name'] != null) {
        return data[0]['name'];
      }
    }
    return null;
  }

  Future<WeatherData?> fetchWeatherByCoords(double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=es';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchForecastByCoords(double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=es';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchForecast(String city) async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric&lang=es';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }
}
