// lib/models/users/admin.dart

import 'pessoa.dart';
import 'user_role.dart';

class Admin extends Pessoa {
  Admin({
    required super.id,
    required super.name,
    required super.email,
    required super.cpf,
    required super.phone,
  }) : super(role: UserRole.admin);

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
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
      'role': 'admin',
    };
  }
}