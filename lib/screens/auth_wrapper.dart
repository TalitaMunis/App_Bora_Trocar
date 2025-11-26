import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import 'login_signup_page.dart';
import 'main_navigation_screen.dart';

/// Widget que decide se exibe a tela de login ou a tela principal.
///
/// Este é o roteador inicial que escuta o estado de autenticação (isUserLoggedIn)
/// e o estado de carregamento do Hive (isInitialized).
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta o UserService para mudanças no estado de login/carregamento
    return Consumer<UserService>(
      builder: (context, userService, child) {
        // 1. Mostrar Loading enquanto o Hive carrega e o estado inicial é definido
        if (!userService.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Mostrar Tela Principal se o usuário estiver logado
        if (userService.isUserLoggedIn) {
          return const MainNavigationScreen();
        }

        // 3. Mostrar Tela de Login/Cadastro se o usuário não estiver logado (ID == 'guest')
        return const LoginSignupPage();
      },
    );
  }
}
