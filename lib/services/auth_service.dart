import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/users/pessoa.dart';
import './token_storage.dart';
// lib/services/auth_service.dart

class AuthService {
  final String _baseUrl = "http://200.137.0.24:31628/auth"; // Removi a barra extra no final

  Future<Pessoa?> login(String cpf, String password) async {
  final url = Uri.parse('$_baseUrl/login');

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "cpf": cpf,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      String token = data['token'];

      // 🔥 SALVA O TOKEN AQUI
      await TokenStorage.saveToken(token);

      Map<String, dynamic> userJson = {
        "id": 0,
        "name": data['name'],
        "cpf": cpf,
        "role": (data['roles'] as List).first.toString(),
      };

      return Pessoa.fromJson(userJson);
    }

    return null;
  } catch (e) {
    print("Erro detalhado: $e");
    return null;
  }
}
}