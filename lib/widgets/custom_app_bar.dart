import 'package:flutter/material.dart';
import 'package:extensao3/feature/login-screen.dart'; // Necessário para navegar de volta
import 'package:extensao3/data/mock_database.dart';   // Para limpar o usuário logado

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  // Removemos o 'actions' daqui. Não pedimos mais isso para quem chama.

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: leading,

      // CONFIGURAÇÃO FIXA DE ESTILO
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
      elevation: 4.0,

      // AQUI ESTÁ A MUDANÇA: O botão agora é fixo da barra
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Sair do Sistema',
          onPressed: () {
            _handleLogout(context);
          },
        ),
      ],
    );
  }

  // Função privada para organizar a lógica de sair
  void _handleLogout(BuildContext context) {
    // 1. Limpa os dados do usuário no nosso Mock
    MockDatabase.logout();

    // 2. Redireciona para o Login (removendo o histórico de volta)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false, // Remove todas as rotas anteriores da pilha
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}