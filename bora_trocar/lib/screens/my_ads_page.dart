import 'package:flutter/material.dart';
// Importa o modelo e a lista de dados mockados
import '../models/food_listing.dart'; 
// Importa o widget do card (que usaremos aqui também)
import '../widgets/simple_listing_card.dart'; 

// Esta é a tela "Meus Anúncios" (RF03, RF04)
class MyAdsPage extends StatelessWidget {
  const MyAdsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 Para o objetivo de visualização, usaremos a lista mockada.
    // Em uma implementação real, aqui seria a lista filtrada apenas pelos anúncios do usuário.
    final List<FoodListing> userListings = mockListings; 

    if (userListings.isEmpty) {
      // Caso o usuário ainda não tenha anúncios
      return const Center(
        child: Text(
          'Você ainda não possui anúncios.\nClique no botão (+) para começar!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    // Exibe a lista de anúncios do usuário
    return ListView.builder(
      itemCount: userListings.length,
      itemBuilder: (context, index) {
        final listing = userListings[index];
        // Reutilizamos o SimpleListingCard
        return SimpleListingCard(
          listing: listing,
          // Implementação futura da navegação:
          // onTap: () {
          //   Navigator.of(context).push(MaterialPageRoute(
          //     builder: (ctx) => DetailScreen(listing: listing),
          //   ));
          // },
        );
      },
    );
  }
}