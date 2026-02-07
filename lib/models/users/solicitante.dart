import 'pessoa.dart';
import 'user_role.dart';

class Solicitante extends Pessoa {
  Solicitante({
    required super.id,
    required super.name,
    required super.cpf,
  }) : super(role: UserRole.REQUESTER); // Usando o novo enum

  factory Solicitante.fromJson(Map<String, dynamic> json) {
    return Solicitante(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      cpf: json['registration'] ?? '', // No seu SQL, a matrícula/CPF é 'registration'
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'registration': cpf,
      'role': 'REQUESTER',
    };
  }
}