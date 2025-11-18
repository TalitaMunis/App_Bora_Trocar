import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart'; // Importa o modelo User

// Dados iniciais (O ÚNICO USUÁRIO MOCK PERMANENTE É O CONVIDADO/GUEST)
final User initialGuestUser = User(
  id: 'guest', // ID fixo para status 'deslogado'
  name: "Convidado",
  phone: "N/A",
  city: "N/A",
  email: null,
  photoUrl: null,
);

const String userBoxName = 'usersBox';
const String userKey = 'profile'; // Chave única para o objeto User

class UserService extends ChangeNotifier {
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized; // Usado no AuthWrapper para loading

  late Box<User> _userBox;

  UserService() {
    _initUserBox();
  }

  Future<void> _initUserBox() async {
    // 1. Abre a Box
    _userBox = await Hive.openBox<User>(userBoxName);

    if (_userBox.isEmpty) {
      // Se a Box estiver vazia, salva APENAS o usuário convidado
      await _userBox.put(userKey, initialGuestUser);
    }

    _isInitialized = true;
    notifyListeners();
  }

  // ✅ Verifica se o usuário logado não é o 'guest'
  bool get isUserLoggedIn {
    if (!_isInitialized) return false;
    // O usuário é considerado logado se o ID for diferente de 'guest'
    return _userBox.get(userKey)?.id != 'guest';
  }

  // Retorna o objeto User atual (seja ele o logado ou o convidado)
  User get currentUser {
    if (!_isInitialized) {
      return initialGuestUser;
    }
    // O '!' é seguro, pois garantimos que a Box nunca está vazia no _initUserBox.
    return _userBox.get(userKey)!;
  }

  // Atualiza o perfil (usado no Login/Cadastro e na Edição)
  Future<void> updateUser(User updatedUser) async {
    if (!_isInitialized) return;
    await _userBox.put(userKey, updatedUser);
    notifyListeners();
  }

  // ✅ Logout: Coloca o usuário de volta no estado 'guest'
  Future<void> logout() async {
    if (!_isInitialized) return;
    await _userBox.put(userKey, initialGuestUser);
    notifyListeners();
  }
}
