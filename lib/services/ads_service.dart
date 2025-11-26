import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/food_listing.dart'; // Importa o modelo e a lista mockada

// Nome da Box (Tabela) para os anúncios
const String adsBoxName = 'adsBox';

class AdsService extends ChangeNotifier {
  late Box<FoodListing> _adsBox;

  // Lista em tempo de execução, carregada do Hive
  List<FoodListing> _listings = [];

  // Variável para rastrear o estado do carregamento (importante para a UI)
  bool _isInitialized = false;

  String _searchTerm = '';
  String _currentSortBy = 'expiry'; // Padrão: 'expiry' (vencimento)
  String _expiryDirection =
      'asc'; // 'asc' (mais próxima) ou 'desc' (mais distante)
  Set<String> _selectedCategories = {}; // Armazena categorias ativas

  String get searchTerm => _searchTerm;
  bool get isInitialized => _isInitialized;
  String get currentSortBy => _currentSortBy;
  String get expiryDirection => _expiryDirection;
  Set<String> get selectedCategories => _selectedCategories;

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
      // Acesso à lista mockada para popular o Hive
      for (var listing in mockListings) {
        await _adsBox.put(nextId, listing.copyWith(id: nextId++));
      }
    }

    // 3. Adiciona um listener para a Box para reatividade
    _adsBox.listenable().addListener(_updateListingsFromHive);

    // Carrega a lista inicial e marca como inicializada
    _updateListingsFromHive();
    _isInitialized = true;
    notifyListeners();
  }

  void _updateListingsFromHive() {
    // Carrega a lista do Hive (todos os valores)
    _listings = _adsBox.values.toList();
    notifyListeners();
  }

  // ------------------ BUSCA E FILTRO AVANÇADO ------------------

  void setSearchTerm(String term) {
    if (_searchTerm != term.toLowerCase()) {
      _searchTerm = term.toLowerCase();
      notifyListeners();
    }
  }

  // Define a ordenação principal e sua direção
  void setSort(String sortBy, String direction) {
    if (_currentSortBy != sortBy || _expiryDirection != direction) {
      _currentSortBy = sortBy;
      _expiryDirection = direction;
      notifyListeners();
    }
  }

  // Atualiza o filtro de categorias
  void setCategoryFilter(Set<String> categories) {
    if (_selectedCategories.length != categories.length ||
        !_selectedCategories.containsAll(categories)) {
      _selectedCategories = categories;
      notifyListeners();
    }
  }

  // Função auxiliar: remove acentos e caracteres especiais
  String _normalize(String? text) {
    final t = (text ?? '').toLowerCase();
    return t
        .replaceAll(RegExp(r'[áàãâä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòõôö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c');
  }

  /// Retorna a lista filtrada E ordenada.
  List<FoodListing> get filteredListings {
    // 1. Começa com uma cópia da lista completa
    List<FoodListing> results = [..._listings];

    // 2. Aplica o filtro de CATEGORIA
    if (_selectedCategories.isNotEmpty) {
      results = results.where((listing) {
        return _selectedCategories.any(
          (cat) => _normalize(listing.category).contains(_normalize(cat)),
        );
      }).toList();
    }

    // 3. Aplica o filtro de BUSCA (termo de pesquisa)
    final term = _normalize(_searchTerm);
    if (term.isNotEmpty) {
      results = results.where((listing) {
        return _normalize(listing.title).contains(term) ||
            _normalize(listing.description).contains(term) ||
            _normalize(listing.statusProximidadeVencimento).contains(term);
      }).toList();
    }

    // 4. Aplica a ordenação
    if (_currentSortBy == 'expiry') {
      // Ordena pela Data de Vencimento
      results.sort((a, b) {
        final comparison = a.expiryDate.compareTo(b.expiryDate);
        // Inverte a comparação se a direção for 'desc' (mais distante primeiro)
        return _expiryDirection == 'asc' ? comparison : -comparison;
      });
    } else if (_currentSortBy == 'proximity') {
      // Simulação de ordenação por proximidade
      results.sort((a, b) {
        // Mock: Usamos o ID como proxy para a proximidade
        final comparison = a.id.compareTo(b.id);
        // Inverte a comparação se a direção for 'desc' (mais longe primeiro)
        return _expiryDirection == 'asc' ? comparison : -comparison;
      });
    }

    return results;
  }

  // ------------------ LISTAGEM ESPECÍFICA ------------------
  List<FoodListing> get userListings {
    // Retorna apenas os anúncios que pertencem ao usuário (mock)
    return _listings.where((l) => l.isMockUserOwner).toList();
  }

  // ------------------ CRUD ------------------

  /// Cria um anúncio (persistência)
  Future<void> addListing(FoodListing newListing) async {
    // 1. Gera o próximo ID com base nas chaves do Hive
    final newId = _adsBox.isEmpty
        ? 1
        : _adsBox.keys.cast<int>().reduce((a, b) => a > b ? a : b) + 1;
    final listingWithId = newListing.copyWith(id: newId);

    // 2. Salva o objeto no Hive
    await _adsBox.put(listingWithId.id, listingWithId);
  }

  /// Atualiza um anúncio existente (Atualização)
  Future<void> updateListing(FoodListing listing) async {
    await _adsBox.put(listing.id, listing);
  }

  /// Remove um anúncio da lista (Exclusão)
  Future<void> deleteListing(int id) async {
    await _adsBox.delete(id);
  }
}
