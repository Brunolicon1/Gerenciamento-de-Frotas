import 'dart:convert';
import 'package:http/http.dart';

import '../../models/vehicle/vehicle_request.dart';
import '../api_client.dart';

class RequestService {

  /// 🔹 Lista solicitações pendentes do usuário logado
  static Future<List<VehicleRequest>> getPending() async {

    final Response response =
        await ApiClient.get("/requests/?status=PENDING");

    if (response.statusCode == 200) {
      final Map<String, dynamic> page = jsonDecode(response.body);

      final List content = page["content"]; // Spring Page

      return content
          .map((e) => VehicleRequest.fromJson(e))
          .toList();
    }

    throw Exception("Erro ao buscar solicitações: ${response.statusCode}");
  }

  /// 🔹 Aprovar (PATCH)
  static Future<void> approve(int id,
      {required int driverId, required int vehicleId}) async {

    final response = await ApiClient.patch(
      "/requests/$id/approve",
      body: {
        "driverId": driverId,
        "vehicleId": vehicleId,
        "notes": ""
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Erro ao aprovar: ${response.body}");
    }
  }

  /// 🔹 Rejeitar (PATCH)
  static Future<void> reject(int id, {String notes = ""}) async {

    final response = await ApiClient.patch(
      "/requests/$id/reject",
      body: {
        "notes": notes
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Erro ao rejeitar: ${response.body}");
    }
  }
}
