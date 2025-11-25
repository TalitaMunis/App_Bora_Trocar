import 'package:flutter/material.dart';
// 6. Importa todas as telas que irá gerenciar
import 'home_page.dart';
// A tela search_page.dart não é mais necessária (Busca está na Home)
// ✅ ATENÇÃO: Ajustado para usar AdsPage
import 'ads_page.dart';
import 'profile_page.dart';
// Importa o tema para customizações visuais
import '../theme/app_theme.dart';
// Importa NewAdPage para manter o link para o FAB futuro na tela AdsPage
import 'new_ad_page.dart';
import '../utils/auth_check.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // ✅ Agora o índice vai de 0 a 2 (Home, Anúncios, Perfil)
  int _selectedIndex = 0;

  // ✅ Lista APENAS das 3 telas que serão exibidas no corpo do Scaffold.
  static const List<Widget> _bodyScreens = <Widget>[
    HomePage(), // Índice 0: Home
    AdsPage(), // Índice 1: Anúncios
    ProfilePage(), // Índice 2: Perfil
  ];

  // A lógica de navegação agora é simples e direta
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Função auxiliar para verificar se o FAB deve ser exibido
  bool _shouldShowFab() {
    // 🎯 O FAB aparece na Home (0) E em Meus Anúncios (1)
    return _selectedIndex == 0 || _selectedIndex == 1;
  }

  // ✅ NOVO MÉTODO: Ação de voltar (muda para a Home)
  void _onBackTapped() {
    // Se não estiver na Home (índice 0), navega para a Home
    if (_selectedIndex != 0) {
      _onItemTapped(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verifica se a tela atual é a Home
    final bool isHomeScreen = _selectedIndex == 0;

    return Scaffold(
      // --- 1. AppBar (Ajustada para ter seta e não implicar volta) ---
      appBar: AppBar(
        title: const Text('Bora Trocar!'),
        centerTitle: true,
        backgroundColor:
            AppTheme.primaryColor, // Corrigi para usar a cor primária
        foregroundColor: Colors.white,
        elevation: 0,

        // 🎯 LÓGICA DO BOTÃO DE VOLTAR MANUAL
        leading: IconButton(
          icon: Icon(
            isHomeScreen
                ? Icons.home
                : Icons
                      .arrow_back, // Se for Home, pode ser um ícone de menu (opcional)
            color: Colors.white,
          ),
          onPressed: isHomeScreen
              ? null
              : _onBackTapped, // Se for Home, desativa (ou abre menu)
        ),

        // Remove a seta automática, já que estamos implementando a nossa
        automaticallyImplyLeading: false,
      ),

      // --- 2. Body ---
      body: _bodyScreens.elementAt(_selectedIndex),

      // --- 3. Floating Action Button (FAB) ---
      // ✅ CORREÇÃO: O FAB aparece se o índice for 0 (Home) OU 1 (Anúncios)
      floatingActionButton: _shouldShowFab()
          ? FloatingActionButton(
              onPressed: () {
                if (checkAuthAndNavigate(context)) {
                  // Abre a tela de criação do anúncio
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NewAdPage()),
                  );
                }
              },
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,

      // Ajusta o FAB para ficar na extremidade inferior direita
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // --- 4. BottomNavigationBar (3 destinos) ---
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        indicatorColor: AppTheme.primaryLightColor,
        backgroundColor: Colors.white,
        elevation: 1,

        destinations: const <NavigationDestination>[
          // 0. Home
          NavigationDestination(
            selectedIcon: Icon(Icons.home, color: AppTheme.primaryColor),
            icon: Icon(Icons.home_outlined, color: Colors.black54),
            label: 'Home',
          ),

          // 1. Anúncios
          NavigationDestination(
            selectedIcon: Icon(Icons.list_alt, color: AppTheme.primaryColor),
            icon: Icon(Icons.list_alt_outlined, color: Colors.black54),
            label: 'Meus Anúncios',
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
