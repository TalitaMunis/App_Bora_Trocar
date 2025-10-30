// Arquivo: lib/models/food_listing.dart

import 'package:flutter/material.dart'; // Mantido caso necessário, mas não essencial aqui.

// Modelo para representar um anúncio de alimento
class FoodListing {
  final int id; // ✅ Mudança para int, facilitando o auto-incremento
  final String title; 
  final String? imageUrl; 
  final String statusProximidadeVencimento;
  
  final DateTime expiryDate; 
  final String description;
  final String contactInfo; 

  FoodListing({
    required this.id,
    required this.title,
    this.imageUrl, 
    required this.statusProximidadeVencimento,
    required this.expiryDate,
    required this.description,
    required this.contactInfo,
  });

  // 🎯 MÉTODO copyWith ADICIONADO
  FoodListing copyWith({
    int? id,
    String? title,
    ValueGetter<String?>? imageUrl, // Usamos ValueGetter para permitir passar null explicitamente
    String? statusProximidadeVencimento,
    DateTime? expiryDate,
    String? description,
    String? contactInfo,
  }) {
    return FoodListing(
      // Se o novo ID for passado, usa-o. Caso contrário, usa o ID existente (this.id).
      id: id ?? this.id, 
      title: title ?? this.title,
      // Se 'imageUrl' for passado como null, ValueGetter permite a substituição
      imageUrl: imageUrl != null ? imageUrl() : this.imageUrl, 
      statusProximidadeVencimento: statusProximidadeVencimento ?? this.statusProximidadeVencimento,
      expiryDate: expiryDate ?? this.expiryDate,
      description: description ?? this.description,
      contactInfo: contactInfo ?? this.contactInfo,
    );
  }
  
  // (Você pode manter o fromJson e toJson aqui, se os tiver implementado.)
}

// ⚠️ ATENÇÃO: É preciso atualizar a lista mockada para usar 'int' nos IDs.

// Lista de Mock de Anúncios para preencher a tela
final List<FoodListing> mockListings = [
  FoodListing(
    id: 1, // ID como INT
    title: 'Pão Integral', 
    imageUrl: null, 
    statusProximidadeVencimento: 'Vence amanhã',
    expiryDate: DateTime.now().add(const Duration(days: 1)),
    description: 'Pão de forma integral, pacote lacrado.',
    contactInfo: '5511987654321', 
  ),
  FoodListing(
    id: 2, // ID como INT
    title: 'Leite Desnatado', 
    imageUrl: null, 
    statusProximidadeVencimento: 'Vence hoje',
    expiryDate: DateTime.now(),
    description: 'Caixa de Leite Desnatado.',
    contactInfo: '5511987654321', 
  ),
  FoodListing(
    id: 3, // ID como INT
    title: 'Frango Assado', 
    imageUrl: null, 
    statusProximidadeVencimento: '500m de você',
    expiryDate: DateTime.now().add(const Duration(days: 5)),
    description: 'Metade de um frango assado.',
    contactInfo: '5511987654321',
  ),
  FoodListing(
    id: 4, // ID como INT
    title: 'Manga Tommy', 
    imageUrl: null, 
    statusProximidadeVencimento: '1.2km de você',
    expiryDate: DateTime.now().add(const Duration(days: 3)),
    description: 'Três mangas maduras.',
    contactInfo: '5511987654321',
  ),
];