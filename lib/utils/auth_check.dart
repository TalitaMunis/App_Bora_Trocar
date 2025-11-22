import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import '../screens/login_signup_page.dart';

/// Função que verifica se o usuário está logado.
/// Se não estiver, redireciona para a tela de Login/Cadastro.
///
/// Retorna true se estiver logado, false se for redirecionado.
bool checkAuthAndNavigate(BuildContext context) {
  final userService = Provider.of<UserService>(context, listen: false);

  if (userService.isUserLoggedIn) {
    return true; // Usuário logado, pode prosseguir
  } else {
    // Redireciona para a tela de login
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LoginSignupPage()));
    // Feedback visual opcional
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Você precisa estar logado para realizar esta ação.'),
      ),
    );
    return false; // Redirecionado
  }
}
