import 'package:flutter/material.dart';
import '../models/user.dart';

// Dados iniciais do usuário (agora definidos aqui)
final User initialMockUser = User(
  id: 'user_123',
  name: "Maria da Silva",
  phone: "(35) 99876-5432",
  city: "Itajubá, MG",
  email: "maria.silva@exemplo.com",
  photoUrl: null,
);

/// Gerencia o estado do perfil do usuário logado.
class UserService extends ChangeNotifier {
  // O estado real é guardado internamente
  User _currentUser = initialMockUser;

  // Getter para acesso (Leitura)
  User get currentUser => _currentUser;

  // Método para Atualização (Escrita)
  void updateUser(User updatedUser) {
    _currentUser = updatedUser;
    notifyListeners(); // Avisa a ProfilePage para reconstruir
  }
}
