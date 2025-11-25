import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../services/ads_service.dart';
import '../models/food_listing.dart';
import '../services/image_service.dart';
import '../services/user_service.dart';
import 'package:intl/intl.dart'; // Mantido no arquivo
import 'dart:convert'; // Necessário para Base64

class NewAdPage extends StatefulWidget {
  final FoodListing? listingToEdit;

  const NewAdPage({super.key, this.listingToEdit});

  @override
  State<NewAdPage> createState() => _NewAdPageState();
}

class _NewAdPageState extends State<NewAdPage> {
  final _formKey = GlobalKey<FormState>();

  late final ImageService _imageService = ImageService();

  // Controllers para preencher e gerenciar os TextFields
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _quantityNumberController;
  late TextEditingController _locationController;

  // Variáveis de estado do formulário
  String _title = '';
  String _description = '';
  String? _category;
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 1));

  String _quantityNumber = '';
  String _quantityUnit = 'unidades';

  // Localização atual (inicial ou do listing em edição)
  String _currentLocation = 'Localização Padrão (GPS)';

  // Mocks de Localização e Contato
  final String _contactInfoMock = '5511999999999';

  // ESTADO DA IMAGEM
  String? _selectedImageUrl;
  bool _isUploading = false; // Removido 'final'

  // Opções de categorias mockadas
  final List<String> _categories = const [
    'Grãos e Cereais',
    'Laticínios',
    'Frutas e Vegetais',
    'Pães e Massas',
    'Carnes e Proteínas',
    'Outros',
  ];

  // Opções de Unidade
  final List<String> _units = const ['unidades', 'kg', 'gramas', 'litros'];

  @override
  void initState() {
    super.initState();
    final isEditing = widget.listingToEdit != null;
    final listing = widget.listingToEdit;

    // Divide a quantidade para edição (Ex: "2 pacotes" -> "2" e "pacotes")
    if (isEditing && listing!.quantity.isNotEmpty) {
      final parts = listing.quantity.split(' ');
      _quantityNumber = parts.isNotEmpty ? parts[0] : '';
      if (parts.length > 1) {
        _quantityUnit = parts[1].toLowerCase();
        if (!_units.contains(_quantityUnit)) {
          _quantityUnit = 'unidades';
        }
      }
    }

    // Define valores iniciais para edição
    if (isEditing) {
      _title = listing!.title;
      _description = listing.description;
      _expiryDate = listing.expiryDate;
      _selectedImageUrl = listing.imageUrl;
      _category = listing.category;
      _currentLocation = listing.location;
    }

    // Inicializa controllers
    _titleController = TextEditingController(text: _title);
    _descriptionController = TextEditingController(text: _description);
    _quantityNumberController = TextEditingController(text: _quantityNumber);
    _locationController = TextEditingController(text: _currentLocation);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _quantityNumberController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // LÓGICA DE IMAGEM
  // -------------------------------------------------------------------------

  Future<void> _pickImage() async {
    // Mark uploading state immediately (synchronous, safe)
    if (!mounted) return;
    setState(() {
      _isUploading = true;
    });

    try {
      final newUrl = await _imageService.pickAndEncodeImage();
      if (!mounted) return; // guard BuildContext/state after await
      setState(() {
        _selectedImageUrl = newUrl;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar imagem: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _removeImage() {
    if (_selectedImageUrl != null) {
      _imageService.removeImage(_selectedImageUrl!);
    }
    setState(() {
      _selectedImageUrl = null;
    });
  }

  // --- Lógica de Data (Função de Ação) ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Selecione a Data de Validade',
    );
    if (picked != null && picked != _expiryDate) {
      if (!mounted) return; // guard state/context after async gap
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  // Função auxiliar para calcular o status (para o construtor FoodListing)
  String computeStatusProximidade(DateTime expiry) {
    final diff = expiry.difference(DateTime.now()).inDays;
    if (diff < 0) return 'VENCIDO';
    if (diff == 0) return 'HOJE';
    if (diff <= 1) return 'AMANHA';
    return 'normal';
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, verifique os campos obrigatórios.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    _formKey.currentState!.save();

    // Validação Manual de Campos Críticos (TÍTULO e QUANTIDADE NUMÉRICA)
    if (_title.isEmpty || _quantityNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'O Título, Data de Validade e Quantidade são obrigatórios.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final adsService = Provider.of<AdsService>(context, listen: false);
    final userService = Provider.of<UserService>(context, listen: false);
    final isEditing = widget.listingToEdit != null;

    final creatorIdKey = userService.currentUser.phone;

    // Garante que a URL da imagem seja salva como string de placeholder se for nula
    final String finalImageUrl =
        _selectedImageUrl ??
        'https://placehold.co/60x60/CCCCCC/FFFFFF?text=FOTO';

    // 1. Constrói o objeto (Novo ou Atualizado)
    final listingToSave = FoodListing(
      id: isEditing ? widget.listingToEdit!.id : 0,
      title: _title,
      description: _description.isEmpty
          ? 'Nenhuma descrição fornecida.'
          : _description,
      quantity:
          '$_quantityNumber $_quantityUnit', // Salva a quantidade combinada
      expiryDate: _expiryDate,
      contactInfo: _contactInfoMock,
      imageUrl: finalImageUrl, // Salva a URL (Base64/Placeholder)
      isMockUserOwner: isEditing ? widget.listingToEdit!.isMockUserOwner : true,
      category: _category, // Salva a categoria (pode ser null)
      creatorUserId: isEditing
          ? widget.listingToEdit!.creatorUserId
          : creatorIdKey, // Salva o ID do criador
      statusProximidadeVencimento: computeStatusProximidade(_expiryDate),
      location: _locationController.text, // Salva a localização
    );

    // 2. Lógica de decisão: Edição ou Criação
    if (isEditing) {
      adsService.updateListing(listingToSave);
    } else {
      adsService.addListing(listingToSave);
    }

    // Feedback visual
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditing
              ? 'Anúncio: "$_title" atualizado com sucesso!'
              : 'Anúncio: "$_title" publicado com sucesso!',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
      ),
    );

    Navigator.pop(context);
  }

  // -------------------------------------------------------------------------
  // ✅ Widget auxiliar para o campo de seleção de data (RESOLVE PROBLEMA DE ESCOPO)
  // -------------------------------------------------------------------------
  Widget _buildDatePickerField(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Data de Validade*',
          suffixIcon: Icon(Icons.calendar_today),
        ),
        baseStyle: const TextStyle(fontSize: 16),
        child: Text(
          DateFormat('dd/MM/yyyy').format(_expiryDate),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // ✅ Widget Builder para o upload de imagem (RESOLVE PROBLEMA DE ESCOPO)
  // -------------------------------------------------------------------------
  Widget _buildImagePicker() {
    // Usamos Base64 decode para exibir a imagem real (se houver)
    final imageBytes = _selectedImageUrl != null
        ? base64Decode(_selectedImageUrl!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: _isUploading ? null : _pickImage,
          borderRadius: BorderRadius.circular(8),

          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            clipBehavior: Clip.antiAlias,
            child: _isUploading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  )
                : imageBytes != null
                ? Image.memory(
                    // 🎯 USA Image.memory para exibir a imagem real
                    imageBytes,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.red.shade600,
                      ),
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 40,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Clique para Adicionar Imagem',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Spacer(),
            if (_selectedImageUrl != null)
              TextButton.icon(
                onPressed: _isUploading ? null : _removeImage,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(
                  'Remover Imagem',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.listingToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Anúncio' : 'Criar Novo Anúncio'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // --- 1. FOTO e LOCALIZAÇÃO ---
              const Text(
                'Foto e Localização',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              _buildImagePicker(), // ✅ Chamada agora resolve o erro de escopo

              const SizedBox(height: 16),
              // Localização Editável
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Localização do Anúncio*',
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.gps_fixed,
                      color: AppTheme.primaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _locationController.text =
                            'Localização Atual (GPS Obtido)'; // Simula GPS
                      });
                    },
                  ),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'A localização é obrigatória.'
                    : null,
                onSaved: (value) =>
                    _currentLocation = value ?? _locationController.text,
              ),
              const Divider(height: 30),

              // --- 2. DADOS DO ALIMENTO ---
              const Text(
                'Dados do Alimento',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Título (RF01 - OBRIGATÓRIO)
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título do Alimento*',
                ),
                maxLength: 50,
                onSaved: (value) => _title = value ?? '',
                validator: (value) => (value == null || value.isEmpty)
                    ? 'O título é obrigatório.'
                    : null,
              ),
              const SizedBox(height: 16),

              // Descrição (NÃO OBRIGATÓRIO)
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (Opcional)',
                ),
                maxLines: 3,
                onSaved: (value) => _description = value!,
              ),
              const SizedBox(height: 16),

              // Categoria (NÃO OBRIGATÓRIO)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Categoria (Opcional)',
                ),
                initialValue: _category,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _category = newValue;
                  });
                },
                onSaved: (value) => _category = value,
                // VAZIO (null) é aceito
              ),
              const Divider(height: 30),

              // --- 3. VALIDADE E QUANTIDADE ---
              const Text(
                'Validade e Quantidade',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Data de Validade (OBRIGATÓRIO)
              _buildDatePickerField(
                context,
              ), // ✅ Chamada agora resolve o erro de escopo
              const SizedBox(height: 16),

              // Quantidade com Dropdown de Unidades
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Entrada Numérica
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade*',
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => _quantityNumber = value!,
                      validator: (value) {
                        if (value!.isEmpty) return 'O valor é obrigatório.';
                        if (double.tryParse(value) == null) {
                          return 'Apenas números são válidos.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 2. Dropdown de Unidade
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Unidade'),
                      initialValue: _quantityUnit,
                      items: _units.map((String unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _quantityUnit = newValue!;
                        });
                      },
                      onSaved: (value) => _quantityUnit = value!,
                    ),
                  ),
                ],
              ),
              const Divider(height: 30),

              // --- 4. Botão de Salvar ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _saveForm,
                  icon: Icon(isEditing ? Icons.save : Icons.upload_file),
                  label: Text(
                    isEditing ? 'Salvar Alterações' : 'Publicar Anúncio',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
            ],
          ),
        ),
      ),
    );
  }
}
