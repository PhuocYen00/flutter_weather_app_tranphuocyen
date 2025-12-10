import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/forecast_model.dart';
import '../providers/weather_provider.dart';

class DailyForecastCard extends StatelessWidget {
  final ForecastModel item;

  const DailyForecastCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<WeatherProvider>();

    final dateText = DateFormat('EEE, dd/MM').format(item.date);
    final maxText = p.formatTemp(item.maxTemp, fractionDigits: 0);
    final minText = p.formatTemp(item.minTemp, fractionDigits: 0);

    final popPercent = (item.pop * 100).round();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Image.network(
          'https://openweathermap.org/img/wn/${item.icon}@2x.png',
          width: 40,
          height: 40,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.cloud, size: 32, color: Colors.grey),
        ),
        title: Text(dateText),
        subtitle: Text(item.description),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$maxText / $minText',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Mưa: $popPercent%',
              style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
          ],
        ),
      ),
    );
  }
}
