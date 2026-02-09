import 'package:flutter/material.dart';
import '../models/vehicle/vehicle_model.dart';
import '../models/fleet_stats.dart';
import '../services/vehicle/vehicle_service.dart';
import 'vehicle_registration_screen.dart';
import '../services/token_storage.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userRole = ""; // Variável dinâmica
  late Future<List<Vehicle>> futureVehicles;
  late Future<FleetStats> futureStats;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      futureVehicles = VehicleService.getAll();
      futureStats = _buildStatsFromVehicles();
    });
  }

  Future<void> _loadPermissions() async {
    final role = await TokenStorage.getUserRole();
    if (mounted) {
      setState(() {
        _userRole = role; // Força a interface a redesenhar e esconder o botão
      });
    }
  }

  Future<FleetStats> _buildStatsFromVehicles() async {
    final vehicles = await VehicleService.getAll();
    int available = 0, inUse = 0, maintenance = 0;

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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // BREAKPOINTS RESPONSIVOS
    final bool isMobileSmall = screenWidth < 400; // iPhone 12, SE, etc.
    final bool isWeb = screenWidth > 900; // Desktop/Web

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Gestão de Frota"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Resumo Operacional', null),
                  const SizedBox(height: 16),

                  // GRID DE KPIs ADAPTATIVO
                  _buildKpiGrid(isWeb, isMobileSmall),

                  const SizedBox(height: 24),

                  // SEÇÃO DE GRÁFICOS ADAPTATIVA
                  _buildChartsSection(isWeb),

                  const SizedBox(height: 32),

                  _buildSectionHeader('Veículos na Base', () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VehicleRegistrationScreen(),
                      ),
                    );
                    if (result == true) {
                      _refreshData();
                    }
                  }),
                  const SizedBox(height: 16),

                  // GRID DE VEÍCULOS ADAPTATIVO
                  _buildVehicleGrid(isWeb),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- LÓGICA DE LAYOUT ---

  Widget _buildKpiGrid(bool isWeb, bool isMobileSmall) {
    return FutureBuilder<FleetStats>(
      future: futureStats,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();
        final stats = snapshot.data!;

        // Define o número de colunas: Web (4), Mobile Médio (2), iPhone 12/Pequeno (1)
        int crossAxisCount = isWeb ? 4 : (isMobileSmall ? 1 : 2);

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isWeb ? 2.2 : (isMobileSmall ? 3.5 : 1.4),
          children: [
            _statCard("Total", stats.total, Icons.directions_car, Colors.blue),
            _statCard(
              "Disponíveis",
              stats.available,
              Icons.check_circle,
              Colors.green,
            ),
            _statCard(
              "Em Uso",
              stats.inUse,
              Icons.local_shipping,
              Colors.orange,
            ),
            _statCard("Manutenção", stats.maintenance, Icons.build, Colors.red),
          ],
        );
      },
    );
  }

  Widget _buildChartsSection(bool isWeb) {
    if (isWeb) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildChartCard("Status da Frota", _buildPieChart())),
          const SizedBox(width: 16),
          Expanded(
            child: _buildChartCard("Uso Semanal (km)", _buildBarChart()),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildChartCard("Status da Frota", _buildPieChart()),
          const SizedBox(height: 16),
          _buildChartCard("Uso Semanal (km)", _buildBarChart()),
        ],
      );
    }
  }

  Widget _buildVehicleGrid(bool isWeb) {
    return FutureBuilder<List<Vehicle>>(
      future: futureVehicles,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        final vehicles = snapshot.data ?? [];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: vehicles.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWeb ? 3 : 1, // 3 colunas web, 1 coluna mobile
            mainAxisExtent: 85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (_, index) => _vehicleCard(vehicles[index]),
        );
      },
    );
  }

  // --- COMPONENTES VISUAIS ---

  Widget _statCard(String label, int value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$value",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 16),
            SizedBox(height: 140, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return Row(
      children: [
        const SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            value: 0.6,
            strokeWidth: 15,
            color: Colors.green,
            backgroundColor: Colors.orange,
          ),
        ),
        const SizedBox(width: 24),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _chartLegend(Colors.green, "Disponível"),
            const SizedBox(height: 4),
            _chartLegend(Colors.orange, "Em uso"),
          ],
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _bar(40, "S"),
        _bar(70, "T"),
        _bar(90, "Q"),
        _bar(55, "Q"),
        _bar(80, "S"),
        _bar(30, "S"),
        _bar(20, "D"),
      ],
    );
  }

  Widget _bar(double height, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 14,
          height: height,
          decoration: BoxDecoration(
            color: Colors.blue.shade400,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _chartLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _vehicleCard(Vehicle v) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        dense: true,
        leading: const Icon(
          Icons.directions_car,
          color: Colors.blueGrey,
          size: 20,
        ),
        title: Text(
          v.licensePlate,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        subtitle: Text(
          "${v.make} ${v.model}",
          style: const TextStyle(fontSize: 11),
        ),
        trailing: Icon(
          Icons.circle,
          color: v.status == 'ACTIVE' ? Colors.green : Colors.grey,
          size: 10,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onAdd) {
    // Apenas o ADMIN tem permissão para ver e clicar no botão de novo veículo
    bool isAdmin = _userRole == "ADMIN";

   return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (onAdd != null && isAdmin) 
          TextButton.icon(
            onPressed: onAdd, 
            icon: const Icon(Icons.add, size: 18), 
            label: const Text("Novo")
          ),
      ],
    );
  }
}
