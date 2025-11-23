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
const String registeredUsersBoxName = 'registeredUsers';

class UserService extends ChangeNotifier {
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  late Box<User> _userBox;
  late Box<User> _registeredUsersBox;

  UserService() {
    _initHive();
  }

  Future<void> _initHive() async {
    // 1. ✅ Abre Boxes de forma persistente (aguarda o carregamento)
    _userBox = await Hive.openBox<User>(userBoxName);
    _registeredUsersBox = await Hive.openBox<User>(
      registeredUsersBoxName,
    ); // 🎯 ABERTURA CRÍTICA

    if (_userBox.isEmpty) {
      // Garante que o estado inicial é 'guest' (convidado)
      await _userBox.put(userKey, initialGuestUser);
    }

    _isInitialized = true;
    notifyListeners();
  }

  // LEITURA DE PERFIL POR ID (NOVO)
  // -------------------------------------------------------------

  /// 🎯 Busca um usuário cadastrado pelo seu ID (chave da Box).
  /// Retorna o User ou null se não encontrado.
  User? getUserById(String phoneKey) {
    // Usamos o telefone (que é a chave de persistência) como ID único
    return _registeredUsersBox.get(phoneKey);
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
  /// 🎯 Realiza o Cadastro de um novo usuário
  Future<bool> signup(User newUser) async {
    // 1. Verifica se o telefone já existe
    // ✅ CORREÇÃO: Busca por telefone na BOX de usuários registrados
    if (_registeredUsersBox.values.any((user) => user.phone == newUser.phone)) {
      return false; // Usuário já existe
    }

    // 2. Salva o novo usuário na Box de usuários registrados (a Box já foi aberta no _initHive)
    await _registeredUsersBox.put(
      newUser.phone,
      newUser,
    ); // ✅ Usa o telefone como chave

    // 3. Loga o novo usuário imediatamente
    await updateUser(newUser);

    return true;
  }

  /// 🎯 Realiza o Login
  Future<User?> login(String phone, String password) async {
    // 1. Tenta encontrar o usuário pelo telefone na BOX de usuários registrados
    // Usamos firstWhere para simular a busca no banco
    final user = _registeredUsersBox.values.firstWhere(
      (u) => u.phone == phone,
      orElse: () => initialGuestUser.copyWith(id: 'not_found'),
    );

    // 2. Verifica se encontrou e se a senha corresponde
    if (user.id != 'not_found' && user.password == password) {
      // Loga o usuário
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
