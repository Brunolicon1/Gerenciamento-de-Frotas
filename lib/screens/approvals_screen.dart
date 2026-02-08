import 'package:flutter/material.dart';

import '../../models/vehicle/vehicle_request.dart';
import '../../services/vehicle/request_service.dart';

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  List<VehicleRequest> _displayList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  // ================= API =================

  Future<void> _loadRequests() async {
    setState(() => _loading = true);

    try {
      final requests = await RequestService.getPending();

      if (!mounted) return;

      setState(() {
        _displayList = requests;
      });
    } catch (e) {
      _showSnack("Erro ao carregar solicitações", Colors.red);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // ================= CONFIRMAÇÃO =================

  Future<void> _confirmAction({
    required VehicleRequest request,
    required bool isApproval,
  }) async {
    final actionName = isApproval ? "Aprovar" : "Negar";
    final color = isApproval ? Colors.green : Colors.red;

    return showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$actionName solicitação'),
        content: Text(
          'Deseja ${actionName.toLowerCase()} o pedido de ${request.requester}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: color),
            onPressed: () {
              Navigator.pop(context);

              if (isApproval) {
                _executeApprove(request);
              } else {
                _executeReject(request);
              }
            },
            child: Text(actionName),
          ),
        ],
      ),
    );
  }

  // ================= AÇÕES API =================

  Future<void> _executeApprove(VehicleRequest request) async {
    try {
      setState(() => _loading = true);

      await RequestService.approve(
        request.id,
        driverId: 1,
        vehicleId: 1,
      );

      await _loadRequests();

      _showSnack("Solicitação aprovada!", Colors.green);
    } catch (e) {
      _showSnack("Erro ao aprovar", Colors.red);
    }
  }

  Future<void> _executeReject(VehicleRequest request) async {
    try {
      setState(() => _loading = true);

      await RequestService.reject(request.id);

      await _loadRequests();

      _showSnack("Solicitação recusada!", Colors.red);
    } catch (e) {
      _showSnack("Erro ao rejeitar", Colors.red);
    }
  }

  // ================= UTILS =================

  void _showSnack(String msg, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aprovações Pendentes")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _displayList.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _displayList.length,
                    itemBuilder: (_, index) =>
                        _buildApprovalCard(_displayList[index]),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "Nenhuma solicitação pendente",
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildApprovalCard(VehicleRequest item) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.type,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),

            Text(item.details),

            const SizedBox(height: 8),

            Text(
              item.requester,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () =>
                      _confirmAction(request: item, isApproval: false),
                  child: const Text("Negar"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () =>
                      _confirmAction(request: item, isApproval: true),
                  child: const Text("Aprovar"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
