import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:provider/provider.dart'; 
import '../theme/app_theme.dart'; 
import '../services/ads_service.dart'; 
import '../models/food_listing.dart'; 

class NewAdPage extends StatefulWidget {
  // ✅ Construtor adaptado para receber um anúncio para edição
  final FoodListing? listingToEdit;

  const NewAdPage({super.key, this.listingToEdit});

  @override
  State<NewAdPage> createState() => _NewAdPageState();
}

class _NewAdPageState extends State<NewAdPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para preencher e gerenciar os TextFields
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;

  // Variáveis de estado
  String _title = '';
  String? _description;
  String? _category;
  DateTime? _expiryDate;
  String _quantity = '';
  
  // Opções de categorias mockadas
  final List<String> _categories = const [
    'Grãos e Cereais', 'Laticínios', 'Frutas e Vegetais', 
    'Pães e Massas', 'Carnes e Proteínas', 'Outros'
  ];

  @override
  void initState() {
    super.initState();
    final isEditing = widget.listingToEdit != null;
    final listing = widget.listingToEdit;
    
    // Define os valores iniciais, ou String vazia/null se for Criação
    final initialDescription = isEditing ? listing!.description : '';
    final initialQuantityMock = isEditing ? listing!.contactInfo : ''; 
    final initialCategoryMock = isEditing ? _categories[1] : null; // Mock para categoria: 'Laticínios'

    // ✅ Inicializa controllers
    _titleController = TextEditingController(text: isEditing ? listing!.title : '');
    _descriptionController = TextEditingController(text: initialDescription);
    _quantityController = TextEditingController(text: initialQuantityMock);

    // ✅ Inicializa variáveis de estado
    if (isEditing) {
      _title = listing!.title;
      _description = initialDescription;
      _category = initialCategoryMock;
      _expiryDate = listing.expiryDate;
      _quantity = initialQuantityMock;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    // ... (Função inalterada) ...
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Selecione a Data de Validade',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }
  
  void _saveForm() {
    // Valida todos os campos do formulário e verifica se data/categoria foram selecionados
    if (_formKey.currentState!.validate() && _expiryDate != null && _category != null) {
      _formKey.currentState!.save();
      
      final adsService = Provider.of<AdsService>(context, listen: false);
      final isEditing = widget.listingToEdit != null;

      // ⚠️ Mock de dados que não vêm do formulário, mas são obrigatórios no modelo:
      final statusProximidadeVencimento = isEditing ? widget.listingToEdit!.statusProximidadeVencimento : 'Novo anúncio!';
      final contactInfoMock = '5511999999999';

      // 1. Constrói o objeto (Novo ou Atualizado)
      final listingToSave = FoodListing(
        // Se for edição, mantém o ID original. Se for criação, usa ID 0 (o serviço gera o ID final).
        id: isEditing ? widget.listingToEdit!.id : 0, 
        title: _title,
        description: _description ?? '', // Força String
        expiryDate: _expiryDate!,
        statusProximidadeVencimento: statusProximidadeVencimento, 
        contactInfo: contactInfoMock,
        imageUrl: widget.listingToEdit?.imageUrl, // Mantém a URL se for edição
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

      // Navega de volta para a tela anterior
      Navigator.pop(context); 
    } else {
      // Feedback para campos faltando 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios.'),
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
        // Título dinâmico
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
              // --- FOTO e LOCALIZAÇÃO ---
              const Text('Foto e Localização', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildImageUploadPlaceholder(),
              const SizedBox(height: 16),
              _buildInfoContainer(
                icon: Icons.location_on_outlined, 
                text: 'Localização: Rua Exemplo, 123',
                trailing: const Icon(Icons.edit, color: AppTheme.proximityText),
              ),
              const Divider(height: 30),

              // --- 2. DADOS DO ALIMENTO ---
              const Text('Dados do Alimento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // Título (RF01)
              TextFormField(
                controller: _titleController, // ✅ Usando Controller
                decoration: const InputDecoration(labelText: 'Título do Alimento*'),
                maxLength: 50,
                onSaved: (value) => _title = value!,
                validator: (value) => value!.isEmpty ? 'O título é obrigatório.' : null,
              ),
              const SizedBox(height: 16),

              // Descrição (RF01)
              TextFormField(
                controller: _descriptionController, // ✅ Usando Controller
                decoration: const InputDecoration(labelText: 'Descrição*'),
                maxLines: 3,
                onSaved: (value) => _description = value, // Salva como String?
                validator: (value) => value!.isEmpty ? 'A descrição é obrigatória.' : null,
              ),
              const SizedBox(height: 16),
              
              // Categoria (RF01)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Categoria*'),
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
                validator: (value) => value == null ? 'Selecione uma categoria.' : null,
              ),
              const Divider(height: 30),

              // --- 3. VALIDADE E QUANTIDADE ---
              const Text('Validade e Quantidade', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              
              // Data de Validade (RF01)
              _buildDatePickerField(context),
              const SizedBox(height: 16),

              // Quantidade (RF01)
              TextFormField(
                controller: _quantityController, // ✅ Usando Controller
                decoration: const InputDecoration(labelText: 'Quantidade e Unidade (Ex: 500g, 3 caixas)*'),
                keyboardType: TextInputType.text,
                onSaved: (value) => _quantity = value!, // Salva como String
                validator: (value) => value!.isEmpty ? 'A quantidade é obrigatória.' : null,
              ),
              const Divider(height: 30),

              // --- 4. Botão de Salvar ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveForm,
                  icon: Icon(isEditing ? Icons.save : Icons.upload_file),
                  label: Text(isEditing ? 'Salvar Alterações' : 'Publicar Anúncio', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Widget auxiliar para o placeholder de upload de imagem (RF01)
Widget _buildImageUploadPlaceholder() {
  const Color placeholderWithOpacity = Color.fromARGB(127, 210, 210, 210);

  return Container(
    height: 150,
    width: double.infinity,
    decoration: BoxDecoration(
      color: placeholderWithOpacity, 
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppTheme.dividerColor, width: 2),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt_outlined, size: 40, color: Colors.grey.shade600),
        const SizedBox(height: 8),
        Text('Adicionar Foto', style: TextStyle(color: Colors.grey.shade700)),
      ],
    ),
  );
}
  
  // Widget auxiliar para campos de informação simulados
  Widget _buildInfoContainer({required IconData icon, required String text, Widget? trailing}) {
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
          _expiryDate == null
              ? 'Selecione a data'
              : DateFormat('dd/MM/yyyy').format(_expiryDate!),
          style: TextStyle(
            color: _expiryDate == null ? Colors.grey.shade600 : Colors.black87,
            fontWeight: _expiryDate == null ? FontWeight.normal : FontWeight.w500
          ),
        ),
      ),
    );
  }
}