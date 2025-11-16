import 'package:flutter/foundation.dart';

/// Modelo que representa o perfil do usuário no aplicativo.
class User {
  // Dados obrigatórios
  final String id;
  final String name;
  final String phone;
  final String city;

  // Dados opcionais
  final String? email;
  final String? photoUrl;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.city,
    this.email,
    this.photoUrl,
  });

  // Método copyWith para facilitar atualizações (necessário para o formulário de edição)
  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? city,
    ValueGetter<String?>? email,
    ValueGetter<String?>? photoUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      email: email != null ? email() : this.email,
      photoUrl: photoUrl != null ? photoUrl() : this.photoUrl,
    );
  }
}
