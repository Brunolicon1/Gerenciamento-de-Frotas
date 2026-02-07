  import 'package:flutter/material.dart';
  import 'package:extensao3/feature/registration-screen.dart';
  import 'package:extensao3/screens/new_request_screen.dart';
  import 'package:extensao3/widgets/custom_app_bar.dart';
  import 'package:extensao3/screens/main_screen.dart';
  import 'package:extensao3/screens/driver_activies.dart';

  // Integração com a API e Modelos
  import 'package:extensao3/services/auth_service.dart';
  import '../models/users/user_role.dart';
  import '../models/users/pessoa.dart';

  class LoginScreen extends StatefulWidget {
    const LoginScreen({super.key});

    @override
    State<LoginScreen> createState() => _LoginScreenState();
  }

  class _LoginScreenState extends State<LoginScreen> {
    bool _isPasswordVisible = false;
    bool _isLoading = false; // Controle de feedback visual
    
    // Controllers atualizados para refletir o uso de CPF
    final _cpfController = TextEditingController(); 
    final _passwordController = TextEditingController();

    /// Função principal que orquestra o login via API
    Future<void> _handleLogin() async {
      final cpf = _cpfController.text.trim();
      final password = _passwordController.text.trim();

      if (cpf.isEmpty || password.isEmpty) {
        _showErrorSnackBar('Por favor, preencha todos os campos.');
        return;
      }

      setState(() => _isLoading = true);

      try {
        final authService = AuthService();
        // Chama a API real
        final Pessoa? usuario = await authService.login(cpf, password);

        if (!mounted) return;

        if (usuario != null) {
          // Lógica de Redirecionamento baseada no Role (Cargo) retornado pela API
          _redirectUser(usuario);
        } else {
          _showErrorSnackBar('CPF ou senha inválidos!');
        }
      } catch (e) {
        _showErrorSnackBar('Erro ao conectar com o servidor.');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }

    void _redirectUser(Pessoa user) {
      if (user.role == UserRole.DRIVER) {
        print("Motorista logado: Indo para Atividades");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DriverActivitiesScreen()),
        );
      } else if (user.role == UserRole.ADMIN || user.role == UserRole.FLEET_MANAGER) {
        print("Gestão/Admin logada: Indo para Dashboard");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        // Caso sua API retorne um role de solicitante/requester
        print("Solicitante logado: Indo para Nova Solicitação");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NewRequestScreen()),
        );
      }
    }

    void _showErrorSnackBar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: 'Gestão de Frotas - Login',
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 24.0),

                // Campo de CPF (Antigo E-mail)
                TextField(
                  controller: _cpfController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'CPF',
                    hintText: '111.222.333-44',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                ),

                const SizedBox(height: 16.0),

                // Campo de Senha
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _isPasswordVisible = !_isPasswordVisible);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 32.0),

                // Botão Entrar com estado de carregamento
                SizedBox(
                  width: double.infinity,
                  height: 50.0,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Entrar', style: TextStyle(fontSize: 18.0)),
                  ),
                ),

                const SizedBox(height: 16.0),

                // Link de Cadastro
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 14.0,
                      ),
                      children: const [
                        TextSpan(text: 'Ainda não tem conta? '),
                        TextSpan(
                          text: 'Cadastre-se',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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