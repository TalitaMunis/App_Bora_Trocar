import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ Importar Provider
// Importa o serviço que contém os dados
import '../services/ads_service.dart'; 
// Importa o widget do card (que renderiza cada item)
import '../widgets/simple_listing_card.dart'; 
// Importa o tema para estilização da barra de busca
import '../theme/app_theme.dart'; 
// Importa a tela de detalhes (para navegação futura)
import 'detail_screen.dart'; 

// Esta é a tela Home (Feed de Anúncios)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos Column para colocar a Barra de Busca acima da Lista (Feed)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- 1. Campo de Busca ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: AppTheme.dividerColor), 
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Buscar alimentos/Localidade',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none, 
                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
        ),

        // --- 2. Feed de Anúncios (ListView Reativo) ---
        Expanded(
          // ✅ Consumer escuta as mudanças no AdsService
          child: Consumer<AdsService>(
            builder: (context, adsService, child) {
              final listings = adsService.listings; // A lista completa de anúncios
              
              if (listings.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhum anúncio disponível no momento.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              
              return ListView.builder(
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
                            isUserOwner: false, // O dono é 'false' no feed geral
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}