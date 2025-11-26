import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ads_service.dart';
import '../widgets/simple_listing_card.dart';
import '../theme/app_theme.dart';
import 'detail_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TextEditingController _searchController;
  // Estado para armazenar a ordenação visualmente
  String _currentSortDisplay = 'Vencimento (Mais Próximo)';

  // Adiciona um FocusNode para controlar o foco do teclado
  final FocusNode _searchFocusNode = FocusNode();

  // Opções de Categorias Mockadas (Deve refletir as opções de cadastro)
  final List<String> _availableCategories = const [
    'Pães e Massas',
    'Laticínios',
    'Frutas e Vegetais',
    'Carnes e Proteínas',
    'Outros',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);

    // Inicializa o estado de ordenação visual com o valor atual do serviço
    final adsService = Provider.of<AdsService>(context, listen: false);
    _updateSortDisplay(adsService.currentSortBy, adsService.expiryDirection);
  }

  void _onSearchChanged() {
    final adsService = Provider.of<AdsService>(context, listen: false);
    adsService.setSearchTerm(_searchController.text);
  }

  // Ação ao clicar no ícone de busca
  void _onSearchIconTapped() {
    // 1. Garante que a busca seja acionada com o texto atual do campo
    _onSearchChanged();

    // 2. Remove o foco do campo para fechar o teclado, simulando a conclusão da pesquisa
    _searchFocusNode.unfocus();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose(); // libera o FocusNode
    super.dispose();
  }

  void _updateSortDisplay(String sortBy, String direction) {
    setState(() {
      final directionText = direction == 'asc'
          ? 'Mais Próximo'
          : 'Mais Distante';
      if (sortBy == 'expiry') {
        _currentSortDisplay = 'Vencimento ($directionText)';
      } else if (sortBy == 'proximity') {
        _currentSortDisplay =
            'Proximidade (${direction == 'asc' ? 'Mais Perto' : 'Mais Longe'})';
      }
    });
  }

  // Lógica do filtro avançado (modal)
  Future<void> _showFilterModal(
    BuildContext context,
    AdsService adsService,
  ) async {
    // Usa um StatefulWidget para o modal para gerenciar o estado temporário
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FilterModal(
        adsService: adsService,
        availableCategories: _availableCategories,
        // Passa o estado atual para o modal
        initialSortBy: adsService.currentSortBy,
        initialDirection: adsService.expiryDirection,
        initialSelectedCategories: adsService.selectedCategories,
      ),
    );

    if (result != null && result is Map) {
      // 1. Aplica as mudanças no serviço
      adsService.setSort(result['sortBy'], result['direction']);
      adsService.setCategoryFilter(result['categories']);

      // 2. Atualiza o indicador visual
      _updateSortDisplay(result['sortBy'], result['direction']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdsService>(
      builder: (context, adsService, child) {
        if (!adsService.isInitialized) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }

        final listings = adsService.filteredListings;

        // Sincroniza o texto do Controller
        if (_searchController.text != adsService.searchTerm &&
            adsService.searchTerm.isNotEmpty) {
          _searchController.text = adsService.searchTerm;
        } else if (adsService.searchTerm.isEmpty &&
            _searchController.text.isNotEmpty) {
          _searchController.text = '';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. BARRA DE BUSCA E FILTRO ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  // Campo de Busca
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: AppTheme.dividerColor),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode:
                            _searchFocusNode, // controla o foco do teclado
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                          hintText: 'Buscar alimentos/Localidade',
                          hintStyle: const TextStyle(color: Colors.grey),
                          // PrefixIcon como botão acionável de busca
                          prefixIcon: IconButton(
                            icon: const Icon(Icons.search, color: Colors.grey),
                            onPressed: _onSearchIconTapped,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // BOTÃO DE FILTRO AVANÇADO
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                      onPressed: () => _showFilterModal(context, adsService),
                    ),
                  ),
                ],
              ),
            ),

            // --- 2. INDICADOR DE ORDENAÇÃO E FILTROS ATIVOS ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: Text(
                'Ordenado por: $_currentSortDisplay${adsService.selectedCategories.isNotEmpty ? ' | Filtros: ${adsService.selectedCategories.length}' : ''}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),

            // --- 3. Feed de Anúncios ---
            Expanded(
              child: listings.isEmpty
                  ? Center(
                      child: Text(
                        adsService.searchTerm.isEmpty &&
                                adsService.selectedCategories.isEmpty
                            ? 'Nenhum anúncio disponível no momento.'
                            : 'Nenhum resultado encontrado.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: listings.length,
                      itemBuilder: (context, index) {
                        final listing = listings[index];
                        return SimpleListingCard(
                          listing: listing,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => DetailScreen(
                                  listing: listing,
                                  isUserOwner: false,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ----------------------------------------------------
// WIDGET DO MODAL DE FILTRO AVANÇADO
// ----------------------------------------------------

class FilterModal extends StatefulWidget {
  final AdsService adsService;
  final List<String> availableCategories;
  final String initialSortBy;
  final String initialDirection;
  final Set<String> initialSelectedCategories;

  const FilterModal({
    super.key,
    required this.adsService,
    required this.availableCategories,
    required this.initialSortBy,
    required this.initialDirection,
    required this.initialSelectedCategories,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late String _sortBy;
  late String _direction;
  late Set<String> _selectedCategories;

  @override
  void initState() {
    super.initState();
    _sortBy = widget.initialSortBy;
    _direction = widget.initialDirection;
    _selectedCategories = Set.from(widget.initialSelectedCategories);
  }

  void _applyFilters() {
    // Retorna os filtros selecionados para a HomePage
    Navigator.pop(context, {
      'sortBy': _sortBy,
      'direction': _direction,
      'categories': _selectedCategories,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // --- TÍTULO ---
          Text(
            'Filtros Avançados',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),

          // --- 1. ORDENAÇÃO PRINCIPAL ---
          Text(
            'Ordenar por',
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildSortChip('expiry', 'Vencimento'),
              const SizedBox(width: 8),
              _buildSortChip('proximity', 'Proximidade'),
            ],
          ),
          const Divider(height: 30),

          // --- 2. DIREÇÃO DA ORDENAÇÃO ---
          Text(
            'Direção',
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildDirectionChip(
                'asc',
                _sortBy == 'expiry' ? 'Mais Próximo' : 'Mais Perto',
              ),
              const SizedBox(width: 8),
              _buildDirectionChip(
                'desc',
                _sortBy == 'expiry' ? 'Mais Distante' : 'Mais Longe',
              ),
            ],
          ),
          const Divider(height: 30),

          // --- 3. FILTRAR POR CATEGORIA ---
          Text(
            'Filtrar por Categoria',
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8.0,
            children: widget.availableCategories.map((category) {
              return FilterChip(
                label: Text(category),
                selected: _selectedCategories.contains(category),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedCategories.add(category);
                    } else {
                      _selectedCategories.remove(category);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 30),

          // --- BOTÃO APLICAR ---
          ElevatedButton(
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text('Aplicar Filtros'),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String value, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _sortBy == value,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _sortBy = value;
          });
        }
      },
      selectedColor: AppTheme.primaryLightColor,
      labelStyle: TextStyle(
        color: _sortBy == value ? AppTheme.primaryColor : Colors.black87,
      ),
    );
  }

  Widget _buildDirectionChip(String value, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _direction == value,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _direction = value;
          });
        }
      },
      selectedColor: AppTheme.primaryLightColor,
      labelStyle: TextStyle(
        color: _direction == value ? AppTheme.primaryColor : Colors.black87,
      ),
    );
  }
}
