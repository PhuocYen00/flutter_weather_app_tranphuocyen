import 'package:flutter/material.dart';

import '../models/location_model.dart';
import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _service;

  LocationModel? _location;
  bool _loading = false;
  String? _error;

  LocationProvider(this._service);

  LocationModel? get location => _location;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _location = await _service.getCurrentLocation();
      if (_location == null) {
        _error = 'Cannot get location';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
