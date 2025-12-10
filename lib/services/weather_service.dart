import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../models/hourly_weather_model.dart';
import '../models/air_quality_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static String get _apiKey => ApiConfig.apiKey;

  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  Future<WeatherModel> currentByCoord(
    double lat,
    double lon, {
    String lang = 'en',
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=$lang',
    );

    final res = await _client.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Lỗi lấy thời tiết hiện tại: ${res.statusCode}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return WeatherModel.fromJson(data);
  }

  Future<WeatherModel> currentByCity(
    String city, {
    String lang = 'en',
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/weather?q=$city,VN&appid=$_apiKey&units=metric&lang=$lang',
    );

    final res = await _client.get(uri);

    if (res.statusCode != 200) {
      String msg = 'Lỗi lấy thời tiết hiện tại: ${res.statusCode}';
      try {
        final body = jsonDecode(res.body);
        if (body is Map && body['message'] != null) {
          msg = 'Lỗi: ${body['message']} (${res.statusCode})';
        }
      } catch (_) {}
      throw Exception(msg);
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return WeatherModel.fromJson(data);
  }

  Future<List<ForecastModel>> forecastDaily(
    double lat,
    double lon, {
    String lang = 'en',
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=$lang',
    );

    final res = await _client.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Lỗi lấy dự báo ngày: ${res.statusCode}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final List rawList = data['list'] ?? [];

    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final item in rawList) {
      if (item is! Map<String, dynamic>) continue;
      final dtTxt = item['dt_txt'] as String?;
      if (dtTxt == null) continue;
      final dateStr = dtTxt.split(' ').first;
      grouped.putIfAbsent(dateStr, () => []).add(item);
    }

    final result = <ForecastModel>[];
    final sortedKeys = grouped.keys.toList()..sort();

    for (final dateStr in sortedKeys) {
      final items = grouped[dateStr]!;

      double minTemp = double.infinity;
      double maxTemp = -double.infinity;
      String icon = '';
      String desc = '';
      bool hasTemp = false;
      double popSum = 0.0;
      int popCount = 0;

      for (final it in items) {
        final mainRaw = it['main'];
        final Map<String, dynamic> main = mainRaw is Map<String, dynamic>
            ? mainRaw
            : mainRaw is Map
                ? mainRaw.map((k, v) => MapEntry(k.toString(), v))
                : const <String, dynamic>{};

        final tMinRaw = main['temp_min'] ?? main['temp'];
        final tMaxRaw = main['temp_max'] ?? main['temp'];

        if (tMinRaw is num && tMaxRaw is num) {
          final tMin = tMinRaw.toDouble();
          final tMax = tMaxRaw.toDouble();
          if (tMin < minTemp) minTemp = tMin;
          if (tMax > maxTemp) maxTemp = tMax;
          hasTemp = true;
        }

        final popRaw = it['pop'];
        if (popRaw is num) {
          popSum += popRaw.toDouble();
          popCount++;
        }

        if (icon.isEmpty &&
            it['weather'] is List &&
            (it['weather'] as List).isNotEmpty) {
          final w = (it['weather'] as List).first;
          if (w is Map<String, dynamic>) {
            icon = (w['icon'] ?? '') as String;
            desc = (w['description'] ?? '') as String;
          }
        }
      }

      if (!hasTemp) continue;

      final date = DateTime.parse(dateStr);

      final double dayTemp = (minTemp + maxTemp) / 2;
      final double pop = popCount > 0 ? (popSum / popCount) : 0.0;

      final fakeDailyJson = {
        'dt': date.millisecondsSinceEpoch ~/ 1000,
        'temp': {
          'day': dayTemp,
          'min': minTemp,
          'max': maxTemp,
        },
        'weather': [
          {
            'icon': icon,
            'description': desc,
          }
        ],
        'pop': pop,
      };

      result.add(ForecastModel.fromDailyJson(fakeDailyJson));
    }

    return result.take(7).toList();
  }

  Future<List<HourlyWeatherModel>> forecastHourly(
    double lat,
    double lon, {
    String lang = 'en',
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=$lang',
    );

    final res = await _client.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Lỗi lấy dự báo giờ: ${res.statusCode}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final List list = data['list'] ?? [];

    return list.take(8).map((e) {
      return HourlyWeatherModel.fromJson(e as Map<String, dynamic>);
    }).toList();
  }

  Future<AirQualityModel> fetchAirQuality(double lat, double lon) async {
    final uri = Uri.parse(
      '$_baseUrl/air_pollution?lat=$lat&lon=$lon&appid=$_apiKey',
    );

    final res = await _client.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Lỗi lấy AQI: ${res.statusCode}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final List list = data['list'] ?? [];
    if (list.isEmpty || list.first is! Map<String, dynamic>) {
      throw Exception('Dữ liệu AQI không hợp lệ');
    }

    return AirQualityModel.fromJson(list.first as Map<String, dynamic>);
  }
}
