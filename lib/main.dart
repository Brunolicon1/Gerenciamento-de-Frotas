import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // 1. Importe para carregar os símbolos locais
import 'feature/login-screen.dart';

void main() async {
  // 2. Garante que os bindings do Flutter estejam prontos
  WidgetsFlutterBinding.ensureInitialized();

    // 3. Inicializa a formatação para o padrão brasileiro
    await initializeDateFormatting('pt_BR', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Título geral da aplicação (visto no gerenciador de apps)
      title: 'Gestão de Frotas',

      locale: const Locale('pt', 'BR'),
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

