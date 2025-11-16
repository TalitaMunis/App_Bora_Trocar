import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/user_service.dart'; // Importa o serviço que contém o estado
import 'edit_profile_page.dart'; // Importa a tela de edição

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // O método build agora envolve a tela em um Consumer para reagir às mudanças do perfil
  @override
  Widget build(BuildContext context) {
    return Consumer<UserService>(
      // ✅ Escuta as mudanças no perfil
      builder: (context, userService, child) {
        final currentUser = userService.currentUser; // Obtém o estado atual
        final theme = Theme.of(context);

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
                currentUser.name, // Exibe o nome atualizado
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

              // --- 5. BOTÃO DE EDIÇÃO ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // ✅ Navega, passando o objeto User ATUALIZADO para a tela de edição
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ... (Botão Sair)
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saindo da conta...')),
                  );
                },
                child: Text(
                  'Sair da Conta',
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Widgets Auxiliares ---
  Widget _buildProfilePhoto(String? url) {
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
}
