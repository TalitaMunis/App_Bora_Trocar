import 'package:flutter/material.dart';

/// Classe responsável por centralizar os temas do aplicativo.
class AppTheme {
  
  // 🎯 CORES ESTÁTICAS GLOBAIS
  // Definindo a cor primária (o verde da marca) para uso direto em widgets.
  static const Color primaryColor = Color(0xFF4CAF50); // Verde vibrante (Material Green 500)
  static const Color primaryLightColor = Color(0xFFE8F5E9); // Verde bem claro para indicadores
  
  static const Color dividerColor = Color(0xFFE0E0E0); // Cinza claro para divisores/bordas
  
  // --- TEMAS ---

  // Tema claro (Ajustado para o verde)
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    // 🎯 Mudar de azul para verde
    primarySwatch: Colors.green, 
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      // Mantém branco/preto conforme a tela principal
      backgroundColor: Colors.white, 
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: primaryColor,
    ),
    // Configurações para o Material 3
    useMaterial3: true,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.green,
    ).copyWith(
      primary: primaryColor,
      secondary: primaryColor, // Usar o verde como cor de destaque
      surface: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.black54),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
  );

  // Tema escuro (Mantido como estava, apenas atualizando o useMaterial3)
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blueGrey,
    scaffoldBackgroundColor: Colors.black,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
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

  // --- CORES DOS CHIPS (MANTIDAS) ---

  // Cor do chip de vencimento 'Vence hoje' (Alerta Crítico)
  static const Color alertCritical = Color.fromARGB(255, 255, 100, 100); 
  static const Color alertCriticalBackground = Color.fromARGB(255, 255, 230, 230);
  
  // Cor do chip de vencimento 'Vence amanhã' (Alerta Próximo)
  static const Color alertWarning = Color.fromARGB(255, 255, 165, 0); 
  static const Color alertWarningBackground = Color.fromARGB(255, 255, 240, 210);

  // Cor do chip de Proximidade (Neutro)
  static const Color proximityText = Color.fromARGB(255, 80, 80, 80);
  static const Color proximityBackground = Color.fromARGB(255, 235, 235, 235);

  // Cor do placeholder de imagem
  static const Color imagePlaceholder = Color.fromARGB(255, 210, 210, 210);
}