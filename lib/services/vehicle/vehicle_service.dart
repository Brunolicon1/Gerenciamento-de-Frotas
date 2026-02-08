import 'dart:convert';
import 'package:http/http.dart';

import '../../models/vehicle/vehicle_model.dart';
import '../api_client.dart';

class VehicleService {

  /// 🔹 Busca veículos da API (Spring Page)
  static Future<List<Vehicle>> getAll() async {

    final Response response = await ApiClient.get("/vehicles");

    if (response.statusCode == 200) {

      final Map<String, dynamic> page = jsonDecode(response.body);

      final List content = page["content"]; // 👈 AQUI ESTÁ A CHAVE

      return content
          .map((e) => Vehicle.fromJson(e))
          .toList();
    }

    throw Exception("Erro ao buscar veículos: ${response.statusCode}");
  }
}
