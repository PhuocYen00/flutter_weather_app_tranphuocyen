import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static const String base = 'https://api.openweathermap.org/data/2.5';
  static const String current = '/weather';
  static const String forecast = '/forecast';

  static String get apiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  static String build(String endpoint, Map<String, dynamic> params) {
    final query = <String, String>{
      'appid': apiKey,
      'units': 'metric',
    };

    params.forEach((key, value) {
      if (key == 'units') {
        query['units'] = value.toString();
      } else {
        query[key] = value.toString();
      }
    });

    return Uri.parse('$base$endpoint')
        .replace(queryParameters: query)
        .toString();
  }

  static String forecastUrl(double lat, double lon) {
    return Uri.parse('https://api.openweathermap.org/data/2.5/forecast')
        .replace(queryParameters: {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'units': 'metric',
      'appid': apiKey,
    }).toString();
  }
}
