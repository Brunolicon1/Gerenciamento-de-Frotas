class Vehicle {
  final int id;
  final String plate;
  final String make;
  final String model;
  final double currentMileage; // Alterado para double para suportar 36.980
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
      // Tenta ler 'licensePlate' (API) ou 'value' (Banco) 
      plate: (json['licensePlate'] ?? json['value'] ?? '').toString(),
      make: json['make']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      currentMileage: double.tryParse(json['currentMileage']?.toString() ?? 
                       json['current_mileage']?.toString() ?? '0') ?? 0.0,
      status: json['status']?.toString() ?? 'ACTIVE',
    );
  }
}