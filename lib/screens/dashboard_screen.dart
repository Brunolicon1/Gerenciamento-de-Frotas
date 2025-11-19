import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Seus modelos
import '../models/vehicle_model.dart';
import '../models/fleet_stats.dart'; // <--- IMPORT NOVO

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Temos DOIS futuros agora: um para a lista, outro para os stats
  late Future<List<Vehicle>> futureVehicles;
  late Future<FleetStats> futureStats; // <--- NOVO

  @override
  void initState() {
    super.initState();
    futureVehicles = fetchVehicles();
    futureStats = fetchFleetStats(); // <--- CHAMADA NOVA
  }

  // --- BUSCA LISTA DE VEÍCULOS (JÁ EXISTIA) ---
  Future<List<Vehicle>> fetchVehicles() async {
    final url = Uri.parse('https://getviaturas-e7zphzrysa-rj.a.run.app/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Vehicle.fromJson(item)).toList();
      } else {
        throw Exception('Erro ao carregar veículos');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // --- NOVA FUNÇÃO: BUSCA ESTATÍSTICAS ---
  Future<FleetStats> fetchFleetStats() async {
    final url = Uri.parse('https://getviaturastats-e7zphzrysa-rj.a.run.app');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return FleetStats.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Erro ao carregar estatísticas');
      }
    } catch (e) {
      // Se der erro, retornamos tudo zerado para não quebrar a tela
      print('Erro Stats: $e');
      return FleetStats(total: 0, available: 0, inUse: 0, maintenance: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // --- SEÇÃO 1: RESUMO DA FROTA (KPIs) ---
            Text(
              'Resumo da Frota',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),

            // Usamos FutureBuilder para carregar os cards
            FutureBuilder<FleetStats>(
              future: futureStats,
              builder: (context, snapshot) {
                // Enquanto carrega ou se der erro, mostramos zeros ou loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LinearProgressIndicator());
                }

                // Pegamos os dados (ou usa padrão se nulo)
                final stats = snapshot.data ??
                    FleetStats(total: 0, available: 0, inUse: 0, maintenance: 0);

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  children: [
                    _buildStatCard(
                      context,
                      icon: Icons.directions_car_filled,
                      label: 'Total de Veículos',
                      value: stats.total.toString(), // Valor da API
                      color: Colors.blue.shade800,
                    ),
                    _buildStatCard(
                      context,
                      icon: Icons.check_circle_outline,
                      label: 'Veículos Disponíveis',
                      value: stats.available.toString(), // Valor da API
                      color: Colors.green.shade800,
                    ),
                    _buildStatCard(
                      context,
                      icon: Icons.local_shipping,
                      label: 'Veículos em Uso',
                      value: stats.inUse.toString(), // Valor da API
                      color: Colors.orange.shade800,
                    ),
                    _buildStatCard(
                      context,
                      icon: Icons.build_circle,
                      label: 'Em Manutenção',
                      value: stats.maintenance.toString(), // Valor da API
                      color: Colors.red.shade800,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24.0),

            // --- SEÇÃO 2: LISTA DE VEÍCULOS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Veículos',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    setState(() {
                      // Recarrega AMBOS ao clicar no refresh
                      futureVehicles = fetchVehicles();
                      futureStats = fetchFleetStats();
                    });
                  },
                )
              ],
            ),
            const SizedBox(height: 16.0),

            // FutureBuilder da Lista (Igual ao anterior)
            FutureBuilder<List<Vehicle>>(
              future: futureVehicles,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Erro: ${snapshot.error}');
                }
                if (snapshot.hasData) {
                  final vehicles = snapshot.data!;
                  if (vehicles.isEmpty) return const Text('Sem veículos.');

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      return _buildVehicleListItem(
                        context,
                        vehicle: vehicle, // Passamos o objeto inteiro agora
                        statusColor: _getStatusColor(vehicle.status),
                      );
                    },
                  );
                }
                return const Text('Sem dados.');
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPERS (Funções visuais) ---

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('disponivel') || s.contains('online')) return Colors.green.shade700;
    if (s.contains('uso') || s.contains('rota')) return Colors.orange.shade700;
    if (s.contains('manutencao')) return Colors.red.shade700;
    return Colors.grey;
  }

  Widget _buildStatCard(BuildContext context, {required IconData icon, required String label, required String value, required Color color}) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36.0, color: color),
            const SizedBox(height: 12.0),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4.0),
            Text(label, style: Theme.of(context).textTheme.bodySmall, maxLines: 2),
          ],
        ),
      ),
    );
  }

  // Atualizei este helper para receber o objeto Vehicle direto
  Widget _buildVehicleListItem(BuildContext context, {required Vehicle vehicle, required Color statusColor}) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Icon(Icons.directions_car, color: Colors.blue.shade700),
        ),
        title: Text('Placa: ${vehicle.plate}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text.rich(
          TextSpan(
            text: '${vehicle.model} - ${vehicle.year}\n',
            style: TextStyle(color: Colors.grey.shade600),
            children: [
              TextSpan(text: vehicle.status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
        isThreeLine: true,
      ),
    );
  }
}