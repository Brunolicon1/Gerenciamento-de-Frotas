import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/users/pessoa.dart';
// lib/services/auth_service.dart

class AuthService {
  final String _baseUrl = "http://200.137.0.24:31628"; // Removi a barra extra no final

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
  
  // 1. Extrai o token se precisar salvar depois
  String token = data['token']; 

  // 2. Prepara os dados para a Factory Pessoa
  // Como o DTO envia uma lista de roles, pegamos o primeiro
  Map<String, dynamic> userJson = {
    "id": "0", // O DTO não envia ID, você pode colocar um placeholder
    "name": data['name'],
    "cpf": cpf, 
    "role": (data['roles'] as List).first.toString(), // Pega o primeiro cargo da lista
  };

  return Pessoa.fromJson(userJson);
}
    return null;
  } catch (e) {
    print("Erro detalhado: $e"); // Isso vai te mostrar se o erro é no JSON ou na Rede
    return null;
  }
}
}