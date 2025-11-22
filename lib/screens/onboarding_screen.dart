import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart'; // Para cores
//import 'login_signup_page.dart'; // Próximo destino
import 'main_navigation_screen.dart'; // Próximo destino atualizado

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Define o estado de bloqueio. True = Bloqueia na tela de permissão.
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Inicia a Onboarding. A permissão será checada/solicitada na última página.
  }

  // --------------------------------------------------
  // Lógica de Permissão e Navegação
  // --------------------------------------------------

  Future<void> _requestAndComplete() async {
    // 1. Simula a solicitação da permissão (Processo em um app real)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Simulando solicitação de permissão de localização...'),
      ),
    );

    // Simulação do tempo de processamento
    await Future.delayed(const Duration(milliseconds: 700));

    // 2. Concede a permissão (Simulação de sucesso)
    // Marca a Onboarding como completa
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    // 3. Navega para a próxima tela (Home)
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  // --------------------------------------------------
  // Builders de Páginas
  // --------------------------------------------------

  // Constrói o conteúdo da página de introdução
  Widget _buildIntroPage(BuildContext context) {
    return _buildPage(
      context: context,
      title: "Reduza o Desperdício.\nConecte-se!",
      description:
          "Anuncie alimentos perto do vencimento para troca ou doação no seu bairro. Sua localização é a chave para o sucesso!",
      buttonText: "Próximo",
      onPressed: () {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      },
    );
  }

  // Constrói a tela de bloqueio de permissão
  Widget _buildPermissionBlocker(BuildContext context) {
    return _buildPage(
      context: context,
      title: "Localização Obrigatória",
      description:
          "O 'Bora Trocar!' precisa da sua localização para exibir anúncios de alimentos próximos a você. Sem esta permissão, não podemos funcionar.",
      icon: Icons.location_on,
      buttonText: "CONCEDER PERMISSÃO",
      onPressed:
          _requestAndComplete, // Chama a função que simula a permissão e navega
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildIntroPage(context),
      _buildPermissionBlocker(context), // Segunda página é o bloqueador
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: pages,
              ),
            ),
            // Indicador de páginas (● ○)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 16,
                  ),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? AppTheme.primaryColor
                        : Colors.grey[400],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builder auxiliar genérico para as páginas
  Widget _buildPage({
    required BuildContext context,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
    IconData icon = Icons.food_bank_outlined, // Ícone padrão
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: AppTheme.primaryColor),
          const SizedBox(height: 48),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: onPressed,
              child: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
