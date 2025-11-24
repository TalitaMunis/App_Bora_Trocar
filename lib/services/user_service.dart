import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';

// Dados iniciais (O ÚNICO USUÁRIO MOCK PERMANENTE É O CONVIDADO/GUEST)
final User initialGuestUser = User(
  id: 'guest',
  name: "Convidado",
  phone: "N/A",
  city: "N/A",
  password: "",
  photoUrl: null,
);

const String userBoxName = 'usersBox';
const String userKey = 'profile';
const String registeredUsersBoxName =
    'registeredUsers'; // Box que guarda TODOS os cadastros

class UserService extends ChangeNotifier {
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  late Box<User> _userBox;
  late Box<User>
  _registeredUsersBox; // Box que armazena todos os usuários cadastrados

  UserService() {
    _initHive();
  }

  Future<void> _initHive() async {
    // 1. Abre Boxes
    _userBox = await Hive.openBox<User>(userBoxName);
    _registeredUsersBox = await Hive.openBox<User>(registeredUsersBoxName);

    if (_userBox.isEmpty) {
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
    return _userBox.get(userKey)!;
  }

  // -------------------------------------------------------------
  // LEITURA DE PERFIL POR ID (CORRIGIDA)
  // -------------------------------------------------------------

  /// 🎯 Busca um usuário cadastrado pelo seu Telefone/Chave de Persistência.
  /// A chave de persistência é o número de telefone (User.phone).
  User? getUserById(String phoneKey) {
    // ✅ CORREÇÃO: Busca o usuário diretamente na Box de Registrados usando a chave
    return _registeredUsersBox.get(phoneKey);
  }

  // -------------------------------------------------------------
  // AUTENTICAÇÃO (MÉTODOS CUIDADOSAMENTE AJUSTADOS)
  // -------------------------------------------------------------

  /// 🎯 Realiza o Cadastro de um novo usuário
  Future<bool> signup(User newUser) async {
    // 1. Verifica se o telefone já existe
    if (_registeredUsersBox.values.any((user) => user.phone == newUser.phone)) {
      return false; // Usuário já existe
    }

    // 2. Salva o novo usuário na Box usando o TELEFONE como chave de persistência
    await _registeredUsersBox.put(newUser.phone, newUser);

    // 3. Loga o novo usuário imediatamente
    await updateUser(newUser);

    return true;
  }

  /// 🎯 Realiza o Login
  Future<User?> login(String phone, String password) async {
    // 1. Tenta encontrar o usuário pelo telefone (que é a chave que usamos)
    final user = _registeredUsersBox.get(phone);

    // 2. Verifica se encontrou e se a senha corresponde
    if (user != null && user.password == password) {
      // Loga o usuário
      await updateUser(user);
      return user;
    }

    return null; // Falha no login
  }

  // -------------------------------------------------------------
  // Persistência e Logout
  // -------------------------------------------------------------

  /// Atualiza o perfil logado na Box e notifica a UI
  Future<void> updateUser(User updatedUser) async {
    if (!_isInitialized) return;
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
