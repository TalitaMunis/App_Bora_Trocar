import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/user_service.dart';
import '../models/user.dart';
import 'main_navigation_screen.dart';

class LoginSignupPage extends StatefulWidget {
  const LoginSignupPage({super.key});

  @override
  State<LoginSignupPage> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  bool _isLogin = true;

  // Variáveis do Formulário
  String _name = '';
  String _phone = '';
  String _city = '';
  String _password = '';

  // Regex para telefone: aceita apenas números, +, -, (, ) e espaço.
  final RegExp phoneRegex = RegExp(r'^[0-9\-\s\(\)\+]+$');

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  // Lógica de autenticação com persistência
  Future<void> _submitAuthForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final userService = Provider.of<UserService>(context, listen: false);
    ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    ScaffoldFeatureController? snackbarController;

    if (_isLogin) {
      // --- LÓGICA DE LOGIN REAL ---

      // 1. Chama o login no serviço para verificar a senha persistida
      final loggedInUser = await userService.login(_phone, _password);

      if (loggedInUser != null) {
        // Sucesso
        snackbarController = messenger.showSnackBar(
          const SnackBar(
            content: Text('Login Sucedido! Redirecionando...'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        await snackbarController.closed;

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      } else {
        // Falha: Senha ou telefone incorretos
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Falha no Login: Telefone ou senha incorretos.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // --- LÓGICA DE CADASTRO ---
      final newUser = User(
        id: 'user_${_phone.hashCode}', // ID de persistência
        name: _name,
        phone: _phone,
        city: _city,
        password: _password,
        photoUrl: null,
      );

      final success = await userService.signup(newUser);

      if (success) {
        // Sucesso: Redireciona
        snackbarController = messenger.showSnackBar(
          SnackBar(
            content: Text('Conta criada! Bem-vindo(a), $_name.'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        await snackbarController.closed;

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      } else {
        // Falha: Usuário já existe
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Falha no Cadastro: Telefone já cadastrado.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                Text(
                  _isLogin ? 'Bem-vindo de volta!' : 'Crie sua conta',
                  style: theme.textTheme.headlineSmall!.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // --- CAMPOS DE CADASTRO ---
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

                  // Cidade (Obrigatório) - Simula Localização Real (Editável)
                  TextFormField(
                    key: const ValueKey('city'),
                    initialValue: 'São Paulo, SP (Localização atual)',
                    decoration: const InputDecoration(
                      labelText: 'Cidade/UF* (Editável)',
                      suffixIcon: Icon(
                        Icons.location_on_outlined,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Cidade é obrigatória.';
                      }
                      return null;
                    },
                    onSaved: (value) => _city = value!,
                  ),
                  const SizedBox(height: 15),
                ],

                // --- TELEFONE (Login/Cadastro) ---
                TextFormField(
                  key: const ValueKey('phone_auth'),
                  decoration: const InputDecoration(
                    labelText: 'Telefone (Login/Cadastro)*',
                  ),
                  keyboardType: TextInputType.phone, // apenas para o teclado
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Telefone é obrigatório.';
                    }
                    // validação: verifica se contém apenas caracteres de telefone
                    if (!phoneRegex.hasMatch(value)) {
                      return 'Use apenas números, parênteses ou hífens.';
                    }
                    return null;
                  },
                  onSaved: (value) => _phone = value!,
                ),
                const SizedBox(height: 15),

                // --- SENHA ---
                TextFormField(
                  controller: _passwordController,
                  key: const ValueKey('password'),
                  decoration: const InputDecoration(labelText: 'Senha*'),
                  obscureText: true,
                  validator: (value) => value!.length < 6
                      ? 'A senha deve ter pelo menos 6 caracteres.'
                      : null,
                  onSaved: (value) => _password = value!,
                ),
                const SizedBox(height: 15),

                // --- CONFIRMAÇÃO DE SENHA (Apenas no modo Cadastro) ---
                if (!_isLogin)
                  TextFormField(
                    key: const ValueKey('confirm_password'),
                    decoration: const InputDecoration(
                      labelText: 'Confirme a Senha*',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Confirmação de senha é obrigatória.';
                      }
                      // Valida se as senhas coincidem
                      if (value != _passwordController.text) {
                        return 'As senhas não coincidem.';
                      }
                      return null;
                    },
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
