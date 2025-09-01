import 'package:flutter/material.dart';
import '../database/db.dart';
import '../services/weather_service.dart';
import '../components/weather_card.dart';

class FavoritesScreen extends StatefulWidget {
  final Function(String) onCitySelected;
  const FavoritesScreen({super.key, required this.onCitySelected});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<String> favorites = [];
  Map<String, dynamic>? weatherData;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    favorites = await DB.getFavorites();
    setState(() {});
  }

  Future<void> fetchWeather(String city) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    final weather = await WeatherService().fetchWeather(city);
    if (!mounted) return;
    if (weather != null) {
      setState(() {
        weatherData = {
          'name': weather.name,
          'main': {'temp': weather.temp, 'humidity': weather.humidity, 'pressure': weather.pressure},
          'weather': [{'main': weather.main, 'description': weather.description, 'icon': weather.icon}],
          'wind': {'speed': weather.windSpeed},
        };
        isLoading = false;
        errorMessage = null;
      });
    } else {
      setState(() {
        errorMessage = 'No existe esa ciudad. Por favor, verifica el nombre.';
        weatherData = null;
        isLoading = false;
      });
    }
  }

  Future<void> removeFavorite(String city) async {
    await DB.removeFavorite(city);
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
      ),
      body: Column(
        children: [
          if (favorites.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text('No tienes ciudades favoritas.'),
            ),
          if (favorites.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final city = favorites[index];
                  return ListTile(
                    title: Text(city),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await removeFavorite(city);
                      },
                    ),
                    onTap: () async {
                      await fetchWeather(city);
                      if (weatherData != null) {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) => Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                WeatherCard(
                                  city: weatherData!['name'],
                                  temp: weatherData!['main']['temp'],
                                  description: weatherData!['weather'][0]['description'],
                                  main: weatherData!['weather'][0]['main'],
                                  icon: weatherData!['weather'][0]['icon'],
                                  humidity: weatherData!['main']['humidity'],
                                  pressure: weatherData!['main']['pressure'],
                                  windSpeed: weatherData!['wind']['speed'],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: Text(
                                    // Se eliminó el uso de getRecommendation
                                    '',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.deepPurple),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                ElevatedButton(
                                  child: const Text('Ver en pantalla principal'),
                                  onPressed: () {
                                    widget.onCitySelected(city);
                                    Navigator.pop(context); // Solo cerrar el modal, no la pantalla de favoritos
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
