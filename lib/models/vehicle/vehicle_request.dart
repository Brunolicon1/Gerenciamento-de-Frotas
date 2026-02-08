class VehicleRequest {
  final int id;

  final String requester;   // nome do solicitante
  final String details;     // descrição
  final String type;        // finalidade/purpose
  final String status;

  final DateTime? createdAt;

  VehicleRequest({
    required this.id,
    required this.requester,
    required this.details,
    required this.type,
    required this.status,
    this.createdAt,
  });

  factory VehicleRequest.fromJson(Map<String, dynamic> json) {
    return VehicleRequest(
      id: json['id'],

      // 👇 requester vem como objeto { id, name }
      requester: json['requester']?['name'] ?? 'Desconhecido',

      details: json['description'] ?? '',
      type: json['purpose'] ?? '',
      status: json['status'] ?? '',

      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
}
