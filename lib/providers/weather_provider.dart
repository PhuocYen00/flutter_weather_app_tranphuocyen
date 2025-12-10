import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../models/forecast_model.dart';
import '../models/hourly_weather_model.dart';
import '../models/weather_model.dart';
import '../models/air_quality_model.dart';
import '../services/connectivity_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService;
  final LocationService _locationService;
  final StorageService _storageService;
  final ConnectivityService _connectivityService;

  WeatherModel? _current;
  List<ForecastModel> _daily = [];
  List<HourlyWeatherModel> _hourly = [];
  AirQualityModel? _airQuality;

  bool _loading = false;
  String? _error;

  bool _isMetric = true;
  bool _isOnline = true;
  bool _initialized = false;

  bool _usingCache = false;
  DateTime? _cacheTime;

  List<String> _searchHistory = [];
  List<String> _favoriteCities = [];

  String _windUnit = 'mps';
  String _hourFormat = '24';
  String _language = 'vi';

  String? _alertMessage;

  WeatherProvider(
    this._weatherService,
    this._locationService,
    this._storageService,
    this._connectivityService,
  ) {
    _init();
  }

  Future<void> _init() async {
    _isMetric = (await _storageService.loadUnit()) != 'imperial';
    _windUnit = await _storageService.loadWindUnit();
    _hourFormat = await _storageService.loadHourFormat();
    _language = await _storageService.loadLanguage();

    _searchHistory = await _storageService.loadSearchHistory();
    _favoriteCities = await _storageService.loadFavoriteCities();

    final cache = await _storageService.loadWeatherCache();
    if (cache != null) {
      _current = cache.current;
      _daily = cache.daily;
      _hourly = cache.hourly;
      _cacheTime = cache.time;
      _usingCache = true;
    }

    _updateAlert();

    _isOnline = await _connectivityService.checkConnection();
    _connectivityService.onStatusChange.listen((result) {
      final online = result != ConnectivityResult.none;
      if (online != _isOnline) {
        _isOnline = online;
        notifyListeners();
      }
    });

    final lastCity = await _storageService.loadLastCity();

    _initialized = true;
    notifyListeners();

    if (lastCity != null && lastCity.isNotEmpty && _isOnline) {
      loadByCity(lastCity, saveCity: false);
    }
  }

  bool get loading => _loading;
  String? get error => _error;
  WeatherModel? get current => _current;
  List<ForecastModel> get daily => _daily;
  List<HourlyWeatherModel> get hourly => _hourly;
  AirQualityModel? get airQuality => _airQuality;

  bool get isMetric => _isMetric;
  bool get isOnline => _isOnline;
  bool get initialized => _initialized;

  bool get usingCache => _usingCache;
  DateTime? get cacheTime => _cacheTime;

  List<String> get searchHistory => List.unmodifiable(_searchHistory);
  List<String> get favoriteCities => List.unmodifiable(_favoriteCities);

  String get windUnit => _windUnit;
  String get hourFormat => _hourFormat;
  bool get is24h => _hourFormat == '24';

  String get language => _language;
  bool get isVietnamese => _language == 'vi';

  String? get alertMessage => _alertMessage;

  String get unitLabel => _isMetric ? '°C' : '°F';

  bool get isCurrentFavorite {
    if (_current == null) return false;
    return _favoriteCities
        .any((c) => c.toLowerCase() == _current!.city.toLowerCase());
  }

  String t(String vi, String en) => isVietnamese ? vi : en;

  String formatTemp(double celsius, {int fractionDigits = 1}) {
    if (_isMetric) {
      return '${celsius.toStringAsFixed(fractionDigits)}°C';
    }
    final f = celsius * 9 / 5 + 32;
    return '${f.toStringAsFixed(fractionDigits)}°F';
  }

  String formatWindSpeed(double mps) {
    double value = mps;
    String label = 'm/s';

    switch (_windUnit) {
      case 'kmh':
        value = mps * 3.6;
        label = 'km/h';
        break;
      case 'mph':
        value = mps * 2.23694;
        label = 'mph';
        break;
      default:
        value = mps;
        label = 'm/s';
    }

    return '${value.toStringAsFixed(1)} $label';
  }

  void _updateAlert() {
    _alertMessage = null;
    if (_current == null) {
      notifyListeners();
      return;
    }

    final temp = _current!.temp;
    final buf = <String>[];

    if (temp >= 37) {
      buf.add(t(
        'Cảnh báo nắng nóng: Hạn chế ra ngoài buổi trưa, uống nhiều nước.',
        'Heat warning: Avoid going out at noon, drink plenty of water.',
      ));
    } else if (temp >= 35) {
      buf.add(t(
        'Thời tiết nóng: Uống đủ nước và tránh nắng gắt.',
        'Hot weather: Stay hydrated and avoid strong sunlight.',
      ));
    }

    if (temp <= 10) {
      buf.add(t(
        'Trời rất lạnh: Mặc đủ ấm khi ra ngoài.',
        'Very cold: Wear warm clothes when going outside.',
      ));
    } else if (temp <= 15) {
      buf.add(t(
        'Trời lạnh: Nên mang áo khoác.',
        'Cold weather: Consider wearing a jacket.',
      ));
    }

    if (_airQuality != null) {
      final aqi = _airQuality!.aqi;
      if (aqi >= 5) {
        buf.add(t(
          'Chất lượng không khí rất kém: Hạn chế hoạt động ngoài trời, đặc biệt với người có bệnh hô hấp.',
          'Air quality is very poor: Limit outdoor activities, especially if you have respiratory issues.',
        ));
      } else if (aqi == 4) {
        buf.add(t(
          'Không khí kém: Người nhạy cảm nên hạn chế ra ngoài.',
          'Air quality is poor: Sensitive groups should limit outdoor exposure.',
        ));
      } else if (aqi == 3) {
        buf.add(t(
          'Không khí ở mức trung bình: Có thể ảnh hưởng nhẹ tới nhóm nhạy cảm.',
          'Air quality is moderate: May affect sensitive individuals.',
        ));
      }
    }

    if (buf.isEmpty) {
      _alertMessage = null;
    } else {
      _alertMessage = buf.join(' ');
    }

    notifyListeners();
  }

  Future<void> _loadAll(double lat, double lon) async {
    _error = null;
    _loading = true;
    notifyListeners();

    try {
      final w = await _weatherService.currentByCoord(
        lat,
        lon,
        lang: _language,
      );
      _current = w;

      _daily = await _weatherService.forecastDaily(
        lat,
        lon,
        lang: _language,
      );
      _hourly = await _weatherService.forecastHourly(
        lat,
        lon,
        lang: _language,
      );

      try {
        _airQuality = await _weatherService.fetchAirQuality(lat, lon);
      } catch (_) {
        _airQuality = null;
      }

      await _storageService.saveWeatherCache(_current!, _daily, _hourly);
      _usingCache = false;
      _cacheTime = DateTime.now();

      _updateAlert();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadByLocation() async {
    if (!_isOnline) {
      _error = t(
        'Không có kết nối mạng. Đang dùng dữ liệu đã lưu (nếu có).',
        'No internet connection. Using cached data if available.',
      );
      notifyListeners();
      return;
    }

    final loc = await _locationService.getCurrentLocation();
    if (loc == null) {
      _error = t(
        'Không lấy được vị trí hiện tại.',
        'Could not get current location.',
      );
      notifyListeners();
      return;
    }

    await _loadAll(loc.lat, loc.lon);
  }

  Future<void> loadByCity(String city, {bool saveCity = true}) async {
    final input = city.trim();
    if (input.isEmpty) return;

    if (!_isOnline) {
      _error = t(
        'Không có kết nối mạng. Đang dùng dữ liệu đã lưu (nếu có).',
        'No internet connection. Using cached data if available.',
      );
      notifyListeners();
      return;
    }

    _error = null;
    _loading = true;
    notifyListeners();

    try {
      final w = await _weatherService.currentByCity(
        input,
        lang: _language,
      );
      _current = w;

      _daily = await _weatherService.forecastDaily(
        w.lat,
        w.lon,
        lang: _language,
      );
      _hourly = await _weatherService.forecastHourly(
        w.lat,
        w.lon,
        lang: _language,
      );

      try {
        _airQuality = await _weatherService.fetchAirQuality(w.lat, w.lon);
      } catch (_) {
        _airQuality = null;
      }

      await _storageService.saveWeatherCache(_current!, _daily, _hourly);
      _usingCache = false;
      _cacheTime = DateTime.now();

      if (saveCity) {
        await _storageService.saveLastCity(w.city);
      }
      _addSearchHistory(w.city);

      _updateAlert();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_current == null) {
      await loadByLocation();
    } else {
      await loadByCity(_current!.city, saveCity: false);
    }
  }

  void _addSearchHistory(String city) {
    city = city.trim();
    if (city.isEmpty) return;

    _searchHistory.removeWhere(
      (e) => e.toLowerCase() == city.toLowerCase(),
    );
    _searchHistory.insert(0, city);
    if (_searchHistory.length > 10) {
      _searchHistory = _searchHistory.take(10).toList();
    }
    _storageService.saveSearchHistory(_searchHistory);
    notifyListeners();
  }

  Future<void> clearSearchHistory() async {
    _searchHistory.clear();
    await _storageService.saveSearchHistory(_searchHistory);
    notifyListeners();
  }

  Future<void> toggleFavorite(String city) async {
    final idx = _favoriteCities
        .indexWhere((e) => e.toLowerCase() == city.toLowerCase());
    if (idx >= 0) {
      _favoriteCities.removeAt(idx);
    } else {
      if (_favoriteCities.length >= 5) {
        _favoriteCities.removeLast();
      }
      _favoriteCities.insert(0, city);
    }
    await _storageService.saveFavoriteCities(_favoriteCities);
    notifyListeners();
  }

  Future<void> toggleUnit(bool value) async {
    _isMetric = value;
    await _storageService.saveUnit(_isMetric ? 'metric' : 'imperial');
    notifyListeners();
  }

  Future<void> setWindUnit(String unit) async {
    _windUnit = unit;
    await _storageService.saveWindUnit(unit);
    notifyListeners();
  }

  Future<void> setHourFormat(String format) async {
    _hourFormat = format;
    await _storageService.saveHourFormat(format);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    if (lang != 'vi' && lang != 'en') return;
    if (lang == _language) return;

    _language = lang;
    await _storageService.saveLanguage(lang);

    if (_isOnline) {
      if (_current != null) {
        await loadByCity(_current!.city, saveCity: false);
      } else {
        await loadByLocation();
      }
    } else {
      notifyListeners();
    }
  }
}
