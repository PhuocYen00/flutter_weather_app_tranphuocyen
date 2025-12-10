import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../models/hourly_weather_model.dart';

class WeatherCache {
  final WeatherModel current;
  final List<ForecastModel> daily;
  final List<HourlyWeatherModel> hourly;
  final DateTime time;

  WeatherCache({
    required this.current,
    required this.daily,
    required this.hourly,
    required this.time,
  });
}

class StorageService {
  static const _keyUnit = 'unit';
  static const _keyLastCity = 'last_city';

  static const _keySearchHistory = 'search_history';
  static const _keyFavorites = 'favorite_cities';

  static const _keyWindUnit = 'wind_unit';
  static const _keyHourFormat = 'hour_format';

  static const _keyCurrentCache = 'current_cache';
  static const _keyDailyCache = 'daily_cache';
  static const _keyHourlyCache = 'hourly_cache';
  static const _keyCacheTime = 'cache_time';
  static const _keyLanguage = 'language';

  Future<void> saveLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, lang);
  }

  Future<String> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage) ?? 'vi';
  }

  Future<String> loadUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUnit) ?? 'metric';
  }

  Future<void> saveUnit(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUnit, unit);
  }

  Future<String?> loadLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastCity);
  }

  Future<void> saveLastCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastCity, city);
  }

  Future<List<String>> loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keySearchHistory) ?? [];
  }

  Future<void> saveSearchHistory(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keySearchHistory, list);
  }

  Future<List<String>> loadFavoriteCities() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFavorites) ?? [];
  }

  Future<void> saveFavoriteCities(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyFavorites, list);
  }

  Future<String> loadWindUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyWindUnit) ?? 'mps';
  }

  Future<void> saveWindUnit(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyWindUnit, unit);
  }

  Future<String> loadHourFormat() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyHourFormat) ?? '24';
  }

  Future<void> saveHourFormat(String format) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHourFormat, format);
  }

  Future<void> saveWeatherCache(
    WeatherModel current,
    List<ForecastModel> daily,
    List<HourlyWeatherModel> hourly,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _keyCurrentCache,
      jsonEncode(current.toJson()),
    );

    await prefs.setString(
      _keyDailyCache,
      jsonEncode(daily.map((e) => e.toJson()).toList()),
    );

    await prefs.setString(
      _keyHourlyCache,
      jsonEncode(hourly.map((e) => e.toJson()).toList()),
    );

    await prefs.setString(
      _keyCacheTime,
      DateTime.now().toIso8601String(),
    );
  }

  Future<WeatherCache?> loadWeatherCache() async {
    final prefs = await SharedPreferences.getInstance();

    final currentStr = prefs.getString(_keyCurrentCache);
    final dailyStr = prefs.getString(_keyDailyCache);
    final hourlyStr = prefs.getString(_keyHourlyCache);
    final timeStr = prefs.getString(_keyCacheTime);

    if (currentStr == null ||
        dailyStr == null ||
        hourlyStr == null ||
        timeStr == null) {
      return null;
    }

    try {
      final cacheTime = DateTime.parse(timeStr);

      if (DateTime.now().difference(cacheTime) > const Duration(minutes: 30)) {
        return null;
      }

      final currentJson = jsonDecode(currentStr);
      final dailyJson = jsonDecode(dailyStr) as List<dynamic>;
      final hourlyJson = jsonDecode(hourlyStr) as List<dynamic>;

      return WeatherCache(
        current: WeatherModel.fromJson(currentJson),
        daily: dailyJson.map((e) => ForecastModel.fromJson(e)).toList(),
        hourly: hourlyJson.map((e) => HourlyWeatherModel.fromJson(e)).toList(),
        time: cacheTime,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clearWeatherCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentCache);
    await prefs.remove(_keyDailyCache);
    await prefs.remove(_keyHourlyCache);
    await prefs.remove(_keyCacheTime);
  }
}
