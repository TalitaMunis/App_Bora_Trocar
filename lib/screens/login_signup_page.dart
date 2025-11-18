import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Adicionado para futura integração
import '../theme/app_theme.dart';
import '../services/user_service.dart'; // Adicionado para persistir o usuário
import '../models/user.dart'; // Adicionado para criar o objeto User
import 'main_navigation_screen.dart'; // Para navegação após login

class LoginSignupPage extends StatefulWidget {
  const LoginSignupPage({super.key});

  @override
  State<LoginSignupPage> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true; // Alterna entre Login e Cadastro

  // Variáveis do Formulário
  String _name = '';
  String _phone = '';
  String _city = '';
  String _email = '';
  String _password = ''; // Usada apenas para validação e simulação

  // Simulação de autenticação com dados persistidos em memória
  void _submitAuthForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final userService = Provider.of<UserService>(context, listen: false);

    // --- SIMULAÇÃO DE LOGIN/CADASTRO E PERSISTÊNCIA ---

    // 1. Cria um novo objeto User (no caso de Cadastro) ou pega o mock (no caso de Login)
    final String userIdMock = 'user_${_phone.hashCode}';

    User updatedUser;

    if (_isLogin) {
      // Mock: Se for login, apenas simula sucesso e carrega o usuário mockado
      // Em um app real, buscaríamos no banco e verificaríamos a senha.
      updatedUser = userService.currentUser.copyWith(id: userIdMock);
    } else {
      // Cadastro: Cria um novo objeto User com os dados do formulário
      updatedUser = User(
        id: userIdMock,
        name: _name,
        phone: _phone,
        city: _city,
        email: _email.isNotEmpty ? _email : null,
      );
    }

    // 2. Persiste o usuário no serviço (Entrega 3)
    userService.updateUser(updatedUser);

    // 3. Feedback visual (usando todos os campos para resolver os avisos)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isLogin
              // ✅ CORREÇÃO 1: Removida a barra invertida \
              ? 'Login Sucedido! Telefone: $_phone'
              : 'Cadastro Sucedido! Nome: $_name, Cidade: $_city, Senha (simulada): $_password, Email (opc): $_email',
        ), // ✅ CORREÇÃO 2: Usando _city, _email, _password
        backgroundColor: AppTheme.primaryColor,
      ),
    );

    // 4. Navega para a Home (substituindo a tela atual)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isLogin ? 'ENTRAR' : 'CADASTRE-SE'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                Text(
                  _isLogin ? 'Bem-vindo de volta!' : 'Crie sua conta',
                  style: theme.textTheme.headlineSmall!.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // --- CAMPOS DE CADASTRO (Apenas no modo Cadastro) ---
                if (!_isLogin) ...[
                  // Nome (Obrigatório)
                  TextFormField(
                    key: const ValueKey('name'),
                    decoration: const InputDecoration(
                      labelText: 'Nome Completo*',
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Nome é obrigatório.' : null,
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 15),

                  // Telefone (Obrigatório - Captura o telefone no modo Cadastro)
                  TextFormField(
                    key: const ValueKey('phone_cadastro'),
                    decoration: const InputDecoration(
                      labelText: 'Telefone (WhatsApp)*',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value!.isEmpty ? 'Telefone é obrigatório.' : null,
                    onSaved: (value) => _phone = value!,
                  ),
                  const SizedBox(height: 15),

                  // Cidade (Obrigatório)
                  TextFormField(
                    key: const ValueKey('city'),
                    decoration: const InputDecoration(labelText: 'Cidade/UF*'),
                    validator: (value) =>
                        value!.isEmpty ? 'Cidade é obrigatória.' : null,
                    onSaved: (value) => _city = value!,
                  ),
                  const SizedBox(height: 15),

                  // Email (Opcional)
                  TextFormField(
                    key: const ValueKey('email'),
                    decoration: const InputDecoration(
                      labelText: 'Email (Opcional)',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (value) => _email = value!,
                  ),
                  const SizedBox(height: 15),
                ],

                // --- CAMPO DE LOGIN (Telefone para Login ou Cadastro, se não foi preenchido acima) ---
                if (_isLogin)
                  TextFormField(
                    key: const ValueKey('auth_phone_login'),
                    decoration: const InputDecoration(
                      labelText: 'Telefone (Login)*',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value!.isEmpty ? 'Telefone é obrigatório.' : null,
                    onSaved: (value) => _phone = value!,
                  ),
                const SizedBox(height: 15),

                TextFormField(
                  key: const ValueKey('password'),
                  decoration: const InputDecoration(labelText: 'Senha*'),
                  obscureText: true,
                  validator: (value) => value!.length < 6
                      ? 'A senha deve ter pelo menos 6 caracteres.'
                      : null,
                  onSaved: (value) => _password = value!,
                ),
                const SizedBox(height: 30),

                // --- BOTÃO PRINCIPAL ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitAuthForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _isLogin ? 'ENTRAR' : 'CADASTRAR',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- ALTERNAR MODO ---
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(
                    _isLogin
                        ? 'Não tem conta? Crie aqui.'
                        : 'Já tem conta? Faça Login.',
                    style: TextStyle(color: theme.colorScheme.secondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
