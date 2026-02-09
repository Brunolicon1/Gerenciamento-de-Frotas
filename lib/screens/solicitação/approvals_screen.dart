import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/vehicle/vehicle_request.dart';
import '../../../services/vehicle/request_service.dart';
import './ApprovalFormScreen.dart';

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  List<VehicleRequest> _displayList = [];
  bool _loading = true;
  
  // Status inicial para carregar solicitações enviadas ao gestor
  String _selectedStatus = "SENT_TO_MANAGER";

  // Mapeamento de filtros amigáveis para os Enums do banco de dados
  final Map<String, String> _filters = {
    "Pendentes": "SENT_TO_MANAGER",
    "Aprovadas": "APPROVED",
    "Negadas": "REJECTED",
    "Canceladas": "CANCELED",
  };

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      // Busca solicitações baseadas no status selecionado no filtro
      final requests = await RequestService.getByStatus(_selectedStatus);
      if (!mounted) return;
      setState(() {
        _displayList = requests;
      });
    } catch (e) {
      _showSnack("Erro ao carregar: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _executeReject(VehicleRequest request) async {
    try {
      setState(() => _loading = true);
      await RequestService.reject(request.id, notes: "Recusado via App");
      await _loadRequests();
      _showSnack("Solicitação recusada!", Colors.red);
    } catch (e) {
      _showSnack("Erro ao rejeitar: $e", Colors.red);
      setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return "--/--";
    return DateFormat('dd/MM HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestão de Solicitações"),
        actions: [
          IconButton(onPressed: _loadRequests, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          // BARRA DE FILTROS POR STATUS
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _filters.entries.map((entry) {
                final isSelected = _selectedStatus == entry.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(entry.key),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedStatus = entry.value);
                        _loadRequests();
                      }
                    },
                    selectedColor: Colors.blueAccent,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _displayList.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadRequests,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _displayList.length,
                          itemBuilder: (_, index) => _buildApprovalCard(_displayList[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text("Nenhuma solicitação encontrada", style: TextStyle(fontSize: 16, color: Colors.grey)),
    );
  }

  Widget _buildApprovalCard(VehicleRequest item) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.purpose,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                  ),
                ),
                Text(item.status, style: const TextStyle(fontSize: 12, color: Colors.orange)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.place, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text("${item.city} - ${item.state}", style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.description, style: const TextStyle(color: Colors.black87)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Solicitante", style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(item.requester, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Saída prevista", style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(_formatDate(item.startDateTime), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            
            // BOTÕES DE AÇÃO: Só aparecem se a solicitação estiver pendente
            if (item.status == "SENT_TO_MANAGER") ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () => _executeReject(item),
                    child: const Text("Negar"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final bool? approved = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ApprovalFormScreen(request: item),
                        ),
                      );

                      if (approved == true) {
                        _loadRequests();
                      }
                    },
                    child: const Text("Aprovar"),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}