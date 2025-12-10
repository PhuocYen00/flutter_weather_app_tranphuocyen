class LocationModel {
  final double lat;
  final double lon;
  final String city;
  final String? province;
  final String? country;

  LocationModel({
    required this.lat,
    required this.lon,
    required this.city,
    this.province,
    this.country,
  });
}
