class HourlyWeatherModel {
  final DateTime time;
  final double temp;
  final String icon;

  HourlyWeatherModel({
    required this.time,
    required this.temp,
    required this.icon,
  });

  factory HourlyWeatherModel.fromJson(Map<String, dynamic> j) {
    // 1) /forecast (3h)
    if (j.containsKey('dt_txt')) {
      return HourlyWeatherModel(
        time: DateTime.parse(j['dt_txt'] as String),
        temp: (j['main']['temp'] as num).toDouble(),
        icon: (j['weather']?[0]?['icon'] ?? '') as String,
      );
    }

    // 2) onecall/hourly (nếu sau này có dùng lại)
    if (j.containsKey('dt') && j.containsKey('temp')) {
      return HourlyWeatherModel(
        time: DateTime.fromMillisecondsSinceEpoch(
          (j['dt'] as num).toInt() * 1000,
        ),
        temp: (j['temp'] as num).toDouble(),
        icon: (j['weather']?[0]?['icon'] ?? '') as String,
      );
    }

    // 3) dữ liệu cache
    return HourlyWeatherModel(
      time: DateTime.parse(j['time'] as String),
      temp: (j['temp'] as num).toDouble(),
      icon: j['icon'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'time': time.toIso8601String(),
        'temp': temp,
        'icon': icon,
      };
}
