import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/models/forecast_model.dart';
import 'package:weather_app/models/hourly_weather_model.dart';

void main() {
  group('WeatherService', () {
    test('currentByCity parses weather JSON correctly', () async {
      final sampleJson = {
        "coord": {"lon": 106.66, "lat": 10.82},
        "weather": [
          {
            "id": 800,
            "main": "Clear",
            "description": "clear sky",
            "icon": "01d",
          }
        ],
        "main": {
          "temp": 25.0,
          "feels_like": 26.0,
          "pressure": 1012,
          "humidity": 70,
        },
        "visibility": 10000,
        "wind": {"speed": 3.0, "deg": 120},
        "sys": {
          "country": "VN",
          "sunrise": 1702000000,
          "sunset": 1702040000,
        },
        "name": "Ho Chi Minh City",
      };

      final mockClient = MockClient((request) async {
        expect(request.url.path, contains('/weather'));
        return http.Response(
          jsonEncode(sampleJson),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = WeatherService(client: mockClient);

      final WeatherModel weather =
          await service.currentByCity('Ho Chi Minh City');

      expect(weather.city, 'Ho Chi Minh City');
      expect(weather.country, 'VN');
      expect(weather.temp, 25.0);
      expect(weather.description, 'clear sky');
      expect(weather.humidity, 70);
      expect(weather.pressure, 1012);
      expect(weather.visibility, 10000);
      expect(weather.windSpeed, 3.0);
      expect(weather.windDeg, 120);
    });

    test('currentByCoord parses weather JSON correctly', () async {
      final sampleJson = {
        "coord": {"lon": 105.0, "lat": 21.0},
        "weather": [
          {
            "id": 500,
            "main": "Rain",
            "description": "light rain",
            "icon": "10d",
          }
        ],
        "main": {
          "temp": 18.5,
          "feels_like": 18.0,
          "pressure": 1005,
          "humidity": 90,
        },
        "visibility": 6000,
        "wind": {"speed": 4.2, "deg": 200},
        "sys": {
          "country": "VN",
          "sunrise": 1702000000,
          "sunset": 1702040000,
        },
        "name": "Hanoi",
      };

      final mockClient = MockClient((request) async {
        expect(request.url.path, contains('/weather'));
        expect(request.url.queryParameters['lat'], isNotNull);
        expect(request.url.queryParameters['lon'], isNotNull);

        return http.Response(
          jsonEncode(sampleJson),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = WeatherService(client: mockClient);

      final WeatherModel weather = await service.currentByCoord(21.0, 105.0);

      expect(weather.city, 'Hanoi');
      expect(weather.country, 'VN');
      expect(weather.temp, 18.5);
      expect(weather.description, 'light rain');
    });

    test('currentByCity throws exception when API returns error', () async {
      final errorBody = {'cod': '404', 'message': 'city not found'};

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode(errorBody),
          404,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = WeatherService(client: mockClient);

      expect(
        () => service.currentByCity('InvalidCity'),
        throwsException,
      );
    });

    test('forecastDaily groups 3h records by date and computes min/max',
        () async {
      final sampleJson = {
        "list": [
          {
            "dt": 1733700000,
            "dt_txt": "2024-12-09 00:00:00",
            "main": {
              "temp": 24.0,
              "temp_min": 23.0,
              "temp_max": 25.0,
            },
            "weather": [
              {"icon": "01d", "description": "clear sky"}
            ],
          },
          {
            "dt": 1733710800,
            "dt_txt": "2024-12-09 03:00:00",
            "main": {
              "temp": 28.0,
              "temp_min": 27.0,
              "temp_max": 29.0,
            },
            "weather": [
              {"icon": "02d", "description": "few clouds"}
            ],
          },
          {
            "dt": 1733786400,
            "dt_txt": "2024-12-10 00:00:00",
            "main": {
              "temp": 26.0,
              "temp_min": 25.0,
              "temp_max": 30.0,
            },
            "weather": [
              {"icon": "10d", "description": "rain"}
            ],
          },
        ]
      };

      final mockClient = MockClient((request) async {
        expect(request.url.path, contains('/forecast'));
        return http.Response(
          jsonEncode(sampleJson),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = WeatherService(client: mockClient);

      final List<ForecastModel> result =
          await service.forecastDaily(10.0, 106.0);

      expect(result.length, 2);

      final first = result[0];
      final second = result[1];

      expect(first.date.year, 2024);
      expect(first.date.month, 12);
      expect(first.date.day, 9);

      expect(second.date.year, 2024);
      expect(second.date.month, 12);
      expect(second.date.day, 10);

      expect(first.minTemp, 23.0);
      expect(first.maxTemp, 29.0);

      expect(second.minTemp, 25.0);
      expect(second.maxTemp, 30.0);

      expect(first.icon, '01d');
      expect(first.description, 'clear sky');
      expect(second.icon, '10d');
      expect(second.description, 'rain');
    });

    test('forecastDaily skips days without temperature info', () async {
      final sampleJson = {
        "list": [
          {
            "dt": 1733700000,
            "dt_txt": "2024-12-09 00:00:00",
            "weather": [
              {"icon": "01d", "description": "clear sky"}
            ],
          },
          {
            "dt": 1733786400,
            "dt_txt": "2024-12-10 00:00:00",
            "main": {
              "temp": 26.0,
              "temp_min": 25.0,
              "temp_max": 30.0,
            },
            "weather": [
              {"icon": "10d", "description": "rain"}
            ],
          },
        ]
      };

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode(sampleJson),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = WeatherService(client: mockClient);

      final List<ForecastModel> result =
          await service.forecastDaily(10.0, 106.0);

      expect(result.length, 1);
      expect(result.first.date.day, 10);
    });

    test('forecastHourly returns first 8 records (~24h)', () async {
      final List<Map<String, dynamic>> list = [];
      final baseDt = 1733700000;

      for (int i = 0; i < 10; i++) {
        final hour = (i * 3).toString().padLeft(2, '0');

        list.add({
          "dt": baseDt + i * 3 * 3600,
          "dt_txt": "2024-12-09 $hour:00:00",
          "main": {
            "temp": 20.0 + i,
          },
          "weather": [
            {"icon": "0${i % 4}d"}
          ],
        });
      }

      final sampleJson = {"list": list};

      final mockClient = MockClient((request) async {
        expect(request.url.path, contains('/forecast'));
        return http.Response(
          jsonEncode(sampleJson),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = WeatherService(client: mockClient);

      final List<HourlyWeatherModel> result =
          await service.forecastHourly(10.0, 106.0);

      expect(result.length, 8);

      final first = result.first;
      expect(first.temp, 20.0);
      expect(first.time.year, 2024);
      expect(first.time.month, 12);
      expect(first.time.day, 9);
    });

    test('forecastHourly throws exception when API error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal error', 500);
      });

      final service = WeatherService(client: mockClient);

      expect(
        () => service.forecastHourly(10.0, 106.0),
        throwsException,
      );
    });
  });
}
