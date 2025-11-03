import 'package:flutter/foundation.dart';
import '../models/food_listing.dart';

/// Gerencia a lista de anúncios (FoodListing) e notifica os ouvintes (Widgets).
class AdsService extends ChangeNotifier {
  final List<FoodListing> _listings = [...mockListings];
  int _nextId = mockListings.length + 1;

  String _searchTerm = '';

  // Getter para o termo de busca atual
  String get searchTerm => _searchTerm;

  // Setter: Atualiza o termo de busca e notifica a UI
  void setSearchTerm(String term) {
    if (_searchTerm != term.toLowerCase()) {
      _searchTerm = term.toLowerCase();
      notifyListeners();
    }
  }

  // 🎯 NOVA FUNÇÃO: Remove acentos e caracteres especiais (Acento-Insensitive)
  String _normalizeString(String text) {
    // Converte para minúsculo e remove acentos comuns no português.
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[áàãâä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòõôö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c');
  }

  // --- GETTERS DE LISTAGEM ---

  /// Retorna a lista filtrada por termo de busca (Usado na HomePage).
  List<FoodListing> get filteredListings {
    if (_searchTerm.isEmpty) {
      return [..._listings];
    }

    // 1. Normaliza o termo de busca (para ser case e accent-insensitive)
    final normalizedSearchTerm = _normalizeString(_searchTerm);

    return _listings.where((listing) {
      // 2. Normaliza os dados do anúncio para a comparação
      final normalizedTitle = _normalizeString(listing.title);
      final normalizedDescription = _normalizeString(listing.description);
      final normalizedStatus = _normalizeString(
        listing.statusProximidadeVencimento,
      );

      // Filtra (agora sem se preocupar com acentos!)
      return normalizedTitle.contains(normalizedSearchTerm) ||
          normalizedDescription.contains(normalizedSearchTerm) ||
          normalizedStatus.contains(normalizedSearchTerm);
    }).toList();
  }

  /// Retorna os anúncios publicados pelo usuário atual (simulado) (Usado na AdsPage).
  List<FoodListing> get userListings {
    // ... (permanece inalterado) ...
    return _listings.where((listing) => listing.id % 2 != 0).toList();
  }

  // --- MÉTODOS CRUD ---

  /// Adiciona um novo anúncio (Criação)
  void addListing(FoodListing newListing) {
    // Cria uma nova instância com ID único
    final listingWithId = newListing.copyWith(id: _nextId++);
    _listings.add(listingWithId);

    notifyListeners();
  }

  /// Atualiza um anúncio existente (Atualização)
  void updateListing(FoodListing updatedListing) {
    final index = _listings.indexWhere((l) => l.id == updatedListing.id);

    if (index != -1) {
      _listings[index] = updatedListing;
      notifyListeners();
    }
  }

  /// Remove um anúncio da lista (Exclusão)
  void deleteListing(int id) {
    _listings.removeWhere((l) => l.id == id);
    notifyListeners();
  }
}
