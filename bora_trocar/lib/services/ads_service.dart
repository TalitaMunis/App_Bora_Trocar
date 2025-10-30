// Arquivo: lib/services/ads_service.dart

import 'package:flutter/foundation.dart';
import '../models/food_listing.dart'; // Importa o seu modelo de dados

/// Gerencia a lista de anúncios (FoodListing) e notifica os ouvintes (Widgets).
/// Esta classe é o nosso Repositório CRUD em Memória.
class AdsService extends ChangeNotifier {
  // Inicializa a lista de anúncios com os dados mockados
  final List<FoodListing> _listings = [...mockListings];
  
  // O ID que será usado para novos anúncios, garantindo que seja único
  // Começa após o maior ID da lista mockada.
  int _nextId = mockListings.length + 1; 

  /// Retorna a lista completa de anúncios (o C do CRUD)
  List<FoodListing> get listings {
    // Retorna uma cópia da lista para evitar modificações externas
    return [..._listings];
  }

  /// Retorna os anúncios publicados pelo usuário atual (simulado)
  List<FoodListing> get userListings {
    // Simula a filtragem. Em um app real, você filtraria por 'userId'.
    // Aqui, vamos simular que os itens ímpares são do usuário para fins de visualização.
    return _listings.where((listing) => listing.id % 2 != 0).toList();
  }

  // --- MÉTODOS CRUD ---

  /// Adiciona um novo anúncio (o C do CRUD)
  void addListing(FoodListing newListing) {
    // Cria uma nova instância com um ID único antes de adicionar
    final listingWithId = newListing.copyWith(id: _nextId++);
    _listings.add(listingWithId);
    
    // Notifica todos os widgets que estão ouvindo esta classe para que se atualizem
    notifyListeners();
  }

  /// Atualiza um anúncio existente (o U do CRUD)
  void updateListing(FoodListing updatedListing) {
    final index = _listings.indexWhere((l) => l.id == updatedListing.id);
    
    if (index != -1) {
      _listings[index] = updatedListing;
      notifyListeners();
    }
  }

  /// Remove um anúncio da lista (o D do CRUD)
  void deleteListing(int id) {
    _listings.removeWhere((l) => l.id == id);
    notifyListeners();
  }
}