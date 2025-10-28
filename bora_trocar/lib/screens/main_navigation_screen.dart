import 'package:flutter/material.dart';
// 6. Importa todas as telas que irá gerenciar
import 'home_page.dart';
import 'search_page.dart';
import 'new_ad_page.dart';
import 'my_ads_page.dart';
import 'profile_page.dart';

// Este é o widget 'MainNavigationScreen' que era do main.dart
// Ele é um WIDGET, por isso o colocamos na pasta /widgets
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const List<String> _titles = <String>[
    'Bora Trocar!',
    'Buscar',
    'Anunciar', // Este título não será usado se o item 2 for um modal
    'Meus Anúncios',
    'Perfil',
  ];

  // 7. A lista de widgets agora aponta para as classes importadas
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    SearchPage(),
    NewAdPage(), // Placeholder, já que o item 2 é tratado no _onItemTapped
    MyAdsPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // Índice 2 é "Anunciar"
      // 8. O 'NewAdPage' é aberto como uma nova rota
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NewAdPage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // O título muda baseado na tab selecionada
        title: Text(_titles.elementAt(_selectedIndex)),
      ),
      // 9. O corpo exibe a tela da lista, exceto o item 2
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.search),
            icon: Icon(Icons.search_outlined),
            label: 'Buscar',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.add_circle),
            icon: Icon(Icons.add_circle_outline),
            label: 'Anunciar',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.list_alt),
            icon: Icon(Icons.list_alt_outlined),
            label: 'Meus',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outlined),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
