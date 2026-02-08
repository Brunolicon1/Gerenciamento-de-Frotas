import 'package:flutter/material.dart';

import '../models/vehicle/vehicle_model.dart';
import '../models/fleet_stats.dart';
import '../services/vehicle/vehicle_service.dart';
import 'vehicle_registration_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Vehicle>> futureVehicles;
  late Future<FleetStats> futureStats;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  // ================= REFRESH =================

  void _refreshData() {
    setState(() {
      futureVehicles = VehicleService.getAll(); // 🔥 agora usa service
      futureStats = _buildStatsFromVehicles(); // calcula local
    });
  }

  // ================= STATS LOCAL =================
  // (caso ainda não tenha endpoint /stats)

  Future<FleetStats> _buildStatsFromVehicles() async {
    final vehicles = await VehicleService.getAll();

    int available = 0;
    int inUse = 0;
    int maintenance = 0;

    for (var v in vehicles) {
      final s = v.status.toLowerCase();

      if (s.contains('disponivel'))
        available++;
      else if (s.contains('uso'))
        inUse++;
      else if (s.contains('manutencao'))
        maintenance++;
    }

    return FleetStats(
      total: vehicles.length,
      available: available,
      inUse: inUse,
      maintenance: maintenance,
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= KPIs =================
              const Text(
                'Resumo da Frota',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              FutureBuilder<FleetStats>(
                future: futureStats,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const LinearProgressIndicator();
                  }

                  final stats = snapshot.data!;

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      _statCard("Total", stats.total, Icons.directions_car),
                      _statCard("Disponíveis", stats.available, Icons.check),
                      _statCard("Em Uso", stats.inUse, Icons.route),
                      _statCard("Manutenção", stats.maintenance, Icons.build),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              // ================= HEADER LISTA =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Veículos',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, size: 30),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VehicleRegistrationScreen(),
                        ),
                      );
                      _refreshData();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ================= LISTA =================
              FutureBuilder<List<Vehicle>>(
                future: futureVehicles,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text("Erro: ${snapshot.error}");
                  }

                  final vehicles = snapshot.data ?? [];

                  if (vehicles.isEmpty) {
                    return const Text("Nenhuma viatura encontrada");
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: vehicles.length,
                    itemBuilder: (_, index) {
                      final v = vehicles[index];

                      return Card(
                        child: ListTile(
                          title: Text(
                            v.plate,
                          ), // Agora vindo corretamente de 'value'
                          // Removido v.year que causava o erro
                          subtitle: Text(
                            "${v.make} ${v.model} • ${v.currentMileage} km",
                          ),
                          trailing: Text(
                            v.status,
                            style: TextStyle(
                              color: v.status == 'ACTIVE'
                                  ? Colors.green
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= COMPONENTES =================

  Widget _statCard(String label, int value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text(
              "$value",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}
