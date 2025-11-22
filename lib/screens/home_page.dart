import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ads_service.dart';
import '../widgets/simple_listing_card.dart';
import '../theme/app_theme.dart';
import 'detail_screen.dart';

// ✅ Alterado de StatelessWidget para StatefulWidget
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ✅ 1. Cria o Controller Apenas Uma Vez
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    // Inicializa o controller
    _searchController = TextEditingController();

    // 💡 IMPORTANTE: Adiciona um listener para atualizar o termo de busca no Provider.
    // Isso garante que o estado de busca e o TextField estejam sempre sincronizados.
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    // Acessa o AdsService e atualiza o termo de busca
    final adsService = Provider.of<AdsService>(context, listen: false);
    adsService.setSearchTerm(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos o Consumer para ouvir as mudanças na busca e na lista
    return Consumer<AdsService>(
      builder: (context, adsService, child) {
        // 🎯 2. TRATAMENTO DE LOADING
        if (!adsService.isInitialized) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }
        // Usar a lista filtrada
        final listings = adsService.filteredListings;

        // Sincroniza o texto do Controller com o estado do Provider APENAS SE
        // o texto for diferente (evita loop e problemas de direção).
        if (_searchController.text != adsService.searchTerm &&
            adsService.searchTerm.isNotEmpty) {
          // Define o texto sem mover o cursor para o final
          _searchController.text = adsService.searchTerm;
        } else if (adsService.searchTerm.isEmpty &&
            _searchController.text.isNotEmpty) {
          _searchController.text = '';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. Campo de Busca (CORRIGIDO E OTIMIZADO) ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: TextField(
                  // ✅ Usando o controller persistente
                  controller: _searchController,

                  // ✅ Força a direção do texto para LTR
                  textDirection: TextDirection.ltr,

                  // ❌ Removido o onChanged, pois o listener do controller faz o trabalho.
                  decoration: const InputDecoration(
                    hintText: 'Buscar alimentos/Localidade',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                  ),
                ),
              ),
            ),

            // --- 2. Feed de Anúncios (ListView Reativo e Filtrado) ---
            Expanded(
              child: listings.isEmpty
                  ? Center(
                      child: Text(
                        adsService.searchTerm.isEmpty
                            ? 'Nenhum anúncio disponível no momento.'
                            : 'Nenhum resultado encontrado para "${_searchController.text}".',
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
