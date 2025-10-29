import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Necessário para formatar a data
import '../theme/app_theme.dart'; // Para cores consistentes

class NewAdPage extends StatefulWidget {
  const NewAdPage({super.key});

  @override
  State<NewAdPage> createState() => _NewAdPageState();
}

class _NewAdPageState extends State<NewAdPage> {
  // Chave global para validação do formulário
  final _formKey = GlobalKey<FormState>();

  // Variáveis de estado para simular os dados do formulário
  String _title = '';
  String? _description;
  String? _category;
  DateTime? _expiryDate;
  String _quantity = '';

  // Opções de categorias mockadas
  final List<String> _categories = const [
    'Grãos e Cereais',
    'Laticínios',
    'Frutas e Vegetais',
    'Pães e Massas',
    'Carnes e Proteínas',
    'Outros'
  ];

  // Função para abrir o seletor de data
  Future<void> _selectDate(BuildContext context) async {
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
              primary: AppTheme.primaryColor, // Cor primária do tema
              onPrimary: Colors.white, // Cor do texto no header
              onSurface: Colors.black, // Cor do texto no calendário
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
  
  // Função de simulação de salvamento
  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // ✅ CORREÇÃO APLICADA: Usando a variável _title para que o Analyzer a reconheça como "usada"
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Anúncio: "$_title" criado!\n'
          'Descrição: ${_description ?? 'Não Selecionada'} | Quantidade: $_quantity'
          // Poderíamos usar a descrição aqui, mas a mensagem ficaria longa.
        ),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
    // Navega de volta para a tela anterior
    Navigator.pop(context); 
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Novo Anúncio'),
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
              // --- 1. FOTO (Foto e Location) ---
              const Text('Foto e Localização', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // Botão para Upload de Foto (Placeholder Visual)
              _buildImageUploadPlaceholder(),
              const SizedBox(height: 16),

              // Localização Atual (RF01) - Simulado
              _buildInfoContainer(
                icon: Icons.location_on_outlined, 
                text: 'Localização: Rua Exemplo, 123',
                trailing: const Icon(Icons.edit, color: AppTheme.proximityText),
              ),
              const Divider(height: 30),

              // --- 2. DADOS DO ALIMENTO (Título, Descrição, Categoria) ---
              const Text('Dados do Alimento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // Título (RF01)
              TextFormField(
                decoration: const InputDecoration(labelText: 'Título do Alimento*'),
                maxLength: 50,
                onSaved: (value) => _title = value!,
                validator: (value) => value!.isEmpty ? 'O título é obrigatório.' : null,
              ),
              const SizedBox(height: 16),

              // Descrição (RF01)
              TextFormField(
                decoration: const InputDecoration(labelText: 'Descrição*'),
                maxLines: 3,
                onSaved: (value) => _description = value!,
                validator: (value) => value!.isEmpty ? 'A descrição é obrigatória.' : null,
              ),
              const SizedBox(height: 16),
              
              // Categoria (RF01)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Categoria*'),
                // ❌ CORREÇÃO: Removendo initialValue e usando value (DropdownButtonFormField usa 'value' ou 'initialValue' não ambos)
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
                decoration: const InputDecoration(labelText: 'Quantidade e Unidade (Ex: 500g, 3 caixas)*'),
                keyboardType: TextInputType.text,
                onSaved: (value) => _quantity = value!,
                validator: (value) => value!.isEmpty ? 'A quantidade é obrigatória.' : null,
              ),
              const Divider(height: 30),

              // --- 4. Botão de Salvar ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveForm,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Publicar Anúncio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
  // Pegamos a cor base (R=210, G=210, B=210) e definimos o Alpha em 127 (50%)
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