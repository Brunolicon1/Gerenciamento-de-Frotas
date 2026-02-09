class VehicleRequest {
  final int id;
  final String requester;
  final String description;
  final String purpose; // Alinhado com o JSON
  final String status;
  final String city;
  final String state;
  final DateTime? startDateTime;
  final DateTime? endDateTime;

  VehicleRequest({
    required this.id,
    required this.requester,
    required this.description,
    required this.purpose,
    required this.status,
    required this.city,
    required this.state,
    this.startDateTime,
    this.endDateTime,
  });

  factory VehicleRequest.fromJson(Map<String, dynamic> json) {
  return VehicleRequest(
    id: json['id'] ?? 0,
    requester: json['requester']?['name'] ?? 'Desconhecido',
    description: json['description'] ?? '',
    purpose: json['purpose'] ?? '',
    status: json['status'] ?? '',
    // Tenta ler 'city' ou 'destCity' para ser compatível com diferentes versões da API
    city: json['city'] ?? json['destCity'] ?? '', 
    state: json['state'] ?? json['destState'] ?? '', 
    startDateTime: json['startDateTime'] != null ? DateTime.parse(json['startDateTime']) : null,
    endDateTime: json['endDateTime'] != null ? DateTime.parse(json['endDateTime']) : null,
  );
}
}