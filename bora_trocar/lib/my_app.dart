import 'package:bora_trocar/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ Importar o Provider
//import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';
import 'services/ads_service.dart'; // ✅ Importar o serviço

/// Este é o widget raiz do aplicativo, chamado pelo main.dart.
/// Ele configura o MaterialApp, o tema e a rota inicial.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Envolve o MaterialApp com o Provider
    return ChangeNotifierProvider(
      // Cria uma única instância do AdsService no topo do widget tree
      create: (context) => AdsService(),
      child: MaterialApp(
        // O restante do seu MaterialApp
        title: 'Bora Trocar!',
        debugShowCheckedModeBanner: false,

        // Aplica o tema global que definimos em /theme/app_theme.dart
        theme: AppTheme.lightTheme,

        // Define a tela principal que será carregada.
        // Usamos nosso widget que gerencia a navegação por tabs.
        home: const SplashScreen(),
      ),
    );
  }
}
