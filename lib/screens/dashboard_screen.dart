import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Seus modelos
import '../models/vehicle_model.dart';
import '../models/fleet_stats.dart';

// Import da tela de cadastro (Certifique-se que o caminho está correto)
import 'vehicle_registration_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Futures para os dados
  late Future<List<Vehicle>> futureVehicles;
  late Future<FleetStats> futureStats;

  @override
  void initState() {
    super.initState();
    _refreshData(); // Centralizei a chamada inicial aqui
  }

  // Função auxiliar para recarregar tudo
  void _refreshData() {
    setState(() {
      futureVehicles = fetchVehicles();
      futureStats = fetchFleetStats();
    });
  }

  // --- API: BUSCA LISTA DE VEÍCULOS ---
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

  // --- API: BUSCA ESTATÍSTICAS ---
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
      print('Erro Stats: $e');
      return FleetStats(total: 0, available: 0, inUse: 0, maintenance: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Adicionei Scaffold caso queira usar background color ou outros recursos
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
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
                  color: Colors.blueGrey.shade800,
                ),
              ),
              const SizedBox(height: 16.0),

              FutureBuilder<FleetStats>(
                future: futureStats,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: LinearProgressIndicator());
                  }
                  final stats = snapshot.data ??
                      FleetStats(total: 0, available: 0, inUse: 0, maintenance: 0);

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    childAspectRatio: 1.5, // Deixa os cards mais "retangulares" e bonitos
                    children: [
                      _buildStatCard(
                        context,
                        icon: Icons.directions_car_filled,
                        label: 'Total',
                        value: stats.total.toString(),
                        color: Colors.blue.shade800,
                      ),
                      _buildStatCard(
                        context,
                        icon: Icons.check_circle_outline,
                        label: 'Disponíveis',
                        value: stats.available.toString(),
                        color: Colors.green.shade800,
                      ),
                      _buildStatCard(
                        context,
                        icon: Icons.local_shipping,
                        label: 'Em Uso',
                        value: stats.inUse.toString(),
                        color: Colors.orange.shade800,
                      ),
                      _buildStatCard(
                        context,
                        icon: Icons.build_circle,
                        label: 'Manutenção',
                        value: stats.maintenance.toString(),
                        color: Colors.red.shade800,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32.0),

              // --- SEÇÃO 2: LISTA DE VEÍCULOS (Com Botão de Adicionar) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Veículos',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade800,
                    ),
                  ),

                  // Agrupamento dos botões de ação
                  Row(
                    children: [
                      // 1. BOTÃO CADASTRAR (NOVO)
                      IconButton(
                        icon: Icon(Icons.add_circle, color: Colors.blue.shade700, size: 30),
                        tooltip: 'Cadastrar Viatura',
                        onPressed: () async {
                          // Navega para a tela de cadastro
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VehicleRegistrationScreen(),
                            ),
                          );
                          // Ao voltar, atualiza a lista (útil quando tivermos backend real)
                          _refreshData();
                        },
                      ),

                      // 2. BOTÃO ATUALIZAR
                      IconButton(
                        icon: Icon(Icons.refresh, color: Colors.grey.shade600),
                        tooltip: 'Recarregar Lista',
                        onPressed: _refreshData,
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 10.0),

              // Lista de Veículos
              FutureBuilder<List<Vehicle>>(
                future: futureVehicles,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  }
                  if (snapshot.hasData) {
                    final vehicles = snapshot.data!;
                    if (vehicles.isEmpty) return const Text('Nenhuma viatura encontrada.');

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = vehicles[index];
                        return _buildVehicleListItem(
                          context,
                          vehicle: vehicle,
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
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('disponivel') || s.contains('online')) return Colors.green.shade700;
    if (s.contains('uso') || s.contains('rota')) return Colors.orange.shade700;
    if (s.contains('manutencao')) return Colors.red.shade700;
    return Colors.grey;
  }

  Widget _buildStatCard(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color
  }) {
    return Card(
      elevation: 2.0,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 32.0, color: color),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 28,
                  ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleListItem(BuildContext context, {
    required Vehicle vehicle,
    required Color statusColor
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Colors.grey.shade200)
      ),
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.directions_car, color: Colors.blue.shade700),
        ),
        title: Text(
            vehicle.plate,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${vehicle.model} • ${vehicle.year}'),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  vehicle.status.toUpperCase(),
                  style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 14.0, color: Colors.grey.shade400),
        onTap: () {
          // Futuramente aqui abrirá os detalhes da viatura
          print("Clicou na viatura ${vehicle.plate}");
        },
      ),
    );
  }
}