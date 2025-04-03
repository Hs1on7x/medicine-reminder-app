import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = ThemeData(
    primaryColor: const Color(0xFF00BCD4),
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00BCD4)),
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Popins', // Arabic-friendly font
    textTheme: const TextTheme(
      // Define text styles with Arabic-friendly settings
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );

  ThemeData getTheme() => _themeData;

  void setTheme(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  // Toggle between light and dark themes
  void toggleTheme() {
    if (_themeData.brightness == Brightness.light) {
      _themeData = ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00BCD4),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00BCD4),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Popins',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      _themeData = ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF00BCD4),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00BCD4)),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Popins',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }
    notifyListeners();
  }
} 