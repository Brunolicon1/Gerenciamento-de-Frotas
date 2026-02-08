class Vehicle {
  final int id;
  final String plate; // Representa a coluna 'value'
  final String make;
  final String model;
  final int currentMileage;
  final String status;

  Vehicle({
    required this.id,
    required this.plate,
    required this.make,
    required this.model,
    required this.currentMileage,
    required this.status,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] ?? 0,
      // No banco a coluna é 'value'
      plate: json['value']?.toString() ?? '', 
      make: json['make']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      // Conversão segura para evitar o FormatException: null
      currentMileage: json['current_mileage'] != null 
          ? int.parse(json['current_mileage'].toString()) 
          : 0,
      status: json['status']?.toString() ?? 'INACTIVE',
    );
  }
}