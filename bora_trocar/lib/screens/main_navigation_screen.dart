import 'package:flutter/material.dart';
// 6. Importa todas as telas que irá gerenciar
import 'home_page.dart';
// A tela search_page.dart não é mais necessária (Busca está na Home)
// A tela new_ad_page.dart será aberta via FloatingActionButton (FAB)
import 'my_ads_page.dart';
import 'profile_page.dart';
// Importa o tema para customizações visuais
import '../theme/app_theme.dart'; 
// Importa NewAdPage para manter o link para o FAB futuro na tela MyAdsPage
import 'new_ad_page.dart'; 

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // ✅ Agora o índice vai de 0 a 2 (Home, Meus, Perfil)
  int _selectedIndex = 0; 

  // ✅ Lista APENAS das 3 telas que serão exibidas no corpo do Scaffold.
  static const List<Widget> _bodyScreens = <Widget>[
    HomePage(),     // Índice 0: Home
    MyAdsPage(),    // Índice 1: Meus
    ProfilePage(),  // Índice 2: Perfil
  ];
  
  // A lógica de navegação agora é simples e direta
  void _onItemTapped(int index) {
    setState(() {
      // O índice da tab corresponde diretamente ao índice da tela
      _selectedIndex = index;
    });
    // Se, no futuro, quisermos manter o NewAdPage fora do FAB, 
    // ele voltaria a ser um item especial aqui.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- 1. AppBar ---
      appBar: AppBar(
        title: const Text('Bora Trocar!'), 
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      
      // --- 2. Body ---
      // ✅ Exibe a tela correspondente ao índice
      body: _bodyScreens.elementAt(_selectedIndex), 
      
      // --- 3. Floating Action Button (FAB) ---
      // 💡 Adicionado para sugerir a próxima etapa: o botão de ANUNCIAR
      floatingActionButton: _selectedIndex == 1 
          ? FloatingActionButton(
              onPressed: () {
                // Abre a tela de criação do anúncio
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NewAdPage()),
                );
              },
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null, // O FAB só aparece na tela "Meus Anúncios" (Índice 1)
      
      // Ajusta o FAB para ficar centralizado na coluna
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      
      // --- 4. BottomNavigationBar (3 destinos) ---
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        indicatorColor: AppTheme.primaryLightColor,
        backgroundColor: Colors.white,
        elevation: 1, 
        
        // ✅ Apenas 3 destinos agora
        destinations: const <NavigationDestination>[
          // 0. Home
          NavigationDestination(
            selectedIcon: Icon(Icons.home, color: AppTheme.primaryColor), 
            icon: Icon(Icons.home_outlined, color: Colors.black54),
            label: 'Home',
          ),
          
          // 1. Meus (Novo hub de gerenciamento e criação)
          NavigationDestination(
            selectedIcon: Icon(Icons.list_alt, color: AppTheme.primaryColor),
            icon: Icon(Icons.list_alt_outlined, color: Colors.black54),
            label: 'Meus',
          ),
          // 2. Perfil
          NavigationDestination(
            selectedIcon: Icon(Icons.person, color: AppTheme.primaryColor),
            icon: Icon(Icons.person_outlined, color: Colors.black54),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}