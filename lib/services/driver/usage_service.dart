  import 'dart:convert';
  import 'package:http/http.dart';
  import '../api_client.dart';

  class UsageService {
    /// 🔹 Busca os usos/missões do motorista logado
    // lib/services/vehicle/usage_service.dart

    static Future<List<dynamic>> getMyUsages() async {
  final Response response = await ApiClient.get("/usages/my-usages");
  print("Status API: ${response.statusCode}");
  print("Corpo API: ${response.body}"); // 👈 Veja o JSON real aqui

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);
    return data['content'] ?? [];
  }
  throw Exception("Erro ao buscar missões");
}

    /// 🔹 Realiza a Retirada (Check-in) - Início da missão
    static Future<void> checkIn(int usageId, int mileage) async {
      final response = await ApiClient.post(
        "/usages/$usageId/check-in",
        body: {"currentMileage": mileage},
      );

      if (response.statusCode != 200) {
        throw Exception("Erro no check-in: ${response.body}");
      }
    }

    /// 🔹 Realiza a Devolução (Check-out) - Fim da missão
    static Future<void> checkOut(int usageId, int endMileage, String notes) async {
      final response = await ApiClient.post(
        "/usages/$usageId/check-out",
        body: {
          "endMileage": endMileage,
          "notes": notes,
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Erro no check-out: ${response.body}");
      }
    }
  }