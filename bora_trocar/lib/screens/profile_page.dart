import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Variáveis mockadas para simular os dados do usuário
// Em um app real, estes viriam de um modelo de dados ou de um serviço
const String _userName = "Maria da Silva";
const String _userPhone = "(35) 99876-5432";
const String _userCity = "Itajubá, MG";
const String _userEmail = "maria.silva@exemplo.com";
const String? _userPhotoUrl = null; // null para usar o placeholder

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // A tela de perfil usa um Scaffold simples, já que a AppBar e BottomNav
    // são gerenciadas pelo MainNavigationScreen.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // --- 1. FOTO DO PERFIL (Opcional, usando Placeholder) ---
          _buildProfilePhoto(_userPhotoUrl),
          const SizedBox(height: 16),

          // --- 2. NOME DO USUÁRIO ---
          Text(
            _userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),

          // --- 3. INFORMAÇÕES OBRIGATÓRIAS ---
          _buildInfoCard(
            context,
            title: 'Telefone (Obrigatório)',
            value: _userPhone,
            icon: Icons.phone_outlined,
          ),
          const SizedBox(height: 12),

          _buildInfoCard(
            context,
            title: 'Cidade (Obrigatório)',
            value: _userCity,
            icon: Icons.location_city_outlined,
          ),
          const SizedBox(height: 12),

          // --- 4. INFORMAÇÕES OPCIONAIS ---
          _buildInfoCard(
            context,
            title: 'Email (Opcional)',
            value: _userEmail,
            icon: Icons.email_outlined,
          ),
          const Divider(height: 40),

          // --- 5. BOTÃO DE EDIÇÃO ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // 💡 Implementação visual: Simular a navegação para a tela de edição
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navegando para a Tela de Edição de Perfil...')),
                );
                // Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfilePage()));
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar Perfil', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Botão de Sair (Prática comum)
          TextButton(
            onPressed: () {
              // Lógica de logout simulada
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saindo da conta...')),
              );
            }, 
            child: Text('Sair da Conta', style: TextStyle(color: Colors.red.shade700)),
          )
        ],
      ),
    );
  }

  // Widget auxiliar para renderizar a foto ou o placeholder
  Widget _buildProfilePhoto(String? url) {
    if (url != null && url.isNotEmpty) {
      // Se houver URL, exibe a imagem
      return CircleAvatar(
        radius: 60,
        backgroundImage: NetworkImage(url),
        backgroundColor: AppTheme.imagePlaceholder,
      );
    } else {
      // Caso contrário, exibe o placeholder com ícone
      return CircleAvatar(
        radius: 60,
        backgroundColor: AppTheme.imagePlaceholder,
        child: Icon(
          Icons.person_outline,
          size: 60,
          color: Colors.grey.shade600,
        ),
      );
    }
  }

  // Widget auxiliar para exibir cada informação do perfil
  Widget _buildInfoCard(BuildContext context, {required String title, required String value, required IconData icon}) {
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
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
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