import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../models/location_model.dart';

class LocationService {
  Future<LocationModel?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    String city = '';
    String? province;
    String? country;

    try {
      final placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        city = p.locality ?? '';
        province = p.administrativeArea;
        country = p.country;
      }
    } catch (_) {}

    return LocationModel(
      lat: pos.latitude,
      lon: pos.longitude,
      city: city.isEmpty ? 'Unknown' : city,
      province: province,
      country: country,
    );
  }
}
