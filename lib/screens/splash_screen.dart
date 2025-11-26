import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import 'auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Simula pequenas inicializações do app
    await Future.delayed(const Duration(seconds: 2));

    // Como o Hive faz a inicialização de forma assíncrona no Provider,
    // a SplashScreen só precisa checar a Onboarding (SharePrefs).

    final prefs = await SharedPreferences.getInstance();
    bool hasSeenOnboarding = prefs.getBool('onboarding_complete') ?? false;

    // 1. Define o destino
    Widget destination = hasSeenOnboarding
        ? const AuthWrapper() // ✅ Vai para o Wrapper que checa login
        : const OnboardingScreen(); // Vai para a Onboarding

    // 2. Navega
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGO DO APP (Assumindo que o asset está configurado)
            Image.asset(
              "assets/icon/icon.png",
              width: 120,
              height: 120,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.swap_horiz,
                size: 120,
                color: Color(0xFF4CAF50),
              ), // Fallback visual
            ),

            const SizedBox(height: 24),

            const Text(
              "Bora Trocar!",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 48),

            // LOADER
            const CircularProgressIndicator(strokeWidth: 3),
          ],
        ),
      ),
    );
  }
}
