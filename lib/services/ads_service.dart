import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/food_listing.dart';

class AdsService extends ChangeNotifier {
  late Box<FoodListing> _box;

  AdsService() {
    _box = Hive.box<FoodListing>('adsBox');
  }

  List<FoodListing> get _listings => _box.values.toList();
  int get _nextId => _listings.length + 1;

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
    if (_searchTerm.isEmpty) return _listings;

    final normalizedSearchTerm = _normalizeString(_searchTerm);

    return _listings.where((listing) {
      return _normalizeString(listing.title).contains(normalizedSearchTerm) ||
          _normalizeString(
            listing.description,
          ).contains(normalizedSearchTerm) ||
          _normalizeString(
            listing.statusProximidadeVencimento,
          ).contains(normalizedSearchTerm);
    }).toList();
  }

  List<FoodListing> get userListings {
    return _listings.where((l) => l.id % 2 != 0).toList();
  }

  // --- MÉTODOS CRUD ---

  /// Adiciona um novo anúncio (Criação)
  void addListing(FoodListing newListing) {
    final listingWithId = newListing.copyWith(id: _nextId);
    _box.put(listingWithId.id, listingWithId);
    notifyListeners();
  }

  /// Atualiza um anúncio existente (Atualização)
  void updateListing(FoodListing updatedListing) {
    _box.put(updatedListing.id, updatedListing);
    notifyListeners();
  }

  /// Remove um anúncio da lista (Exclusão)
  void deleteListing(int id) {
    _box.delete(id);
    notifyListeners();
  }
}
