class WeatherModel {
  final String city;
  final String country;

  final double temp;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int windDeg;
  final int pressure;
  final int visibility;

  final String description;
  final String icon;

  final double lat;
  final double lon;

  final DateTime sunrise;
  final DateTime sunset;

  WeatherModel({
    required this.city,
    required this.country,
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.pressure,
    required this.visibility,
    required this.description,
    required this.icon,
    required this.lat,
    required this.lon,
    required this.sunrise,
    required this.sunset,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> j) {
    final main = j['main'] ?? {};
    final wind = j['wind'] ?? {};
    final weather = (j['weather'] ?? [{}])[0];
    final sys = j['sys'] ?? {};

    double _d(dynamic v) {
      if (v == null) return 0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0;
      return 0;
    }

    int _i(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return WeatherModel(
      city: j['name'] ?? '',
      country: sys['country'] ?? '',
      temp: _d(main['temp']),
      feelsLike: _d(main['feels_like']),
      humidity: _i(main['humidity']),
      pressure: _i(main['pressure']),
      windSpeed: _d(wind['speed']),
      windDeg: _i(wind['deg']),
      visibility: _i(j['visibility']),
      description: weather['description'] ?? '',
      icon: weather['icon'] ?? '',
      lat: _d(j['coord']?['lat']),
      lon: _d(j['coord']?['lon']),
      sunrise: DateTime.fromMillisecondsSinceEpoch(_i(sys['sunrise']) * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(_i(sys['sunset']) * 1000),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': city,
        'sys': {
          'country': country,
          'sunrise': sunrise.millisecondsSinceEpoch ~/ 1000,
          'sunset': sunset.millisecondsSinceEpoch ~/ 1000,
        },
        'coord': {'lat': lat, 'lon': lon},
        'main': {
          'temp': temp,
          'feels_like': feelsLike,
          'humidity': humidity,
          'pressure': pressure,
        },
        'wind': {'speed': windSpeed, 'deg': windDeg},
        'visibility': visibility,
        'weather': [
          {'description': description, 'icon': icon}
        ],
      };
  WeatherModel copyWith({
    String? city,
    String? country,
  }) {
    return WeatherModel(
      city: city ?? this.city,
      country: country ?? this.country,
      temp: temp,
      feelsLike: feelsLike,
      humidity: humidity,
      windSpeed: windSpeed,
      windDeg: windDeg,
      pressure: pressure,
      visibility: visibility,
      description: description,
      icon: icon,
      lat: lat,
      lon: lon,
      sunrise: sunrise,
      sunset: sunset,
    );
  }
}
