// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/users/pessoa.dart';
import './token_storage.dart';

class AuthService {
  final String _baseUrl = "http://200.137.0.24:31628/auth";

  Future<Pessoa?> login(String cpf, String password) async {
    final url = Uri.parse('$_baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"cpf": cpf, "password": password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // 1. Extrai o Token e a primeira Role da lista enviada pela API
        String token = data['token'];
        String role = (data['roles'] as List).first.toString(); // Ex: 'FLEET_MANAGER'

        // 2. Salva o Token no Secure Storage
        await TokenStorage.saveToken(token);

      await TokenStorage.saveRole(role);

        // 4. Monta o objeto Pessoa para o restante do App
        Map<String, dynamic> userJson = {
          "id": 0, // Ajustar se a API enviar o ID real
          "name": data['name'],
          "cpf": cpf,
          "role": role,
        };

        return Pessoa.fromJson(userJson);
      }
      return null;
    } catch (e) {
      print("Erro no login: $e");
      return null;
    }
  }
}