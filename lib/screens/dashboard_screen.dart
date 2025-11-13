// lib/screens/dashboard_screen.dart (REFATORADO)

import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // O SingleChildScrollView é o widget "raiz" desta tela
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TÍTULO DA SEÇÃO DE RESUMO ---
            Text(
              'Resumo da Frota',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),

            // --- GRELHA DE ESTATÍSTICAS (KPIs) ---
            GridView.count(
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
                  value: '25',
                  color: Colors.blue.shade800,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.check_circle_outline,
                  label: 'Veículos Disponíveis',
                  value: '18',
                  color: Colors.green.shade800,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.local_shipping,
                  label: 'Veículos em Uso',
                  value: '22',
                  color: Colors.orange.shade800,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.build_circle,
                  label: 'Em Manutenção',
                  value: '3',
                  color: Colors.red.shade800,
                ),
              ],
            ),

            const SizedBox(height: 24.0),

            // --- SEÇÃO: LISTA DE VEÍCULOS ---
            Text(
              'Veículos Recentes',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),

            Column(
              children: [
                _buildVehicleListItem(
                  context,
                  plate: 'ABC-1234',
                  model: 'Caminhão Modelo X',
                  status: 'Disponível',
                  statusColor: Colors.green.shade700,
                ),
                _buildVehicleListItem(
                  context,
                  plate: 'XYZ-9876',
                  model: 'Carro Utilitário',
                  status: 'Em Uso',
                  statusColor: Colors.orange.shade700,
                ),
                _buildVehicleListItem(
                  context,
                  plate: 'JKL-1122',
                  model: 'Caminhão Modelo Y',
                  status: 'Em Manutenção',
                  statusColor: Colors.red.shade700,
                ),
              ],
            ),

            const SizedBox(height: 24.0),

            // --- TÍTULO DA SEÇÃO DE AÇÕES ---
            Text(
              'Ações Rápidas',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),

            // --- BOTÕES DE AÇÃO RÁPIDA ---
            _buildActionButton(
              context,
              icon: Icons.list_alt,
              label: 'Ver Lista de Veículos',
              onPressed: () {
                print('Ir para Lista de Veículos');
              },
            ),
            const SizedBox(height: 12.0),
            _buildActionButton(
              context,
              icon: Icons.map_outlined,
              label: 'Ver Mapa Geral',
              onPressed: () {
                print('Ir para Mapa Geral');
              },
            ),
            const SizedBox(height: 12.0),
            _buildActionButton(
              context,
              icon: Icons.add_circle_outline,
              label: 'Cadastrar Novo Veículo',
              onPressed: () {
                print('Ir para Cadastro de Veículo');
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER PARA OS CARTÕES DE RESUMO ---
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
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
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER PARA A LISTA DE VEÍCULOS ---
  Widget _buildVehicleListItem(
    BuildContext context, {
    required String plate,
    required String model,
    required String status,
    required Color statusColor,
  }) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Icon(Icons.directions_car, color: Colors.blue.shade700),
        ),
        title: Text(
          'Placa: $plate',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text.rich(
          TextSpan(
            text: '$model\n',
            style: TextStyle(color: Colors.grey.shade600),
            children: [
              TextSpan(
                text: status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16.0),
        onTap: () {
          print('Clicou no veículo $plate');
        },
        isThreeLine: true,
      ),
    );
  }

  // --- WIDGET HELPER PARA OS BOTÕES DE AÇÃO ---
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55.0,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24.0),
        label: Text(label, style: const TextStyle(fontSize: 16.0)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }
}
