import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_shimmer.dart';
import 'forecast_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<WeatherProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        actions: [
          IconButton(
            icon: Icon(
              p.isCurrentFavorite ? Icons.star : Icons.star_border,
            ),
            onPressed: p.current == null
                ? null
                : () => p.toggleFavorite(p.current!.city),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ForecastScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (p.usingCache && p.cacheTime != null)
            Container(
              width: double.infinity,
              color: Colors.orange.shade100,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Text(
                'Hiển thị dữ liệu đã lưu lúc: '
                '${p.cacheTime!.hour.toString().padLeft(2, '0')}:'
                '${p.cacheTime!.minute.toString().padLeft(2, '0')} '
                '${p.cacheTime!.day}/${p.cacheTime!.month}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          if (!p.isOnline)
            Container(
              width: double.infinity,
              color: Colors.red.shade100,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: const Text(
                'Không có kết nối mạng – đang dùng dữ liệu đã lưu (nếu có).',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ),
          Expanded(child: _buildBody(context, p)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, WeatherProvider p) {
    if (!p.initialized) {
      return const LoadingShimmer();
    }

    if (p.loading && p.current == null) {
      return const LoadingShimmer();
    }

    if (p.error != null && p.current == null) {
      return AppErrorWidget(
        message: p.error!,
        onRetry: () => p.refresh(),
      );
    }

    if (p.current == null) {
      return Center(
        child: ElevatedButton(
          onPressed: () => p.loadByLocation(),
          child: const Text('Lấy thời tiết theo vị trí hiện tại'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => p.refresh(),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          CurrentWeatherCard(
            weather: p.current!,
            hourly: p.hourly,
            daily: p.daily,
          ),
          if (p.loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
