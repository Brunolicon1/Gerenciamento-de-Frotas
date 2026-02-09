import 'package:flutter/material.dart';
import 'package:extensao3/widgets/custom_app_bar.dart';
import '../models/vehicle/vehicle_usage_model.dart';
import 'check_in_screen.dart';

class TripDetailsScreen extends StatelessWidget {
  final VehicleUsage activity;

  const TripDetailsScreen({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final bool isStarted = activity.isStarted;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Detalhes da Missão'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 180, color: Colors.blue.shade900, child: const Center(child: Icon(Icons.map, size: 50, color: Colors.white))),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Missão #${activity.id}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _infoTile(Icons.person, "Motorista", activity.driverName),
                  _infoTile(Icons.timer, "Status", activity.status.replaceAll('_', ' ')),
                  const Divider(height: 40),
                  const Text("Viatura", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.directions_car, color: Colors.blue),
                      title: Text("${activity.vehicle.make} ${activity.vehicle.model}"),
                      subtitle: Text("Placa: ${activity.vehicle.licensePlate}\nKM Atual: ${activity.vehicle.currentMileage}"),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isStarted ? Colors.orange.shade800 : Colors.green.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CheckInScreen(activity: activity))),
                      child: Text(
                        isStarted ? "REALIZAR CHECK-OUT (DEVOLUÇÃO)" : "REALIZAR CHECK-IN (RETIRADA)",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [Icon(icon, color: Colors.grey), const SizedBox(width: 12), Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)), Text(value)]),
    );
  }
}