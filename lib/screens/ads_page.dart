import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ads_service.dart';
import '../widgets/simple_listing_card.dart';
import 'detail_screen.dart';
import '../theme/app_theme.dart';
import 'new_ad_page.dart';

// Esta é a tela "Meus Anúncios" (RF03, RF04)
class AdsPage extends StatelessWidget {
  const AdsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Tela completa incluindo AppBar e FAB; corpo escuta o AdsService
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Anúncios'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Consumer<AdsService>(
        builder: (context, adsService, child) {
          // 🎯 1. TRATAMENTO DE LOADING (Se Hive não terminou de inicializar)
          if (!adsService.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }
          // Pega a lista filtrada de anúncios do usuário
          final userListings = adsService.userListings;

          if (userListings.isEmpty) {
            // Caso o usuário ainda não tenha anúncios (vazio)
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(30.0),
                child: Text(
                  'Você ainda não possui anúncios publicados.\nClique no botão (+) para começar!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            );
          }

          // Exibe a lista de anúncios do usuário
          return ListView.builder(
            itemCount: userListings.length,
            itemBuilder: (context, index) {
              final listing = userListings[index];

              return SimpleListingCard(
                listing: listing,
                // Implementação futura da navegação para edição/exclusão (RF03/RF04)
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => DetailScreen(
                        listing: listing,
                        isUserOwner: true, // O dono é 'true' nesta tela
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const NewAdPage()));
        },
      ),
    );
  }
}
