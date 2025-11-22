import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/user_service.dart';
import 'edit_profile_page.dart';
import 'login_signup_page.dart'; // Importa Login Page para o modo Convidado

// --- WIDGETS AUXILIARES MOVIDOS PARA O ARQUIVO ---
Widget _buildProfilePhoto(String? url) {
  // Lógica para exibir a foto de perfil ou o placeholder
  return CircleAvatar(
    radius: 60,
    backgroundColor: AppTheme.imagePlaceholder,
    backgroundImage: url != null ? NetworkImage(url) : null,
    child: url == null
        ? Icon(Icons.person_outline, size: 60, color: Colors.grey.shade600)
        : null,
  );
}

Widget _buildInfoCard({
  required String title,
  required String value,
  required IconData icon,
}) {
  // Card reutilizável para exibir informações do perfil
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.proximityBackground,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.primaryColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
// --- FIM DOS WIDGETS AUXILIARES ---

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold com a AppBar (gerenciado pelo MainNavigationScreen)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      // O Consumer agora é o corpo do Scaffold
      body: Consumer<UserService>(
        builder: (context, userService, child) {
          // 🎯 1. TRATAMENTO DE LOADING: Mostra o loading enquanto o Hive inicializa
          if (!userService.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          // 2. Se estiver inicializado (já carregou do Hive), exibe o conteúdo
          final currentUser = userService.currentUser;
          final theme = Theme.of(context);
          final isGuest =
              !userService.isUserLoggedIn; // Checa se é usuário convidado

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // --- 1. FOTO DO PERFIL ---
                _buildProfilePhoto(currentUser.photoUrl),
                const SizedBox(height: 16),

                // --- 2. NOME DO USUÁRIO ---
                Text(
                  currentUser.name,
                  style: theme.textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // --- 3. INFORMAÇÕES ---
                _buildInfoCard(
                  title: 'Telefone (Obrigatório)',
                  value: currentUser.phone,
                  icon: Icons.phone_outlined,
                ),
                const SizedBox(height: 12),

                _buildInfoCard(
                  title: 'Cidade (Obrigatório)',
                  value: currentUser.city,
                  icon: Icons.location_city_outlined,
                ),
                const SizedBox(height: 12),

                _buildInfoCard(
                  title: 'Email (Opcional)',
                  value: currentUser.email ?? 'Não informado',
                  icon: Icons.email_outlined,
                ),
                const Divider(height: 40),

                // --- 5. BOTÃO PRINCIPAL: EDICÃO OU LOGIN ---
                SizedBox(
                  width: double.infinity,
                  child: isGuest
                      ? ElevatedButton.icon(
                          // MODO CONVIDADO: Botão de Login
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const LoginSignupPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.person_add_alt_1),
                          label: const Text(
                            'ENTRAR / CADASTRAR',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        )
                      : ElevatedButton.icon(
                          // MODO LOGADO: Botão de Edição
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) =>
                                    EditProfilePage(userToEdit: currentUser),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text(
                            'Editar Perfil',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                ),
                const SizedBox(height: 20),

                // --- BOTÃO DE SAIR (Apenas visível se estiver logado) ---
                if (!isGuest)
                  TextButton(
                    onPressed: () async {
                      // Capture messenger and service before awaiting to avoid
                      // using `context` across an async gap.
                      final messenger = ScaffoldMessenger.of(context);
                      final userServiceAction = Provider.of<UserService>(
                        context,
                        listen: false,
                      );

                      await userServiceAction.logout();
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Saindo da conta...')),
                      );
                    },
                    child: Text(
                      'Sair da Conta',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
