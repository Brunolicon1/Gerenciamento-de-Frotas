import 'package:extensao3/feature/registration-screen.dart';
import 'package:flutter/material.dart';
//import 'package:extensao3/screens/dashboard_screen.dart';
import 'package:extensao3/widgets/custom_app_bar.dart';
import 'package:extensao3/screens/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;

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

              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  hintText: 'exemplo@dominio.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  prefixIcon: Icon(Icons.email),
                ),
              ),

              const SizedBox(height: 16.0),

              TextField(
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24.0),

              SizedBox(
                width: double.infinity,
                height: 50.0,
                child: ElevatedButton(
                  onPressed: () {
                    print('Botão de Login pressionado!');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text('Entrar', style: TextStyle(fontSize: 18.0)),
                ),
              ),

              // Um espaço entre o botão "Entrar" e o link de cadastro
              const SizedBox(height: 16.0),

              TextButton(
                // --- PASSO 5: Navegação ---
                onPressed: () {
                  print('Navegando para a tela de Cadastro...');
                  // comando para abrir uma nova tela
                  Navigator.push(
                    context,
                    // MaterialPageRoute é a transição de tela padrão (desliza)
                    MaterialPageRoute(
                      builder: (context) => const RegistrationScreen(),
                    ),
                  );
                },

                // Estilização para parecer mais com um link de texto
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),

                // ---RichText para múltiplos estilos ---
                child: RichText(
                  text: TextSpan(
                    // Estilo padrão (para "Ainda não tem conta?")
                    style: TextStyle(
                      // Pega a cor de texto padrão do tema
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 14.0,
                    ),
                    children: <TextSpan>[
                      const TextSpan(text: 'Ainda não tem conta? '),

                      // Estilo do "link" (para "Cadastre-se")
                      TextSpan(
                        text: 'Cadastre-se',
                        style: TextStyle(
                          color: Colors.blueAccent, // Cor de destaque
                          fontWeight: FontWeight.bold, // Negrito
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
