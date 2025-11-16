import 'package:flutter/material.dart';

/// Classe responsável por centralizar os temas do aplicativo.
class AppTheme {
  // 🎯 CORES ESTÁTICAS GLOBAIS
  static const Color primaryColor = Color(
    0xFF4CAF50,
  ); // Verde vibrante (Material Green 500)
  static const Color primaryLightColor = Color(
    0xFFE8F5E9,
  ); // Verde bem claro para indicadores
  static const Color dividerColor = Color(
    0xFFE0E0E0,
  ); // Cinza claro para divisores/bordas

  // --- TEMAS ---

  // Tema claro (Ajustado para o verde)
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    iconTheme: const IconThemeData(color: Colors.black),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
    ),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: primaryColor),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ).copyWith(secondary: primaryColor, surface: Colors.white),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.black54),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
  );

  // Tema escuro
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Colors.blueGrey,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.black,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blueGrey,
      foregroundColor: Colors.white,
    ),
  );

  // --- CORES DOS CHIPS ---
  static const Color alertCritical = Color.fromARGB(255, 255, 100, 100);
  static const Color alertCriticalBackground = Color.fromARGB(
    255,
    255,
    230,
    230,
  );

  static const Color alertWarning = Color.fromARGB(255, 255, 165, 0);
  static const Color alertWarningBackground = Color.fromARGB(
    255,
    255,
    240,
    210,
  );

  static const Color proximityText = Color.fromARGB(255, 80, 80, 80);
  static const Color proximityBackground = Color.fromARGB(255, 235, 235, 235);

  static const Color imagePlaceholder = Color.fromARGB(255, 210, 210, 210);
}
