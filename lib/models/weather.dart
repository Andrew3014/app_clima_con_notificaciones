class WeatherData {
  final String name;
  final double temp;
  final int humidity;
  final int pressure;
  final String main;
  final String description;
  final String icon;
  final double windSpeed;

  WeatherData({
    required this.name,
    required this.temp,
    required this.humidity,
    required this.pressure,
    required this.main,
    required this.description,
    required this.icon,
    required this.windSpeed,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      name: json['name'],
      temp: json['main']['temp'].toDouble(),
      humidity: json['main']['humidity'],
      pressure: json['main']['pressure'],
      main: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      windSpeed: json['wind']['speed'].toDouble(),
    );
  }
}

