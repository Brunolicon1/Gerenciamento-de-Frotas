// lib/models/users/pessoa.dart

import 'user_role.dart';
// Importamos as subclasses para conseguir criá-las
import 'admin.dart';
import 'gestor_frotas.dart';
import 'motorista.dart';
import 'solicitante.dart';

abstract class Pessoa {
  final int id;
  final String name;
  final String cpf;
  final UserRole role;

  Pessoa({
    required this.id,
    required this.name,
    required this.cpf,
    required this.role,
  });

  // Helpers para facilitar verificações no código
  bool get isAdmin => role == UserRole.ADMIN;
  bool get isManager => role == UserRole.FLEET_MANAGER;
  bool get isDriver => role == UserRole.DRIVER;
  bool get isSolicitante => role == UserRole.REQUESTER;

  // Factory inteligente que decide qual arquivo chamar
factory Pessoa.fromJson(Map<String, dynamic> json) {
  // A API deve retornar o campo 'role' baseado na tabela user_roles
  String roleString = json['role'] ?? 'REQUESTER';

  switch (roleString) {
    case 'ADMIN':
      return Admin.fromJson(json);
    case 'FLEET_MANAGER':
      return GestorFrotas.fromJson(json);
    case 'DRIVER':
      return Motorista.fromJson(json);
    case 'REQUESTER':
    default:
      return Solicitante.fromJson(json); // Crie esta classe se não existir
  }
}

  Map<String, dynamic> toJson();
}