// lib/models/users/pessoa.dart

import 'user_role.dart';
// Importamos as subclasses para conseguir criá-las
import 'admin.dart';
import 'gestor_frotas.dart';
import 'motorista.dart';

abstract class Pessoa {
  final String id;
  final String name;
  final String email;
  final String cpf;
  final String phone;
  final UserRole role;

  Pessoa({
    required this.id,
    required this.name,
    required this.email,
    required this.cpf,
    required this.phone,
    required this.role,
  });

  // Helpers para facilitar verificações no código
  bool get isAdmin => role == UserRole.admin;
  bool get isManager => role == UserRole.manager;
  bool get isDriver => role == UserRole.driver;

  // Factory inteligente que decide qual arquivo chamar
  factory Pessoa.fromJson(Map<String, dynamic> json) {
    String roleString = json['role'] ?? 'driver';

    switch (roleString) {
      case 'admin':
        return Admin.fromJson(json);
      case 'manager':
        return GestorFrotas.fromJson(json);
      case 'driver':
        return Motorista.fromJson(json);
      default:
        return Motorista.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();
}