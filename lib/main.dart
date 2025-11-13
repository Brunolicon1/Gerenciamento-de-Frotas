import 'package:flutter/material.dart';

import 'feature/login-screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Título geral da aplicação (visto no gerenciador de apps)
      title: 'Gestão de Frotas',

      // Define o tema geral (cores, fontes)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),

      // 'home' define qual tela (Widget) será exibida
      // quando o app abrir.
      home: const LoginScreen(),

      // Remove a faixa de "DEBUG" no canto da tela
      debugShowCheckedModeBanner: false,
    );
  }
}

