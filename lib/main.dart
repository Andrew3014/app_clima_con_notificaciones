import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:geolocator/geolocator.dart';
import 'components/weather_main_card.dart';
import 'components/hourly_forecast_card.dart';
import 'components/weather_details_panel.dart';
import 'components/recommendations_panel.dart';
import 'components/animated_weather_background.dart';
import 'components/weekly_forecast_card.dart';
import 'services/weather_service.dart';
import 'database/db.dart';
import 'screens/favorites_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'utils/color_utils.dart';
import 'models/weather.dart';
import 'dart:async';

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
        fontFamily: GoogleFonts.inter().fontFamily,
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
  final WeatherService _weatherService = WeatherService();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  Map<String, dynamic>? weatherData;
  Map<String, dynamic>? forecastData;
  bool isLoading = false;
  String? errorMessage;
  List<String> favorites = [];
  String? currentCity;
  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _initNotifications();
    _getLocationAndWeather();
    _startPeriodicNotifications();
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    favorites = await DB.getFavorites();
    setState(() {});
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showWeatherAlert(String city, String main) async {
    if (main.toLowerCase().contains('thunderstorm') || main.toLowerCase().contains('rain')) {
      await flutterLocalNotificationsPlugin.show(
        0,
        'Alerta meteorológica',
        '¡Atención! Se detectó $main en $city.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'weather_alerts',
            'Alertas meteorológicas',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  }

  Future<void> _getLocationAndWeather() async {
    setState(() { isLoading = true; });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() { errorMessage = 'La ubicación está desactivada.'; isLoading = false; });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() { errorMessage = 'Permiso de ubicación denegado.'; isLoading = false; });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() { errorMessage = 'Permiso de ubicación denegado permanentemente.'; isLoading = false; });
        return;
      }
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final city = await _weatherService.getCityFromCoords(position.latitude, position.longitude);
      if (city != null) {
        currentCity = city;
        await fetchWeather(city, byCoords: true, lat: position.latitude, lon: position.longitude);
      } else {
        setState(() { errorMessage = 'No se pudo determinar la ciudad.'; isLoading = false; });
      }
    } catch (e) {
      setState(() { errorMessage = 'Error obteniendo ubicación.'; isLoading = false; });
    }
  }

  Future<void> fetchWeather(String city, {bool byCoords = false, double? lat, double? lon}) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    final weather = byCoords && lat != null && lon != null
        ? await _weatherService.fetchWeatherByCoords(lat, lon)
        : await _weatherService.fetchWeather(city);
    final forecast = byCoords && lat != null && lon != null
        ? await _weatherService.fetchForecastByCoords(lat, lon)
        : await _weatherService.fetchForecast(city);
    if (!mounted) return;
    if (weather != null && forecast != null) {
      setState(() {
        // Si weather ya es un Map, úsalo directamente. Si es WeatherData, conviértelo a Map.
        Map<String, dynamic> weatherMap = weather is Map<String, dynamic>
            ? weather as Map<String, dynamic>
            : (weather is WeatherData
                ? {
                    'name': weather.name,
                    'main': {
                      'temp': weather.temp,
                      'humidity': weather.humidity,
                      'pressure': weather.pressure,
                    },
                    'weather': [
                      {
                        'main': weather.main,
                        'description': weather.description,
                        'icon': weather.icon,
                      }
                    ],
                    'wind': {'speed': weather.windSpeed},
                  }
                : {});
        weatherData = weatherMap;
        forecastData = forecast;
        isLoading = false;
        errorMessage = null;
      });
    } else {
      setState(() {
        errorMessage = 'No existe esa ciudad o no se pudo obtener el clima.';
        weatherData = null;
        forecastData = null;
        isLoading = false;
      });
    }
  }

  Future<List<String>> fetchCitySuggestions(String query) async {
    return await _weatherService.fetchCitySuggestions(query);
  }

  void _showSearchModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        String? selectedCity;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TypeAheadField<String>(
                      suggestionsCallback: fetchCitySuggestions,
                      itemBuilder: (context, String suggestion) {
                        return ListTile(title: Text(suggestion));
                      },
                      onSelected: (String suggestion) {
                        setModalState(() {
                          selectedCity = suggestion.split(',')[0];
                        });
                        _controller.text = suggestion;
                        fetchWeather(selectedCity!);
                      },
                      builder: (context, controller, focusNode) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: 'Ingresa una ciudad',
                            filled: true,
                            fillColor: const Color.fromARGB(204, 255, 255, 255),
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
                          setModalState(() {
                            selectedCity = _controller.text.trim().split(',')[0];
                          });
                          fetchWeather(selectedCity!);
                        }
                      },
                      child: const Text('Buscar clima', style: TextStyle(fontSize: 18)),
                    ),
                    if (selectedCity != null && !favorites.contains(selectedCity))
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.star),
                          label: const Text('Agregar a favoritos'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () async {
                            await addFavorite(selectedCity!);
                            setModalState(() {});
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Color> getGradientColors() {
    if (weatherData == null) {
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

  Future<void> addFavorite(String city) async {
    await DB.addFavorite(city);
    await _loadFavorites();
  }

  Future<void> removeFavorite(String city) async {
    await DB.removeFavorite(city);
    await _loadFavorites();
  }

  Color _getBackgroundColor(int hour) {
    // Fondo oscuro para noche, celeste para día
    if (hour >= 6 && hour < 18) {
      return const Color(0xFFB3E5FC); // Celeste día
    } else {
      return const Color(0xFF263238); // Azul oscuro noche
    }
  }

  void _startPeriodicNotifications() {
    _notificationTimer?.cancel();
    _notificationTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await _showWeatherAndRecommendationsNotification();
    });
  }

  Future<void> _showWeatherAndRecommendationsNotification() async {
    if (weatherData == null || forecastData == null) return;
    final city = weatherData!["name"] ?? "-";
    final temp = weatherData!["main"]["temp"]?.toStringAsFixed(0) ?? "-";
    final desc = weatherData!["weather"][0]["description"] ?? "-";
    String recommendations = _getRecommendationsForCurrentHour();
    String message = 'Temp: $temp°C, $desc.';
    if (recommendations.isNotEmpty) {
      message += '\nRecomendación: $recommendations';
    } else {
      message += '\nRecomendación: Lleva ropa adecuada y revisa el pronóstico.';
    }
    await flutterLocalNotificationsPlugin.show(
      1,
      'Clima actual en $city',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weather_hourly',
          'Clima y recomendaciones por hora',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  String _getRecommendationsForCurrentHour() {
    if (forecastData == null || forecastData!["hourly"] == null) return "Lleva ropa adecuada y revisa el pronóstico.";
    final now = DateTime.now();
    final hour = now.hour;
    final hourly = List<Map<String, dynamic>>.from(forecastData!["hourly"]);
    final current = hourly.firstWhere(
      (h) => DateTime.fromMillisecondsSinceEpoch(h["dt"] * 1000).hour == hour,
      orElse: () => {},
    );
    if (current.isEmpty) return "Lleva ropa adecuada y revisa el pronóstico.";
    final desc = current["desc"] ?? current["weather"]?[0]?["description"] ?? "";
    if (desc.toString().contains("lluvia")) {
      return "Lleva paraguas y protégete de la lluvia.";
    } else if (desc.toString().contains("nieve")) {
      return "Precaución por nieve. Usa ropa abrigada y calzado adecuado.";
    } else if (desc.toString().contains("despejado")) {
      return "Buen día para actividades al aire libre. Usa protector solar.";
    } else if (desc.toString().contains("nubes")) {
      return "Cielo parcialmente nublado. Lleva una chaqueta ligera.";
    } else if (desc.toString().contains("tormenta")) {
      return "Evita salir si no es necesario. Precaución por tormentas.";
    }
    return "Lleva ropa adecuada y revisa el pronóstico.";
  }

  // Getter para el estado principal del clima
  String get weatherMain => weatherData != null && weatherData!["weather"] != null && weatherData!["weather"].isNotEmpty
      ? weatherData!["weather"][0]["main"] ?? ''
      : '';

  // Getter para la hora actual
  int get currentHour => DateTime.now().hour;

  // Determina si es de día usando sunrise y sunset de la API
  bool get isDayTime {
    if (forecastData != null && forecastData!["city"] != null) {
      final sunrise = forecastData!["city"]["sunrise"];
      final sunset = forecastData!["city"]["sunset"];
      final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
      if (sunrise != null && sunset != null) {
        return now >= sunrise && now < sunset;
      }
    }
    // Fallback: usar hora local
    final hour = DateTime.now().hour;
    return hour >= 6 && hour < 18;
  }

  // Modifica el color de fondo según isDayTime
  Color get backgroundColor {
    return isDayTime ? const Color(0xFFE3F2FD) : const Color(0xFF263238);
  }

  // Modifica el color de los recuadros según isDayTime
  Color get cardColor {
    return isDayTime ? Colors.white.withOpacity(0.92) : Colors.grey[900]!.withOpacity(0.92);
  }

  // Modifica el color del texto según isDayTime
  Color get textColor {
    return isDayTime ? Colors.black87 : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.25),
        elevation: 0,
        leading: (weatherData != null && weatherData!["name"] != null && !favorites.contains(weatherData!["name"]))
            ? IconButton(
                icon: const Icon(Icons.star_border, color: Colors.amber),
                tooltip: 'Agregar a favoritos',
                onPressed: () async {
                  await addFavorite(weatherData!["name"]);
                  setState(() {});
                },
              )
            : null,
        title: const Text('Clima', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _showSearchModal,
            tooltip: 'Buscar ciudad',
          ),
          IconButton(
            icon: const Icon(Icons.star, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FavoritesScreen(
                    onCitySelected: (city) {
                      fetchWeather(city);
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
            tooltip: 'Favoritos',
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedWeatherBackground(
            weatherMain: weatherMain,
            hour: currentHour,
            isDay: isDayTime,
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 80.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 18)),
                    ),
                  if (weatherData != null && errorMessage == null)
                    Column(
                      children: [
                        WeatherMainCard(
                          city: weatherData!["name"] ?? "-",
                          description: weatherData!["weather"][0]["description"] ?? "-",
                          temp: (weatherData!["main"]["temp"] is int)
                              ? (weatherData!["main"]["temp"] as int).toDouble()
                              : (weatherData!["main"]["temp"]?.toDouble() ?? 0.0),
                          icon: weatherData!["weather"][0]["icon"] ?? "01d",
                          textColor: textColor,
                          cardColor: cardColor.withOpacity(0.85),
                          feelsLike: (weatherData!["main"]["feels_like"] is int)
                              ? (weatherData!["main"]["feels_like"] as int).toDouble()
                              : (weatherData!["main"]["feels_like"]?.toDouble()),
                          humidity: weatherData!["main"]["humidity"],
                          pressure: weatherData!["main"]["pressure"],
                          windSpeed: (weatherData!["wind"] != null && weatherData!["wind"]["speed"] != null)
                              ? (weatherData!["wind"]["speed"] is int
                                  ? (weatherData!["wind"]["speed"] as int).toDouble()
                                  : (weatherData!["wind"]["speed"]?.toDouble() ?? 0.0))
                              : null,
                          visibility: weatherData!["visibility"],
                          uv: (forecastData != null && forecastData!["current"] != null && forecastData!["current"]["uvi"] != null)
                              ? (forecastData!["current"]["uvi"] is int
                                  ? (forecastData!["current"]["uvi"] as int).toDouble()
                                  : (forecastData!["current"]["uvi"]?.toDouble()))
                              : null,
                          sunrise: forecastData != null && forecastData!["city"] != null && forecastData!["city"]["sunrise"] != null ? _formatUnixTime(forecastData!["city"]["sunrise"]) : null,
                          sunset: forecastData != null && forecastData!["city"] != null && forecastData!["city"]["sunset"] != null ? _formatUnixTime(forecastData!["city"]["sunset"]) : null,
                          weatherMain: weatherData!["weather"][0]["main"] ?? '',
                        ),
                        if (forecastData != null && (forecastData!["hourly"] != null || forecastData!["list"] != null))
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: HourlyForecastCard(
                              hourlyData: forecastData!["hourly"] != null
                                  ? List<Map<String, dynamic>>.from(forecastData!["hourly"])
                                  : _extractHourlyFromList(forecastData!["list"]),
                              cardColor: cardColor,
                              textColor: textColor,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: WeatherDetailsPanel(details: _buildWeatherDetails(), cardColor: cardColor, textColor: textColor),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: RecommendationsPanel(
                            weatherMain: weatherMain,
                            hourlyData: forecastData != null && forecastData!["hourly"] != null
                                ? List<Map<String, dynamic>>.from(forecastData!["hourly"])
                                : null,
                            textColor: textColor,
                            cardColor: cardColor,
                          ),
                        ),
                        if (forecastData != null && forecastData!["list"] != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: WeeklyForecastCard(
                              dailyData: _extractDailyForecast(forecastData!["list"]),
                              textColor: textColor,
                              cardColor: cardColor,
                              isDayTime: isDayTime,
                              currentHour: currentHour,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _buildWeatherDetails() {
    if (weatherData == null) return {};
    final details = <String, String>{};
    // Ubicación y coordenadas
    details['Ubicación'] = weatherData!['name'] ?? '-';
    if (weatherData!['coord'] != null) {
      details['Coordenadas'] = '${weatherData!['coord']['lat']}, ${weatherData!['coord']['lon']}';
    }
    // Temperatura y sensación térmica
    details['Temperatura'] = weatherData!['main']['temp'] != null ? '${weatherData!['main']['temp']}°C' : '';
    if (weatherData!['main']['feels_like'] != null) {
      details['Sensación térmica'] = '${weatherData!['main']['feels_like']}°C';
    }
    // Humedad, presión, visibilidad, punto de rocío
    details['Humedad'] = weatherData!['main']['humidity'] != null ? '${weatherData!['main']['humidity']}%' : '';
    details['Presión'] = weatherData!['main']['pressure'] != null ? '${weatherData!['main']['pressure']} hPa' : '';
    if (weatherData!['visibility'] != null) {
      details['Visibilidad'] = '${(weatherData!['visibility'] / 1000).toStringAsFixed(1)} km';
    }
    if (weatherData!['main']['dew_point'] != null) {
      details['Punto de rocío'] = '${weatherData!['main']['dew_point']}°C';
    }
    // Viento
    if (weatherData!['wind'] != null) {
      details['Viento'] = weatherData!['wind']['speed'] != null ? '${weatherData!['wind']['speed']} m/s' : '';
      if (weatherData!['wind']['deg'] != null) {
        details['Dirección viento'] = _degToCompass(weatherData!['wind']['deg']);
      }
      if (weatherData!['wind']['gust'] != null) {
        details['Ráfagas'] = '${weatherData!['wind']['gust']} m/s';
      }
    }
    // UV, amanecer, atardecer, fase lunar, alertas (si forecastData disponible)
    if (forecastData != null && forecastData!['city'] != null) {
      if (forecastData!['city']['sunrise'] != null) {
        details['Amanecer'] = _formatUnixTime(forecastData!['city']['sunrise']);
      }
      if (forecastData!['city']['sunset'] != null) {
        details['Atardecer'] = _formatUnixTime(forecastData!['city']['sunset']);
      }
    }
    // UV y fase lunar no están en la API básica, pero puedes agregarlos si tienes datos
    // Alertas meteorológicas (si existen)
    if (forecastData != null && forecastData!['alerts'] != null && forecastData!['alerts'].isNotEmpty) {
      details['Alerta'] = forecastData!['alerts'][0]['event'] ?? 'Alerta meteorológica';
    }
    return details;
  }

  String _degToCompass(num deg) {
    const directions = [
      'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW', 'N'
    ];
    return directions[((deg % 360) / 22.5).round()];
  }

  String _formatUnixTime(int unix) {
    final dt = DateTime.fromMillisecondsSinceEpoch(unix * 1000);
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // Extrae las próximas 8 horas del forecastData["list"]
  List<Map<String, dynamic>> _extractHourlyFromList(List<dynamic> list) {
    final now = DateTime.now();
    final List<Map<String, dynamic>> result = [];
    for (var entry in list) {
      final dt = DateTime.fromMillisecondsSinceEpoch(entry['dt'] * 1000);
      if (dt.isAfter(now) && result.length < 8) {
        result.add({
          'hour': '${dt.hour.toString().padLeft(2, '0')}:00',
          'temp': entry['main']['temp'],
          'icon': entry['weather'][0]['icon'],
          'pop': ((entry['pop'] ?? 0) * 100).round(),
          'desc': entry['weather'][0]['description'],
          'wind': entry['wind']?['speed'],
          'humidity': entry['main']['humidity'],
        });
      }
      if (result.length >= 8) break;
    }
    return result;
  }

  // Extrae el pronóstico diario con descripción, viento y humedad promedio
  List<Map<String, dynamic>> _extractDailyForecast(List<dynamic> forecastList) {
    final Map<String, List<Map<String, dynamic>>> days = {};
    for (var entry in forecastList) {
      final dt = DateTime.fromMillisecondsSinceEpoch(entry['dt'] * 1000);
      final day = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      days.putIfAbsent(day, () => []);
      days[day]!.add({
        'min': entry['main']['temp_min'],
        'max': entry['main']['temp_max'],
        'icon': entry['weather'][0]['icon'],
        'desc': entry['weather'][0]['description'],
        'wind': entry['wind']?['speed'],
        'humidity': entry['main']['humidity'],
        'dt': dt,
      });
    }
    final List<Map<String, dynamic>> result = [];
    days.forEach((day, entries) {
      final min = entries.map((e) => e['min'] as num).reduce((a, b) => a < b ? a : b);
      final max = entries.map((e) => e['max'] as num).reduce((a, b) => a > b ? a : b);
      final icon = entries[0]['icon'];
      final desc = entries[0]['desc'];
      final windAvg = (entries.map((e) => (e['wind'] ?? 0.0) as num).reduce((a, b) => a + b) / entries.length).toStringAsFixed(1);
      final humAvg = (entries.map((e) => (e['humidity'] ?? 0) as num).reduce((a, b) => a + b) / entries.length).toStringAsFixed(0);
      final dt = entries[0]['dt'] as DateTime;
      final weekDay = [
        'Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'
      ][dt.weekday % 7];
      result.add({
        'day': weekDay,
        'min': min.toStringAsFixed(0),
        'max': max.toStringAsFixed(0),
        'icon': icon,
        'desc': desc,
        'wind': windAvg,
        'humidity': humAvg,
      });
    });
    return result.take(7).toList();
  }
}
