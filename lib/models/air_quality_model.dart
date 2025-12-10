class AirQualityModel {
  /// 1: Good, 2: Fair, 3: Moderate, 4: Poor, 5: Very Poor
  final int aqi;
  final double pm2_5;
  final double pm10;
  final double no2;
  final double o3;
  final double so2;
  final double co;

  AirQualityModel({
    required this.aqi,
    required this.pm2_5,
    required this.pm10,
    required this.no2,
    required this.o3,
    required this.so2,
    required this.co,
  });

  /// j là phần tử trong data['list'][0] từ API air_pollution
  factory AirQualityModel.fromJson(Map<String, dynamic> j) {
    final main = (j['main'] ?? {}) as Map<String, dynamic>;
    final comps = (j['components'] ?? {}) as Map<String, dynamic>;

    double _get(String key) {
      final v = comps[key];
      if (v is num) return v.toDouble();
      return 0.0;
    }

    return AirQualityModel(
      aqi: (main['aqi'] as num?)?.toInt() ?? 0,
      pm2_5: _get('pm2_5'),
      pm10: _get('pm10'),
      no2: _get('no2'),
      o3: _get('o3'),
      so2: _get('so2'),
      co: _get('co'),
    );
  }
}
