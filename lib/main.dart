import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'providers/location_provider.dart';
import 'providers/weather_provider.dart';
import 'screens/home_screen.dart';
import 'services/connectivity_service.dart';
import 'services/location_service.dart';
import 'services/storage_service.dart';
import 'services/weather_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WeatherProvider(
            WeatherService(),
            LocationService(),
            StorageService(),
            ConnectivityService(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationProvider(LocationService()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Weather App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          useMaterial3: false,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
