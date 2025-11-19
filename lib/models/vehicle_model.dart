class Vehicle {
  final String id;
  final String plate;       // placa
  final String model;       // modelo
  final int year;           // ano
  final String type;        // tipo
  final int capacity;       // lotacao
  final int odometer;       // hodometro
  final String fuel;        // combustivel
  final List<String> equipment; // equipamentosEmbarcados
  final String status;

  // Datas (podem ser nulas, por isso o ?)
  final DateTime? ipvaDate;
  final DateTime? insuranceDate;
  final DateTime? inspectionDate;
  final DateTime? registrationDate;

  Vehicle({
    required this.id,
    required this.plate,
    required this.model,
    required this.year,
    required this.type,
    required this.capacity,
    required this.odometer,
    required this.fuel,
    required this.equipment,
    required this.status,
    this.ipvaDate,
    this.insuranceDate,
    this.inspectionDate,
    this.registrationDate,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      // Mapeamento simples (Strings e Inteiros)
      id: json['id'] ?? '',
      plate: json['placa'] ?? 'Sem Placa',
      model: json['modelo'] ?? 'Modelo Desconhecido',
      year: json['ano'] ?? 0,
      type: json['tipo'] ?? 'Não informado',
      capacity: json['lotacao'] ?? 0,
      odometer: json['hodometro'] ?? 0,
      fuel: json['combustivel'] ?? 'Não informado',
      status: json['status'] ?? 'Indefinido',

      // Mapeamento da Lista (Array)
      // Convertemos para List<String> garantindo que não dê erro
      equipment: json['equipamentosEmbarcados'] != null
          ? List<String>.from(json['equipamentosEmbarcados'])
          : [],

      // Mapeamento das Datas (A parte "tricky")
      // Usamos uma função auxiliar que criei lá em baixo
      ipvaDate: _parseDate(json['dataVencimentoIPVA']),
      insuranceDate: _parseDate(json['dataVencimentoSeguro']),
      inspectionDate: _parseDate(json['dataVistoria']),
      registrationDate: _parseDate(json['dataCadastro']),
    );
  }

  // --- FUNÇÃO AUXILIAR PARA CONVERTER DATAS ---
  // Transforma aquele objeto {_seconds: ...} numa Data do Dart
  static DateTime? _parseDate(dynamic dateMap) {
    if (dateMap == null) return null;

    // Verifica se tem o campo '_seconds'
    if (dateMap is Map && dateMap.containsKey('_seconds')) {
      final int seconds = dateMap['_seconds'];
      // O Dart usa milissegundos, então multiplicamos por 1000
      return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    }
    return null;
  }
}