// lib/models/users/gestor_frotas.dart

import 'pessoa.dart';
import 'user_role.dart';

class GestorFrotas extends Pessoa {
  // Removemos o 'department' conforme solicitado

  GestorFrotas({
    required super.id,
    required super.name,
    required super.email,
    required super.cpf,
    required super.phone,
  }) : super(role: UserRole.manager);

  factory GestorFrotas.fromJson(Map<String, dynamic> json) {
    return GestorFrotas(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      cpf: json['cpf'],
      phone: json['phone'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'cpf': cpf,
      'phone': phone,
      'role': 'manager',
    };
  }
}