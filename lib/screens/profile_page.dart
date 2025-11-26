// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'edit_profile_page.dart';
import 'login_signup_page.dart';
import 'dart:convert'; // necessário para base64Decode
import 'dart:typed_data'; // necessário para MemoryImage

// --- WIDGETS AUXILIARES ---

Widget _buildProfilePhoto(String? url) {
  ImageProvider? imageProvider;

  // 🎯 LÓGICA DE EXIBIÇÃO: Decodifica o Base64
  if (url != null && url.isNotEmpty && url != 'null') {
    // Checa se a URL não é nula/vazia/string 'null'
    try {
      final imageBytes = base64Decode(url);
      imageProvider = MemoryImage(
        imageBytes,
      ); // Usa MemoryImage para exibir bytes
    } catch (e) {
      imageProvider = null; // Falha na decodificação
    }
  }

  return CircleAvatar(
    radius: 60,
    backgroundColor: AppTheme.imagePlaceholder,
    backgroundImage: imageProvider, // Usa a foto decodificada
    child: imageProvider == null
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<UserService>(
        builder: (context, userService, child) {
          if (!userService.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          final currentUser = userService.currentUser;
          final theme = Theme.of(context);
          final isGuest = !userService.isUserLoggedIn;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // --- 1. FOTO DO PERFIL ---
                _buildProfilePhoto(
                  currentUser.photoUrl,
                ), // exibe foto decodificada em Base64 (se houver)
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
                          // MODO CONVIDADO
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const LoginSignupPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.person_add_alt_1),
                          label: const Text(
                            'ENTRAR / CADASTRA',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        )
                      : ElevatedButton.icon(
                          // MODO LOGADO (Editar)
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
                      // Captura o ScaffoldMessenger antes do await
                      final userServiceAction = Provider.of<UserService>(
                        context,
                        listen: false,
                      );
                      final messenger = ScaffoldMessenger.of(context);

                      await userServiceAction.logout();

                      // Use the captured messenger after the await (avoids using BuildContext across async gap)
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Saindo da conta...')),
                      );

                      // Nota: O redirecionamento é tratado pelo AuthWrapper
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
