// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// đúng 100%
import 'package:weather_app/l10n/app_localizations.dart';

import 'config/api_config.dart';
import 'providers/weather_provider.dart';
import 'providers/locale_provider.dart';

import 'services/weather_service.dart';
import 'services/location_service.dart';
import 'services/storage_service.dart';

import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    ApiConfig.apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';

    if (ApiConfig.apiKey.isEmpty) {
      print("⚠️ WARNING: OPENWEATHER_API_KEY is empty! Check your .env file.");
    }
  } catch (e) {
    print("❌ Failed to load .env file: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WeatherProvider(
            WeatherService(apiKey: ApiConfig.apiKey),
            LocationService(),
            StorageService(),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => LocaleProvider(),
        ),
      ],

      child: Consumer<LocaleProvider>(
        builder: (context, localeProv, _) {
          return MaterialApp(
            title: 'Weather App',
            debugShowCheckedModeBanner: false,

            // đổi ngôn ngữ realtime
            locale: localeProv.locale,

            // hỗ trợ đa ngôn ngữ
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            supportedLocales: const [
              Locale('en'),
              Locale('vi'),
            ],

            theme: ThemeData(
              useMaterial3: true,
              fontFamily: "Roboto",

              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4A90E2),
                brightness: Brightness.light,
              ),

              // Sửa lỗi: dùng CardThemeData thay vì CardTheme
              cardTheme: CardThemeData(
                elevation: 4,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                surfaceTintColor: Colors.transparent,
              ),

              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 20),
                ),
              ),

              appBarTheme: const AppBarTheme(
                elevation: 0,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black,
                centerTitle: true,
              ),
            ),

            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
