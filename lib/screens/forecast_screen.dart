import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/forecast_model.dart';
import '../providers/weather_provider.dart';
import '../widgets/daily_forecast_card.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();
    final List<ForecastModel> daily = weatherProvider.daily;
    final bool loading = weatherProvider.loading;
    final String? error = weatherProvider.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dự báo 7 ngày'),
      ),
      body: Builder(
        builder: (_) {
          if (loading && daily.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (error != null && error.isNotEmpty && daily.isEmpty) {
            return Center(child: Text(error));
          }

          if (daily.isEmpty) {
            return const Center(
              child: Text('Chưa có dữ liệu dự báo'),
            );
          }

          return ListView.builder(
            itemCount: daily.length,
            itemBuilder: (context, index) {
              final item = daily[index];
              return DailyForecastCard(item: item);
            },
          );
        },
      ),
    );
  }
}
