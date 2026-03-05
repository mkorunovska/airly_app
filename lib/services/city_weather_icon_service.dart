import 'dart:convert';
import 'package:http/http.dart' as http;

enum WeatherIconType { sun, cloud, rain, storm, snow }

class CityWeatherIconService {
  static Future<WeatherIconType> fetchIconType({
    required double lat,
    required double lon,
  }) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon'
      '&hourly=weathercode'
      '&timezone=auto',
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      return WeatherIconType.cloud;
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final hourly = data['hourly'] as Map<String, dynamic>;
    final codes = (hourly['weathercode'] as List).cast<num>();

    final int code = codes.isNotEmpty ? codes.first.toInt() : 3;

    return _mapWeatherCodeToIcon(code);
  }

  static WeatherIconType _mapWeatherCodeToIcon(int code) {
    // Sonce
    if (code == 0) return WeatherIconType.sun;

    // Oblachno
    if (code == 1 || code == 2 || code == 3 || code == 45 || code == 48) {
      return WeatherIconType.cloud;
    }

    // Vrnezlivo
    if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) {
      return WeatherIconType.rain;
    }

    //Sneg
    if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86)) {
      return WeatherIconType.snow;
    }
    //Bura
    if (code >= 95 && code <= 99) {
      return WeatherIconType.storm;
    }

    return WeatherIconType.cloud;
  }
}