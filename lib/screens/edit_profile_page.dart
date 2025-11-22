import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import '../services/user_service.dart';

// O widget precisa ser StatefulWidget para gerenciar o estado do formulário
class EditProfilePage extends StatefulWidget {
  final User userToEdit;

  const EditProfilePage({super.key, required this.userToEdit});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // ✅ NOVO: Regex para telefone (igual ao usado no Login/Cadastro)
  final RegExp _phoneRegex = RegExp(r'^[0-9\-\s\(\)\+]+$');

  // Controllers para pré-preencher e salvar dados
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;

  // URL da foto (simulação)
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    final user = widget.userToEdit;

    // Inicializa controllers com os dados do usuário existente
    _nameController = TextEditingController(text: user.name);
    _phoneController = TextEditingController(text: user.phone);
    _cityController = TextEditingController(text: user.city);
    _photoUrl = user.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final userService = Provider.of<UserService>(context, listen: false);

      final updatedUser = widget.userToEdit.copyWith(
        name: _nameController.text,
        phone: _phoneController.text,
        city: _cityController.text,
        photoUrl: () => _photoUrl,
        password: widget.userToEdit.password,
      );

      userService.updateUser(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Perfil de ${updatedUser.name} salvo com sucesso!'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Placeholder de Foto para Edição
              _buildPhotoEditor(),
              const SizedBox(height: 30),

              // --- Nome (Obrigatório) ---
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome Completo*'),
                validator: (value) =>
                    value!.isEmpty ? 'O nome é obrigatório.' : null,
              ),
              const SizedBox(height: 15),

              // --- Telefone (Obrigatório) ---
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone (WhatsApp)*',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.isEmpty) return 'O telefone é obrigatório.';
                  // ✅ CORREÇÃO: Aplica o regex de validação
                  if (!_phoneRegex.hasMatch(value)) {
                    return 'Use apenas números, parênteses ou hífens.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // --- Cidade (Obrigatório) ---
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'Cidade/UF*'),
                validator: (value) =>
                    value!.isEmpty ? 'A cidade é obrigatória.' : null,
              ),
              const SizedBox(height: 15),

              // ... (Botões de Salvar, etc.)
              const SizedBox(height: 30),

              // --- Botão de Salvar ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'SALVAR ALTERAÇÕES',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para foto com botão de edição
  Widget _buildPhotoEditor() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: AppTheme.imagePlaceholder,
          backgroundImage: _photoUrl != null ? NetworkImage(_photoUrl!) : null,
          child: _photoUrl == null
              ? Icon(
                  Icons.person_outline,
                  size: 60,
                  color: Colors.grey.shade600,
                )
              : null,
        ),
        // Botão flutuante para editar a foto
        FloatingActionButton.small(
          onPressed: () {
            // 💡 Simular a troca/upload de foto
            setState(() {
              _photoUrl =
                  'https://placehold.co/120x120/4CAF50/FFFFFF?text=EDITADA';
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Simulando upload de nova foto...')),
            );
          },
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.camera_alt, size: 20),
        ),
      ],
    );
  }
}
