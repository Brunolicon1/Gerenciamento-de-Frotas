// lib/widgets/custom_app_bar.dart

import 'package:flutter/material.dart';

// Nosso widget implementa PreferredSizeWidget para que possa ser usado
// na propriedade 'appBar' do Scaffold.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {

  // --- NOSSOS PARÂMETROS ---
  final String title; // O título que será exibido
  final List<Widget>? actions; // Lista opcional de botões (ex: Logout)
  final Widget? leading; // Widget opcional à esquerda (ex: botão Voltar)

  // O construtor recebe os parâmetros
  const CustomAppBar({
    super.key,
    required this.title, // O título é obrigatório
    this.actions, // 'actions' é opcional
    this.leading, // 'leading' é opcional
  });

  @override
  Widget build(BuildContext context) {
    // Retornamos a AppBar padrão do Flutter, mas agora
    // ela é alimentada pelos nossos parâmetros.
    return AppBar(
      title: Text(title),

      // Passamos os parâmetros recebidos para a AppBar real
      leading: leading,
      actions: actions,

      // Nosso estilo padrão
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
      elevation: 4.0, // Uma leve sombra
    );
  }

  // --- PARTE OBRIGATÓRIA do PreferredSizeWidget ---
  // Precisamos dizer ao Scaffold qual a altura que nossa AppBar terá.
  // kToolbarHeight é a altura padrão da AppBar no Flutter.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}