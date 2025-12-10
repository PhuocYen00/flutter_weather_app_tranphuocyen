import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/hourly_weather_model.dart';
import '../providers/weather_provider.dart';

class HourlyForecastList extends StatelessWidget {
  final List<HourlyWeatherModel> items;

  const HourlyForecastList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<WeatherProvider>();
    final pattern = p.is24h ? 'HH:mm' : 'h a';

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final h = items[i];
          final time = DateFormat(pattern).format(h.time);
          return Container(
            width: 70,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(time, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Image.network(
                  "https://openweathermap.org/img/wn/${h.icon}@2x.png",
                  width: 36,
                  height: 36,
                ),
                const SizedBox(height: 4),
                Text(
                  p.formatTemp(h.temp, fractionDigits: 0),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
