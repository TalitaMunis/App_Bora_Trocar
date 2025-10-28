import 'package:flutter/material.dart';

// --- PONTO DE ENTRADA DO APP ---
// Este é o arquivo 'main.dart'
void main() {
  // NOTA: Aqui é onde inicializaríamos serviços como o Firebase
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  runApp(const MyApp());
}

// --- WIDGET RAIZ DO APP ---
// Corresponde ao 'app_widget.dart' na nossa estrutura.
// Configura o tema principal e o ponto de partida.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bora Trocar!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Este é o tema básico (RNF01)
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,

        // Define a aparência da barra de navegação
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Colors.green.shade100,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),

        // Tema do AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0.5,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // A 'home' do app é a tela que gerencia a navegação principal
      home: const MainNavigationScreen(),
    );
  }
}

// --- GERENCIADOR DE NAVEGAÇÃO (SHELL) ---
// Corresponde ao 'features/shell/view/main_navigation_shell.dart'
// Este widget controla a BottomNavigationBar e qual tela exibir.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0; // Controla qual tab está ativa

  // Lista de títulos para o AppBar
  static const List<String> _titles = <String>[
    'Bora Trocar!', // Home
    'Buscar', // Buscar
    'Anunciar', // Anunciar
    'Meus Anúncios', // Meus
    'Perfil', // Perfil
  ];

  // Lista das telas (Widgets) correspondentes a cada tab
  // Na estrutura final, importaríamos essas telas de seus arquivos
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(), // features/home_feed/view/home_feed_screen.dart
    SearchPage(), // features/search/view/search_screen.dart
    NewAdPage(), // features/ad_management/view/ad_form_screen.dart
    MyAdsPage(), // features/ad_management/view/my_ads_screen.dart
    ProfilePage(), // features/profile/view/profile_screen.dart
  ];

  void _onItemTapped(int index) {
    // A Tab "Anunciar" (índice 2) não deve trocar a tela,
    // mas sim abrir um modal ou nova página.
    if (index == 2) {
      // Por enquanto, vamos apenas navegar para a página
      // No futuro, isso poderia ser: context.push('/new-ad') com GoRouter
      // ou showModalBottomSheet(...)
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
      appBar: AppBar(title: Text(_titles.elementAt(_selectedIndex))),
      body: Center(
        // Exibe a tela selecionada
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // --- BARRA DE NAVEGAÇÃO INFERIOR ---
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const <NavigationDestination>[
          // Tab 1: Home (RF02)
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          // Tab 2: Buscar
          NavigationDestination(
            selectedIcon: Icon(Icons.search),
            icon: Icon(Icons.search_outlined),
            label: 'Buscar',
          ),
          // Tab 3: Anunciar (RF01) - Botão Centralizado
          NavigationDestination(
            selectedIcon: Icon(Icons.add_circle),
            icon: Icon(Icons.add_circle_outline),
            label: 'Anunciar',
          ),
          // Tab 4: Meus Anúncios (RF03, RF04)
          NavigationDestination(
            selectedIcon: Icon(Icons.list_alt),
            icon: Icon(Icons.list_alt_outlined),
            label: 'Meus',
          ),
          // Tab 5: Perfil
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

// --- TELAS PLACEHOLDER ---
// Estas são as telas "vazias" que serão preenchidas
// com o conteúdo de cada feature (RFs).

// Tela Home (RF02) - (image_ffae39.jpg)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Aqui entraria o feed de anúncios próximos
    return const Center(
      child: Text(
        'Tela Home (Feed)\nAqui aparecerão os anúncios (RF02)',
        textAlign: TextAlign.center,
      ),
    );
  }
}

// Tela de Busca
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Tela de Busca'));
  }
}

// Tela de Novo Anúncio (RF01) - (image_ffb176.jpg)
class NewAdPage extends StatelessWidget {
  const NewAdPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Esta tela (Formulário) seria aberta por cima (Modal ou Push)
    // Para simplificar, ela tem seu próprio Scaffold
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Novo Anúncio (RF01)')),
      body: const Center(child: Text('Aqui ficará o formulário do anúncio.')),
    );
  }
}

// Tela Meus Anúncios (RF03, RF04) - (image_ffb118.jpg)
class MyAdsPage extends StatelessWidget {
  const MyAdsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Aqui entraria a lista de anúncios do usuário
    return const Center(child: Text('Tela "Meus Anúncios" (RF03, RF04)'));
  }
}

// Tela de Perfil - (image_ffae6e.jpg)
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Aqui entrariam os dados do usuário
    return const Center(child: Text('Tela de Perfil'));
  }
}
