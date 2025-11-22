import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/food_listing.dart'; // Importa o modelo e a lista mockada

// Nome da Box (Tabela) para os anúncios
const String adsBoxName = 'adsBox';

class AdsService extends ChangeNotifier {
  late Box<FoodListing> _adsBox;

  List<FoodListing> _listings = [];
  bool _isInitialized = false;

  String _searchTerm = '';
  String get searchTerm => _searchTerm;
  bool get isInitialized => _isInitialized;

  AdsService() {
    _initHive();
  }

  // Lógica de Inicialização Assíncrona e Carregamento
  Future<void> _initHive() async {
    // 1. Abre a Box
    _adsBox = await Hive.openBox<FoodListing>(adsBoxName);

    // 2. Se a Box estiver vazia, preenche com os dados mockados
    if (_adsBox.isEmpty) {
      int nextId = 1;
      // ✅ Acesso à lista mockada para popular o Hive
      for (var listing in mockListings) {
        await _adsBox.put(nextId, listing.copyWith(id: nextId++));
      }
    }

    // 3. Adiciona um listener para a Box para reatividade
    _adsBox.listenable().addListener(_updateListingsFromHive);

    _updateListingsFromHive();
    _isInitialized = true;
    notifyListeners();
  }

  void _updateListingsFromHive() {
    _listings = _adsBox.values.toList();
    notifyListeners();
  }

  // ------------------ BUSCA ------------------
  void setSearchTerm(String term) {
    if (_searchTerm != term.toLowerCase()) {
      _searchTerm = term.toLowerCase();
      notifyListeners();
    }
  }

  String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[áàãâä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòõôö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c');
  }

  // ------------------ LISTAGEM ------------------
  List<FoodListing> get filteredListings {
    if (_searchTerm.isEmpty) return [..._listings];

    final term = _normalize(_searchTerm);

    return _listings.where((listing) {
      return _normalize(listing.title).contains(term) ||
          _normalize(listing.description).contains(term) ||
          _normalize(listing.statusProximidadeVencimento).contains(term);
    }).toList();
  }

  List<FoodListing> get userListings {
    return _listings.where((l) => l.isMockUserOwner).toList();
  }

  // ------------------ CRUD ------------------

  Future<void> addListing(FoodListing newListing) async {
    final newId = _adsBox.isEmpty
        ? 1
        : _adsBox.keys.cast<int>().reduce((a, b) => a > b ? a : b) + 1;
    final listingWithId = newListing.copyWith(id: newId);

    await _adsBox.put(listingWithId.id, listingWithId);
  }

  Future<void> updateListing(FoodListing listing) async {
    await _adsBox.put(listing.id, listing);
  }

  Future<void> deleteListing(int id) async {
    await _adsBox.delete(id);
  }
}
