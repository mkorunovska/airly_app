import 'dart:convert';

import 'package:airly_app/models/hourly_point.dart';
import 'package:airly_app/models/weather_bundle.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static Future<WeatherBundle> fetchHourlyBundle({
    required double lat,
    required double lon,
  }) async {
    final weatherUri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon'
      '&hourly=temperature_2m,relativehumidity_2m,windspeed_10m,weathercode'
      '&timezone=auto',
    );

    final aqUri = Uri.parse(
      'https://air-quality-api.open-meteo.com/v1/air-quality'
      '?latitude=$lat&longitude=$lon'
      '&hourly=pm10,pm2_5'
      '&timezone=auto',
    );

    final weatherRes = await http.get(weatherUri);
    final aqRes = await http.get(aqUri);

    if (weatherRes.statusCode != 200) {
      throw Exception('Weather request failed (${weatherRes.statusCode})');
    }
    if (aqRes.statusCode != 200) {
      throw Exception('Air quality request failed (${aqRes.statusCode})');
    }

    final weatherJson = jsonDecode(weatherRes.body) as Map<String, dynamic>;
    final aqJson = jsonDecode(aqRes.body) as Map<String, dynamic>;

    final weatherHourly = weatherJson['hourly'] as Map<String, dynamic>;
    final aqHourly = aqJson['hourly'] as Map<String, dynamic>;

    final times = (weatherHourly['time'] as List).cast<String>();

    final temp = (weatherHourly['temperature_2m'] as List)
        .map((e) => (e as num).toDouble())
        .toList();

    final hum = (weatherHourly['relativehumidity_2m'] as List)
        .map((e) => (e as num).toDouble())
        .toList();

    final wind = (weatherHourly['windspeed_10m'] as List)
        .map((e) => (e as num).toDouble())
        .toList();

    final codes = (weatherHourly['weathercode'] as List)
        .map((e) => (e as num?)?.toDouble() ?? 0.0)
        .toList();

    final pm10 = (aqHourly['pm10'] as List)
        .map((e) => (e as num?)?.toDouble() ?? 0.0)
        .toList();

    final pm25 = (aqHourly['pm2_5'] as List)
        .map((e) => (e as num?)?.toDouble() ?? 0.0)
        .toList();

    List<HourlyPoint> buildSeries(List<double> values) {
      final len = values.length < times.length ? values.length : times.length;
      return List.generate(len, (i) {
        return HourlyPoint(
          time: DateTime.parse(times[i]),
          value: values[i],
        );
      });
    }

    return WeatherBundle(
      temperatureC: buildSeries(temp),
      humidity: buildSeries(hum),
      windSpeed: buildSeries(wind),
      pm10: buildSeries(pm10),
      pm25: buildSeries(pm25),
      weatherCode: buildSeries(codes), 
    );
  }
}
