import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/forecast_model.dart';
import '../models/hourly_weather_model.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';
import 'daily_forecast_card.dart';
import 'hourly_forecast_list.dart';
import 'weather_detail_item.dart';

class CurrentWeatherCard extends StatelessWidget {
  final WeatherModel weather;
  final List<HourlyWeatherModel> hourly;
  final List<ForecastModel> daily;

  const CurrentWeatherCard({
    super.key,
    required this.weather,
    required this.hourly,
    required this.daily,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.watch<WeatherProvider>();

    final sunrise =
        DateFormat(p.is24h ? 'HH:mm' : 'h:mm a').format(weather.sunrise);
    final sunset =
        DateFormat(p.is24h ? 'HH:mm' : 'h:mm a').format(weather.sunset);

    final visKm = (weather.visibility / 1000).toStringAsFixed(1);
    final aqi = p.airQuality;

    final cities = <String>[
      if (weather.city.isNotEmpty) weather.city,
      ...p.favoriteCities.where(
        (c) => c.toLowerCase() != weather.city.toLowerCase(),
      ),
    ];

    String aqiLabel = p.t('Không có dữ liệu', 'No data');
    Color aqiColor = Colors.grey;
    String aqiDesc = '';

    if (aqi != null) {
      switch (aqi.aqi) {
        case 1:
          aqiLabel = p.t('Tốt', 'Good');
          aqiColor = Colors.green;
          aqiDesc = p.t(
            'Không khí trong lành, có thể hoạt động bình thường.',
            'Air quality is good. It’s safe to go outside.',
          );
          break;
        case 2:
          aqiLabel = p.t('Trung bình', 'Fair');
          aqiColor = Colors.lightGreen;
          aqiDesc = p.t(
            'Chấp nhận được, hầu hết mọi người đều an toàn.',
            'Air quality is acceptable for most people.',
          );
          break;
        case 3:
          aqiLabel = p.t('Trung bình - Nhạy cảm chú ý', 'Moderate');
          aqiColor = Colors.orange;
          aqiDesc = p.t(
            'Nhóm nhạy cảm có thể bị ảnh hưởng nhẹ.',
            'Sensitive groups may be affected.',
          );
          break;
        case 4:
          aqiLabel = p.t('Kém', 'Poor');
          aqiColor = Colors.red;
          aqiDesc = p.t(
            'Không khí kém, nên hạn chế hoạt động ngoài trời.',
            'Poor air quality, limit outdoor activities.',
          );
          break;
        case 5:
          aqiLabel = p.t('Rất kém', 'Very poor');
          aqiColor = Colors.purple;
          aqiDesc = p.t(
            'Rất ô nhiễm, nên ở trong nhà nếu có thể.',
            'Very polluted, stay indoors if possible.',
          );
          break;
        default:
          break;
      }
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          if (p.alertMessage != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Card(
                color: Colors.orange.shade50,
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.orange),
                  title: Text(
                    p.t('Cảnh báo thời tiết', 'Weather alert'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(p.alertMessage!),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey.shade200,
            child: CachedNetworkImage(
              imageUrl:
                  "https://openweathermap.org/img/wn/${weather.icon}@4x.png",
              width: 70,
              height: 70,
              fit: BoxFit.contain,
              errorWidget: (context, url, error) => const Icon(
                Icons.cloud,
                size: 50,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            p.formatTemp(weather.temp, fractionDigits: 1),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${weather.city}, ${weather.country}',
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            weather.description,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          if (cities.length > 1) ...[
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: cities.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cityName = cities[index];
                  final isSelected =
                      cityName.toLowerCase() == weather.city.toLowerCase();

                  return ChoiceChip(
                    label: Text(cityName),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (!selected) return;
                      if (isSelected) return;

                      p.loadByCity(cityName, saveCity: false);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.1,
              children: [
                WeatherDetailItem(
                  icon: Icons.water_drop,
                  title: p.t('Độ ẩm', 'Humidity'),
                  value: '${weather.humidity}%',
                ),
                WeatherDetailItem(
                  icon: Icons.speed,
                  title: p.t('Áp suất', 'Pressure'),
                  value: '${weather.pressure} hPa',
                ),
                WeatherDetailItem(
                  icon: Icons.visibility,
                  title: p.t('Tầm nhìn', 'Visibility'),
                  value: '$visKm km',
                ),
                WeatherDetailItem(
                  icon: Icons.air,
                  title: p.t('Tốc độ gió', 'Wind speed'),
                  value: p.formatWindSpeed(weather.windSpeed),
                ),
                WeatherDetailItem(
                  icon: Icons.navigation,
                  title: p.t('Hướng gió', 'Wind direction'),
                  value: '${weather.windDeg}°',
                ),
                WeatherDetailItem(
                  icon: Icons.wb_sunny_outlined,
                  title: 'UV',
                  value: 'N/A',
                  subtitle: p.t(
                    'API free không có UV',
                    'Free API does not provide UV',
                  ),
                ),
                WeatherDetailItem(
                  icon: Icons.wb_sunny,
                  title: p.t('Mặt trời mọc', 'Sunrise'),
                  value: sunrise,
                ),
                WeatherDetailItem(
                  icon: Icons.nights_stay,
                  title: p.t('Mặt trời lặn', 'Sunset'),
                  value: sunset,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.t('Chất lượng không khí (AQI)', 'Air Quality Index'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: aqiColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            aqi != null
                                ? 'AQI ${aqi.aqi} • $aqiLabel'
                                : aqiLabel,
                            style: TextStyle(
                              color: aqiColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (aqi != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        aqiDesc,
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PM2.5: ${aqi.pm2_5.toStringAsFixed(1)} µg/m³',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'PM10: ${aqi.pm10.toStringAsFixed(1)} µg/m³',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          HourlyForecastList(items: hourly),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daily.length,
            itemBuilder: (_, i) => DailyForecastCard(item: daily[i]),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
