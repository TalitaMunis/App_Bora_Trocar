import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import 'main_navigation_screen.dart';

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

    final prefs = await SharedPreferences.getInstance();
    bool hasSeenOnboarding = prefs.getBool('onboarding_complete') ?? false;

    if (!hasSeenOnboarding) {
      Navigator.pushReplacement(
        mounted
            ? context
            : throw Exception("Contexto não montado para navegação"),
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else {
      Navigator.pushReplacement(
        mounted
            ? context
            : throw Exception("Contexto não montado para navegação"),
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGO DO APP
            Image.asset("assets/icon/icon.png", width: 120, height: 120),

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
