import 'package:bora_trocar/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:firebase_core/firebase_core.dart';

import 'theme/app_theme.dart';
import 'services/ads_service.dart';
import 'services/user_service.dart';

// Função para Inicializar o Firebase (Apenas mantida como mock)
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ MultiProvider injeta os dois serviços necessários
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdsService()),
        ChangeNotifierProvider(create: (_) => UserService()),
      ],
      child: MaterialApp(
        title: 'Bora Trocar!',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        //darkTheme: AppTheme.darkTheme,
        //themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}
