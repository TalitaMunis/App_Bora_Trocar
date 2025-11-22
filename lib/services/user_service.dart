import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart'; // Importa o modelo User

// Dados iniciais (O ÚNICO USUÁRIO MOCK PERMANENTE É O CONVIDADO/GUEST)
final User initialGuestUser = User(
  id: 'guest',
  name: "Convidado",
  phone: "N/A",
  city: "N/A",
  password: "", // Senha vazia para convidado
  photoUrl: null,
);

const String userBoxName = 'usersBox';
const String userKey = 'profile';
const String registeredUsersBoxName =
    'registeredUsers'; // ✅ NOVA BOX para cadastros globais

class UserService extends ChangeNotifier {
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized; // Usado no AuthWrapper para loading

  late Box<User> _userBox;
  late Box<User>
  _registeredUsersBox; // ✅ Box que armazena todos os usuários cadastrados

  UserService() {
    _initHive();
  }

  Future<void> _initHive() async {
    // 1. Abre Boxes
    _userBox = await Hive.openBox<User>(userBoxName);
    _registeredUsersBox = await Hive.openBox<User>(registeredUsersBoxName);

    if (_userBox.isEmpty) {
      // Garante que o estado inicial é 'guest' (convidado)
      await _userBox.put(userKey, initialGuestUser);
    }

    _isInitialized = true;
    notifyListeners();
  }

  // ✅ Getter: Verifica se o usuário logado não é o 'guest'
  bool get isUserLoggedIn {
    if (!_isInitialized) return false;
    return _userBox.get(userKey)?.id != 'guest';
  }

  User get currentUser {
    if (!_isInitialized) {
      return initialGuestUser;
    }
    // Retorna o usuário logado persistido no Hive
    return _userBox.get(userKey)!;
  }

  // -------------------------------------------------------------
  // AUTENTICAÇÃO (VALORES PERSISTENTES)
  // -------------------------------------------------------------

  /// 🎯 Realiza o Cadastro de um novo usuário
  /// Retorna true se o cadastro foi bem-sucedido, false se o telefone já existe.
  Future<bool> signup(User newUser) async {
    // 1. Verifica se o telefone já existe
    if (_registeredUsersBox.values.any((user) => user.phone == newUser.phone)) {
      return false; // Usuário já existe
    }

    // 2. Salva o novo usuário na Box de usuários registrados (persistência)
    // Usamos o telefone como chave temporária na box de registrados
    await _registeredUsersBox.put(newUser.phone, newUser);

    // 3. Loga o novo usuário imediatamente (troca o 'guest' pelo usuário real)
    await updateUser(newUser);

    return true;
  }

  /// 🎯 Realiza o Login
  /// Retorna o objeto User se o login for bem-sucedido, null caso contrário.
  Future<User?> login(String phone, String password) async {
    // 1. Tenta encontrar o usuário pelo telefone (que é a chave que usamos)
    // Usamos firstWhere para simular a busca no banco
    final user = _registeredUsersBox.values.firstWhere(
      (u) => u.phone == phone,
      orElse: () =>
          initialGuestUser.copyWith(id: 'not_found'), // Usuário não encontrado
    );

    // 2. Verifica se encontrou e se a senha corresponde
    if (user.id != 'not_found' && user.password == password) {
      // Loga o usuário, atualizando o estado 'current_user'
      await updateUser(user);
      return user;
    }

    return null; // Falha no login (senha incorreta ou usuário inexistente)
  }

  // -------------------------------------------------------------
  // Persistência e Logout
  // -------------------------------------------------------------

  /// Atualiza o perfil logado na Box e notifica a UI
  Future<void> updateUser(User updatedUser) async {
    if (!_isInitialized) return;
    // Salva o novo perfil (logado ou editado)
    await _userBox.put(userKey, updatedUser);
    notifyListeners();
  }

  /// Logout: Coloca o usuário de volta no estado 'guest'
  Future<void> logout() async {
    if (!_isInitialized) return;
    await _userBox.put(userKey, initialGuestUser);
    notifyListeners();
  }
}
