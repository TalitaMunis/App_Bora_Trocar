import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'user.g.dart'; // ✅ Linha OBRIGATÓRIA

// ✅ HiveType: ID único (1)
@HiveType(typeId: 1)
class User {
  // Campos obrigatórios do perfil (RF)
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String phone;
  @HiveField(3)
  final String city;

  // Campos opcionais
  @HiveField(4)
  final String? email;
  @HiveField(5)
  final String? photoUrl;
  @HiveField(6)
  final String password; // ✅ NOVO: Senha para login

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.city,
    required this.password,
    this.email,
    this.photoUrl,
  });

  // Método copyWith
  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? city,
    String? password, // ✅ NOVO
    ValueGetter<String?>? email,
    ValueGetter<String?>? photoUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      password: password ?? this.password, // ✅ NOVO
      email: email != null ? email() : this.email,
      photoUrl: photoUrl != null ? photoUrl() : this.photoUrl,
    );
  }
}
