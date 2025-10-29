import 'package:flutter/material.dart';
// Importa o modelo e a lista de dados mockados
import '../models/food_listing.dart'; 
// Importa o widget do card
import '../widgets/simple_listing_card.dart'; 
// Importa o tema para estilização da barra de busca
import '../theme/app_theme.dart'; 

// Esta é a tela Home (Feed de Anúncios)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos Column para colocar a Barra de Busca acima da Lista (Feed)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- 1. Campo de Busca (Implementado diretamente no body) ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10.0),
              // Usa a cor do divisor que definimos no AppTheme
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

        // --- 2. Feed de Anúncios (ListView) ---
        Expanded(
          child: ListView.builder(
            itemCount: mockListings.length,
            itemBuilder: (context, index) {
              final listing = mockListings[index];
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
          ),
        ),
      ],
    );
  }
}