// lib/models/users/motorista.dart

import 'pessoa.dart';
import 'user_role.dart';

class Motorista extends Pessoa {
  final String cnhNumber;
  final String cnhCategory; // Ex: B, C, D

  // Removemos 'cnhExpiration' conforme solicitado

  Motorista({
    required super.id,
    required super.name,
    required super.email,
    required super.cpf,
    required super.phone,
    required this.cnhNumber,
    required this.cnhCategory,
  }) : super(role: UserRole.driver);

  factory Motorista.fromJson(Map<String, dynamic> json) {
    return Motorista(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      cpf: json['cpf'],
      phone: json['phone'],
      cnhNumber: json['cnhNumber'] ?? '',
      cnhCategory: json['cnhCategory'] ?? 'B',
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
      'role': 'driver',
      'cnhNumber': cnhNumber,
      'cnhCategory': cnhCategory,
    };
  }
}