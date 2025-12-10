class ForecastModel {
  final DateTime date;
  final double dayTemp;
  final double minTemp;
  final double maxTemp;
  final String icon;
  final String description;

  final double pop;

  ForecastModel({
    required this.date,
    required this.dayTemp,
    required this.minTemp,
    required this.maxTemp,
    required this.icon,
    required this.description,
    this.pop = 0.0,
  });

  /// Dùng cho dữ liệu kiểu One Call (hoặc fake JSON mình dựng từ /forecast)
  factory ForecastModel.fromDailyJson(Map<String, dynamic> j) {
    final dt = (j['dt'] as num?)?.toInt() ?? 0;
    final temp = (j['temp'] ?? {}) as Map<String, dynamic>;

    final day = (temp['day'] as num?)?.toDouble() ?? 0.0;
    final min = (temp['min'] as num?)?.toDouble() ?? day;
    final max = (temp['max'] as num?)?.toDouble() ?? day;

    String icon = '';
    String desc = '';
    if (j['weather'] is List && (j['weather'] as List).isNotEmpty) {
      final w = (j['weather'] as List).first;
      if (w is Map<String, dynamic>) {
        icon = (w['icon'] ?? '') as String;
        desc = (w['description'] ?? '') as String;
      }
    }

    final pop = (j['pop'] as num?)?.toDouble() ?? 0.0;

    return ForecastModel(
      date:
          DateTime.fromMillisecondsSinceEpoch(dt * 1000, isUtc: true).toLocal(),
      dayTemp: day,
      minTemp: min,
      maxTemp: max,
      icon: icon,
      description: desc,
      pop: pop,
    );
  }

  factory ForecastModel.fromJson(Map<String, dynamic> j) {
    return ForecastModel(
      date: DateTime.parse(j['date'] as String),
      dayTemp: (j['dayTemp'] as num).toDouble(),
      minTemp: (j['minTemp'] as num).toDouble(),
      maxTemp: (j['maxTemp'] as num).toDouble(),
      icon: j['icon'] as String,
      description: j['description'] as String,
      pop: (j['pop'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'dayTemp': dayTemp,
      'minTemp': minTemp,
      'maxTemp': maxTemp,
      'icon': icon,
      'description': description,
      'pop': pop,
    };
  }
}
