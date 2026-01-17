// Arquivo: lib/screens/trip_details_screen.dart

import 'package:flutter/material.dart';
import 'package:extensao3/widgets/custom_app_bar.dart';
import 'package:extensao3/data/mock_database.dart';

import 'check_in_screen.dart'; // Importando o Modelo Activity

class TripDetailsScreen extends StatelessWidget {
  // Recebemos a viagem inteira vinda do banco de dados
  final Activity activity;

  const TripDetailsScreen({
    super.key,
    required this.activity
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App Bar padrão com botão de voltar
      appBar: CustomAppBar(
        title: 'Detalhes da Missão',
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CABEÇALHO COM MAPA (Visual)
            _buildMapHeader(),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. TÍTULO, ROTA E DESCRIÇÃO
                  Text(
                    activity.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),

                  // Componente visual da Rota
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blueAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          activity.route,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 40),

                  // 3. INFORMAÇÕES DA VIATURA (Dinâmico)
                  const Text(
                    "Viatura Designada",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Icon(
                        Icons.directions_car_filled,
                        size: 40,
                        color: _getStatusColor(activity.status),
                      ),
                      title: Text(activity.vehicleModel, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Placa: ${activity.vehiclePlate}"),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text("OK", style: TextStyle(color: Colors.green, fontSize: 12)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 4. EQUIPE / PASSAGEIROS (Lista Dinâmica)
                  const Text(
                    "Equipe / Passageiros",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Gera a lista baseado no Array 'team' do banco
                  ...activity.team.map((member) => _buildPassengerItem(member)).toList(),

                  const SizedBox(height: 40),

                  // 5. BOTÃO DE AÇÃO (CHECK-IN)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () {
                          // Navega para a tela de Check-in passando os dados da viagem
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckInScreen(activity: activity),
                            ),
                          );
                      },
                      icon: const Icon(Icons.vpn_key),
                      label: const Text("REALIZAR CHECK-IN (RETIRADA)"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets Auxiliares ---

  Widget _buildMapHeader() {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.grey.shade300,
      child: Stack(
        children: [
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text("Mapa da Rota (Google Maps)", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              color: Colors.black.withOpacity(0.6),
              child: Center(
                child: Text(
                  "Status: ${activity.status.toUpperCase().replaceAll('_', ' ')}",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPassengerItem(String name) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade50,
            child: Text(name[0], style: TextStyle(color: Colors.blue.shade800)),
          ),
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'em_andamento': return Colors.blueAccent;
      case 'concluido': return Colors.green;
      default: return Colors.grey;
    }
  }
}