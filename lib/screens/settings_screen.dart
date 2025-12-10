import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<WeatherProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(p.t('Cài đặt', 'Settings')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            p.t('Nhiệt độ', 'Temperature'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SwitchListTile(
            title: Text(p.isMetric ? '°C' : '°F'),
            subtitle: Text(
              p.t('Chuyển đổi giữa °C và °F', 'Switch between °C and °F'),
            ),
            value: p.isMetric,
            onChanged: (value) => p.toggleUnit(value),
          ),
          const Divider(),
          Text(
            p.t('Tốc độ gió', 'Wind speed'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(p.t('Đơn vị tốc độ gió', 'Wind speed unit')),
            subtitle: DropdownButton<String>(
              value: p.windUnit,
              isExpanded: true,
              items: [
                DropdownMenuItem(
                  value: 'mps',
                  child:
                      Text(p.t('m/s (mét mỗi giây)', 'm/s (meters per sec)')),
                ),
                DropdownMenuItem(
                  value: 'kmh',
                  child: Text(
                      p.t('km/h (kilômét mỗi giờ)', 'km/h (kilometers/h)')),
                ),
                DropdownMenuItem(
                  value: 'mph',
                  child: Text(p.t('mph (mile mỗi giờ)', 'mph (miles per h)')),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  p.setWindUnit(value);
                }
              },
            ),
          ),
          const Divider(height: 32),
          Text(
            p.t('Định dạng giờ', 'Time format'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: Text(p.t('24 giờ', '24h')),
                  value: '24',
                  groupValue: p.hourFormat,
                  onChanged: (v) {
                    if (v != null) {
                      p.setHourFormat(v);
                    }
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: Text(p.t('12 giờ', '12h')),
                  value: '12',
                  groupValue: p.hourFormat,
                  onChanged: (v) {
                    if (v != null) {
                      p.setHourFormat(v);
                    }
                  },
                ),
              ),
            ],
          ),
          const Divider(),
          Text(
            p.t('Ngôn ngữ / Language', 'Language'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Tiếng Việt'),
                  value: 'vi',
                  groupValue: p.language,
                  onChanged: (v) {
                    if (v != null) {
                      p.setLanguage(v);
                    }
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('English'),
                  value: 'en',
                  groupValue: p.language,
                  onChanged: (v) {
                    if (v != null) {
                      p.setLanguage(v);
                    }
                  },
                ),
              ),
            ],
          ),
          const Divider(),
          Text(
            p.t('Trạng thái', 'Status'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                p.isOnline ? Icons.wifi : Icons.wifi_off,
                color: p.isOnline ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                p.isOnline
                    ? p.t('Đang trực tuyến', 'Online')
                    : p.t('Đang offline', 'Offline'),
              ),
            ],
          ),
          if (p.usingCache && p.cacheTime != null) ...[
            const SizedBox(height: 8),
            Text(
              p.t(
                'Hiển thị dữ liệu cache lúc: ${p.cacheTime}',
                'Showing cached data at: ${p.cacheTime}',
              ),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}
