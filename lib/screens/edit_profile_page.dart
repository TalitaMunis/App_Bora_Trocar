import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import '../services/user_service.dart';
import '../services/image_service.dart';
import 'dart:convert';
// ignore: unused_import
import 'dart:typed_data';

class EditProfilePage extends StatefulWidget {
  final User userToEdit;

  const EditProfilePage({super.key, required this.userToEdit});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // ✅ NOVO: Regex para telefone (Resolvendo Undefined name '_phoneRegex')
  final RegExp _phoneRegex = RegExp(r'^[0-9\-\s\(\)\+]+$');

  late final ImageService _imageService = ImageService();
  bool _isUploadingPhoto = false;

  // Controllers para pré-preencher e salvar dados
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;

  // URL da foto (agora armazena a string Base64)
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    final user = widget.userToEdit; // ✅ VARIÁVEL CORRIGIDA

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

  // 🎯 LÓGICA DE UPLOAD DE FOTO
  Future<void> _pickProfilePhoto() async {
    setState(() {
      _isUploadingPhoto = true;
    });

    try {
      final String? base64String = await _imageService.pickAndEncodeImage();

      if (!mounted) {
        return; // ✅ SEGURANÇA: Checa o contexto antes de usar setState
      }
      setState(() {
        _photoUrl = base64String;
        _isUploadingPhoto = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        // ✅ SEGURANÇA: Corrigindo 'BuildContext's across async gaps
        SnackBar(
          content: Text(
            base64String != null ? 'Foto selecionada!' : 'Seleção cancelada.',
          ),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar foto: $e')));
      setState(() {
        _isUploadingPhoto = false;
      });
    }
  }

  // 🎯 MÉTODO: Remover Foto
  void _removeProfilePhoto() {
    setState(() {
      _photoUrl = null;
    });
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

  // ✅ Widget auxiliar para foto com botão de edição (AGORA COM IMAGE.MEMORY)
  Widget _buildPhotoEditor() {
    // Lógica para decodificar a foto Base64
    final imageBytes = _photoUrl != null ? base64Decode(_photoUrl!) : null;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: AppTheme.imagePlaceholder,
          // ✅ Usa ImageProvider (MemoryImage) se houver bytes
          backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
          child: _isUploadingPhoto
              ? const CircularProgressIndicator(color: AppTheme.primaryColor)
              : imageBytes == null
              ? Icon(
                  Icons.person_outline,
                  size: 60,
                  color: Colors.grey.shade600,
                )
              : null,
        ),
        // Botão flutuante para editar a foto
        FloatingActionButton.small(
          onPressed: _isUploadingPhoto
              ? null
              : _pickProfilePhoto, // ✅ Chama a função de upload
          backgroundColor: AppTheme.primaryColor,
          child: Icon(
            _photoUrl != null ? Icons.edit : Icons.camera_alt,
            size: 20,
          ),
        ),
        // Botão para remover a foto
        if (_photoUrl != null && !_isUploadingPhoto)
          Positioned(
            bottom: 50,
            left: 70,
            child: GestureDetector(
              onTap: _removeProfilePhoto, // ✅ LIGADO CORRETAMENTE
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Colors.red.shade700,
                child: const Icon(Icons.close, size: 10, color: Colors.white),
              ),
            ),
          ),
      ],
    );
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
                  // ✅ Validação usando o _phoneRegex
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
              const SizedBox(height: 30),

              // --- Botão de Salvar ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isUploadingPhoto ? null : _saveProfile,
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
}
