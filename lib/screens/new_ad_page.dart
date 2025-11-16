import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../services/ads_service.dart';
import '../models/food_listing.dart';
import '../services/image_service.dart'; // ✅ ImageService importado

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
  late TextEditingController _quantityController;

  // Variáveis de estado do formulário
  String _title = '';
  String _description = '';
  String?
  _category; // Mantido anulável para permitir estado 'nenhum selecionado'
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 1));
  String _quantity = '';

  // ✅ ESTADO DA IMAGEM
  String? _selectedImageUrl;
  bool _isUploading = false;

  // Opções de categorias mockadas
  final List<String> _categories = const [
    'Grãos e Cereais',
    'Laticínios',
    'Frutas e Vegetais',
    'Pães e Massas',
    'Carnes e Proteínas',
    'Outros',
  ];

  @override
  void initState() {
    super.initState();
    final isEditing = widget.listingToEdit != null;
    final listing = widget.listingToEdit;

    // Define valores iniciais para edição
    if (isEditing) {
      _title = listing!.title;
      _description = listing.description;
      _quantity = listing.quantity;
      _expiryDate = listing.expiryDate;
      _selectedImageUrl = listing.imageUrl;
      // Mock da categoria: usa a primeira categoria (mock), garantindo que não é nula na edição
      _category = _categories[0];
    } else {
      // Garante que é null na criação, o que é o estado inicial correto para o Dropdown
      _category = null;
    }

    // Inicializa controllers com valores de edição ou String vazia
    _titleController = TextEditingController(text: _title);
    _descriptionController = TextEditingController(text: _description);
    _quantityController = TextEditingController(text: _quantity);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // --- Lógica de Imagem ---
  Future<void> _pickImage() async {
    setState(() {
      _isUploading = true;
    });
    try {
      final newUrl = await _imageService.pickAndUploadImage();
      setState(() {
        _selectedImageUrl = newUrl;
        _isUploading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar imagem: $e')),
        );
      }
      setState(() {
        _isUploading = false;
      });
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

  // --- Lógica de Formulário ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Selecione a Data de Validade',
    );
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate() && _category != null) {
      _formKey.currentState!.save();

      final adsService = Provider.of<AdsService>(context, listen: false);
      final isEditing = widget.listingToEdit != null;

      const contactInfoMock = '5511999999999';
      final statusProximidadeVencimento = isEditing
          ? widget.listingToEdit!.statusProximidadeVencimento
          : 'Novo anúncio!';

      final listingToSave = FoodListing(
        id: isEditing ? widget.listingToEdit!.id : 0,
        title: _title,
        description: _description,
        quantity: _quantity,
        expiryDate: _expiryDate,
        contactInfo: contactInfoMock,
        imageUrl: _selectedImageUrl,
        statusProximidadeVencimento: statusProximidadeVencimento,
      );

      if (isEditing) {
        adsService.updateListing(listingToSave);
      } else {
        adsService.addListing(listingToSave);
      }

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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, preencha todos os campos obrigatórios (incluindo Categoria).',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
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

              _buildImagePicker(), // Widget de Upload Integrado

              const SizedBox(height: 16),
              _buildInfoContainer(
                icon: Icons.location_on_outlined,
                text: 'Localização: Rua Exemplo, 123',
                trailing: const Icon(Icons.edit, color: AppTheme.proximityText),
              ),
              const Divider(height: 30),

              // --- 2. DADOS DO ALIMENTO ---
              const Text(
                'Dados do Alimento',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Título (RF01)
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título do Alimento*',
                ),
                maxLength: 50,
                onSaved: (value) => _title = value!,
                validator: (value) =>
                    value!.isEmpty ? 'O título é obrigatório.' : null,
              ),
              const SizedBox(height: 16),

              // Descrição (RF01)
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição*'),
                maxLines: 3,
                onSaved: (value) => _description = value!,
                validator: (value) =>
                    value!.isEmpty ? 'A descrição é obrigatória.' : null,
              ),
              const SizedBox(height: 16),

              // Categoria (RF01)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Categoria*'),
                initialValue:
                    _category, // ✅ Agora só usa 'value', que é o correto
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
                validator: (value) =>
                    value == null ? 'Selecione uma categoria.' : null,
              ),
              const Divider(height: 30),

              // --- 3. VALIDADE E QUANTIDADE ---
              const Text(
                'Validade e Quantidade',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Data de Validade (RF01)
              _buildDatePickerField(context),
              const SizedBox(height: 16),

              // Quantidade (RF01)
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantidade e Unidade (Ex: 500g, 3 caixas)*',
                ),
                keyboardType: TextInputType.text,
                onSaved: (value) => _quantity = value!,
                validator: (value) =>
                    value!.isEmpty ? 'A quantidade é obrigatória.' : null,
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

  // --- WIDGETS AUXILIARES ---

  // Widget Builder para o upload de imagem
  // Widget Builder para o upload de imagem
  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ✅ 1. Envolve o Container principal em um InkWell
        InkWell(
          // Aciona o seletor de imagem ao clicar no placeholder/imagem
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
                  ) // Loading
                : _selectedImageUrl != null
                ? Image.network(
                    _selectedImageUrl!,
                    fit: BoxFit.cover,
                    // Adiciona uma sobreposição sutil para indicar que é clicável
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: child);
                    },
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                : Center(
                    // Estado: Nenhuma imagem selecionada
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons
                              .add_photo_alternate_outlined, // 🎯 Ícone de adicionar foto
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

        // Botões de Ação
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Botão de REMOVER IMAGEM
            if (_selectedImageUrl != null)
              TextButton.icon(
                onPressed: _isUploading ? null : _removeImage,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(
                  'Remover',
                  style: TextStyle(color: Colors.red),
                ),
              ),

            const Spacer(),
          ],
        ),
      ],
    );
  }

  // Widget auxiliar para campos de informação simulados
  Widget _buildInfoContainer({
    required IconData icon,
    required String text,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.proximityBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.proximityText),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  // Widget auxiliar para o campo de seleção de data (RF01)
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
}
