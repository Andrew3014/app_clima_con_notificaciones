import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clima',
      theme: ThemeData(
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? weatherData;
  Map<String, dynamic>? forecastData;
  bool isLoading = false;
  String? errorMessage;

  // API KEY de OpenWeatherMap proporcionada por el usuario
  final String apiKey = '4554d700ead9e817391a18a3c7d75a5d';

  Future<void> fetchWeather(String city) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final weatherUrl = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=es');
      final forecastUrl = Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric&lang=es');
      final weatherResponse = await http.get(weatherUrl);
      final forecastResponse = await http.get(forecastUrl);
      if (weatherResponse.statusCode == 200 && forecastResponse.statusCode == 200) {
        final weather = json.decode(weatherResponse.body);
        final forecast = json.decode(forecastResponse.body);
        // Verificar si la ciudad existe realmente y tiene datos válidos en ambos endpoints
        final weatherCod = weather['cod']?.toString();
        final forecastCod = forecast['cod']?.toString();
        if (weather == null || weather['main'] == null || weather['weather'] == null || weatherCod != '200' || forecastCod != '200') {
          setState(() {
            errorMessage = 'No existe esa ciudad. Por favor, verifica el nombre.';
            weatherData = null;
            forecastData = null;
            isLoading = false;
          });
        } else {
          setState(() {
            weatherData = weather;
            forecastData = forecast;
            isLoading = false;
          });
        }
      } else if (weatherResponse.statusCode == 404 || forecastResponse.statusCode == 404) {
        setState(() {
          errorMessage = 'No existe esa ciudad. Por favor, verifica el nombre.';
          weatherData = null;
          forecastData = null;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error al obtener datos del clima.';
          weatherData = null;
          forecastData = null;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error de conexión.';
        weatherData = null;
        forecastData = null;
        isLoading = false;
      });
    }
  }

  Future<List<String>> fetchCitySuggestions(String query) async {
    if (query.isEmpty) return [];
    final url = Uri.parse(
        'https://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$apiKey');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
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

  List<Color> getGradientColors() {
    if (weatherData == null) {
      // Degradado por defecto
      return [Colors.blue.shade200, Colors.blue.shade800];
    }
    final weatherMain = weatherData!['weather'][0]['main'].toString().toLowerCase();
    final now = DateTime.now();
    final hour = now.hour;
    bool isNight = hour < 6 || hour > 19;
    if (weatherMain.contains('clear')) {
      return isNight
          ? [Colors.indigo.shade900, Colors.black87]
          : [Colors.yellow.shade200, Colors.orange.shade400];
    } else if (weatherMain.contains('cloud')) {
      return isNight
          ? [Colors.blueGrey.shade700, Colors.black54]
          : [Colors.blueGrey.shade200, Colors.blueGrey.shade600];
    } else if (weatherMain.contains('rain') || weatherMain.contains('drizzle')) {
      return isNight
          ? [Colors.blueGrey.shade800, Colors.indigo.shade900]
          : [Colors.blue.shade300, Colors.blueGrey.shade500];
    } else if (weatherMain.contains('thunderstorm')) {
      return [Colors.deepPurple.shade700, Colors.black];
    } else if (weatherMain.contains('snow')) {
      return [Colors.blue.shade100, Colors.white];
    } else {
      return [Colors.grey.shade400, Colors.grey.shade700];
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = getGradientColors();
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'App del Clima',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(blurRadius: 8, color: Colors.black26, offset: Offset(2, 2)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  TypeAheadField<String>(
                    suggestionsCallback: fetchCitySuggestions,
                    itemBuilder: (context, String suggestion) {
                      return ListTile(
                        title: Text(suggestion),
                      );
                    },
                    onSelected: (String suggestion) {
                      _controller.text = suggestion;
                      fetchWeather(suggestion.split(',')[0]);
                    },
                    builder: (context, controller, focusNode) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: 'Ingresa una ciudad',
                          filled: true,
                          fillColor: Color.fromARGB(204, 255, 255, 255), // 0.8*255=204
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.location_city),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    onPressed: () {
                      if (_controller.text.trim().isNotEmpty) {
                        fetchWeather(_controller.text.trim());
                      }
                    },
                    child: const Text('Buscar clima', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 32),
                  if (isLoading)
                    const SpinKitFadingCircle(
                      color: Colors.white,
                      size: 60.0,
                    ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (weatherData != null && !isLoading && errorMessage == null)
                    Column(
                      children: [
                        WeatherInfo(weatherData: weatherData!),
                        if (forecastData != null)
                          ForecastInfo(forecastData: forecastData!),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WeatherInfo extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  const WeatherInfo({super.key, required this.weatherData});

  @override
  Widget build(BuildContext context) {
    final temp = weatherData['main']['temp'].toDouble();
    final desc = weatherData['weather'][0]['description'];
    final icon = weatherData['weather'][0]['icon'];
    final city = weatherData['name'];
    final country = weatherData['sys']['country'];
    final dt = DateTime.fromMillisecondsSinceEpoch(weatherData['dt'] * 1000, isUtc: true).toLocal();
    final formatter = DateFormat('HH:mm, dd MMM yyyy', 'es');
    return Card(
      color: Color.fromARGB(217, 255, 255, 255), // 0.85*255=217
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$city, $country', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(formatter.format(dt), style: const TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 16),
            Image.network('https://openweathermap.org/img/wn/$icon@4x.png', width: 100, height: 100),
            const SizedBox(height: 8),
            Text('${temp.toStringAsFixed(1)}°C', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(desc.toString().toUpperCase(), style: const TextStyle(fontSize: 20, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}

class ForecastInfo extends StatelessWidget {
  final Map<String, dynamic> forecastData;
  const ForecastInfo({super.key, required this.forecastData});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> hourlyForecast = forecastData['list'];
    return Card(
      color: Color.fromARGB(217, 255, 255, 255), // 0.85*255=217
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pronóstico por horas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: hourlyForecast.length,
                itemBuilder: (context, index) {
                  final hourData = hourlyForecast[index];
                  final hour = DateTime.fromMillisecondsSinceEpoch(hourData['dt'] * 1000, isUtc: true).toLocal();
                  final temp = hourData['main']['temp'].toDouble();
                  final icon = hourData['weather'][0]['icon'];
                  return Container(
                    width: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat.Hm('es').format(hour),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Image.network('https://openweathermap.org/img/wn/$icon@2x.png', width: 40, height: 40),
                        const SizedBox(height: 8),
                        Text('${temp.toStringAsFixed(1)}°C', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
