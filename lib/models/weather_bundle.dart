import 'package:airly_app/models/hourly_point.dart';

class WeatherBundle {
  final List<HourlyPoint> temperatureC;
  final List<HourlyPoint> humidity;
  final List<HourlyPoint> windSpeed;
  final List<HourlyPoint> pm10;
  final List<HourlyPoint> pm25;


  final List<HourlyPoint> weatherCode;

  const WeatherBundle({
    required this.temperatureC,
    required this.humidity,
    required this.windSpeed,
    required this.pm10,
    required this.pm25,
    required this.weatherCode,
  });
}
