import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/users/pessoa.dart';
// lib/services/auth_service.dart

class AuthService {
  final String _baseUrl = "http://200.137.0.24:31628"; // Removi a barra extra no final

  Future<Pessoa?> login(String registration, String password) async {
    final url = Uri.parse('$_baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "registration": registration, // Alterado de 'cpf' para 'registration' conforme o SQL
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Pessoa.fromJson(data);
      }
      return null;
    } catch (e) {
      print("Erro ao conectar na API: $e");
      return null;
    }
  }
}