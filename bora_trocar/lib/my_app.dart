import 'package:bora_trocar/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'theme/app_theme.dart'; // Importa as definições do tema

/// Este é o widget raiz do aplicativo, chamado pelo main.dart.
/// Ele configura o MaterialApp, o tema e a rota inicial.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Título do app (visto no gerenciador de tarefas do celular)
      title: 'Bora Trocar!',

      // Remove a faixa "DEBUG"
      debugShowCheckedModeBanner: false,

      // Aplica o tema global que definimos em /theme/app_theme.dart
      theme: AppTheme.lightTheme,

      // Define a tela principal que será carregada.
      // Usamos nosso widget que gerencia a navegação por tabs.
      home: const SplashScreen(),
    );
  }
}
