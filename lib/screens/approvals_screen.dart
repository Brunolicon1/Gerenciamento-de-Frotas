import 'package:flutter/material.dart';
import 'package:extensao3/data/mock_database.dart';

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  List<Request> _displayList = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() {
    setState(() {
      _displayList = MockDatabase.pendingRequests
          .where((r) => r.status == 'pendente')
          .toList();
    });
  }

  // --- NOVA LÓGICA DE CONFIRMAÇÃO ---

  Future<void> _confirmAction({
    required Request request,
    required bool isApproval,
  }) async {
    final actionName = isApproval ? "Aprovar" : "Negar";
    final color = isApproval ? Colors.green : Colors.red;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // O usuário é obrigado a escolher uma opção
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$actionName Solicitação?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Você está prestes a ${actionName.toLowerCase()} o pedido de:'),
                const SizedBox(height: 8),
                Text(request.requester, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Tem certeza que deseja continuar?'),
              ],
            ),
          ),
          actions: <Widget>[
            // Botão CANCELAR
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo sem fazer nada
              },
            ),
            // Botão CONFIRMAR
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
              child: Text('Confirmar $actionName'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
                // Executa a ação real
                if (isApproval) {
                  _executeApprove(request);
                } else {
                  _executeReject(request);
                }
              },
            ),
          ],
        );
      },
    );
  }

  // --- AÇÕES REAIS (SÓ RODAM DEPOIS DO DIÁLOGO) ---

  void _executeApprove(Request request) {
    MockDatabase.approveRequest(request.id);
    _removeRequestFromScreen(request);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Solicitação de ${request.requester} APROVADA!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _executeReject(Request request) {
    MockDatabase.rejectRequest(request.id);
    _removeRequestFromScreen(request);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Solicitação RECUSADA.'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _removeRequestFromScreen(Request request) {
    setState(() {
      _displayList.remove(request);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _displayList.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _displayList.length,
        itemBuilder: (context, index) {
          return _buildApprovalCard(_displayList[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.green.shade100),
          const SizedBox(height: 16),
          const Text(
            'Tudo limpo por aqui!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text('Nenhuma pendência para aprovação.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildApprovalCard(Request item) {
    return Card(
      elevation: 3.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getIconForType(item.type),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    item.type,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Text(
                  "${item.date.day}/${item.date.month}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Text(item.details, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 8.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
              child: Text(item.requester, style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontStyle: FontStyle.italic)),
            ),
            const Divider(height: 24.0, thickness: 1.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // BOTÃO NEGAR -> Chama o Dialog com isApproval = false
                OutlinedButton(
                  onPressed: () => _confirmAction(request: item, isApproval: false),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                  child: const Text('Negar'),
                ),
                const SizedBox(width: 12.0),
                // BOTÃO APROVAR -> Chama o Dialog com isApproval = true
                ElevatedButton.icon(
                  onPressed: () => _confirmAction(request: item, isApproval: true),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Aprovar'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getIconForType(String type) {
    IconData icon;
    Color color;
    if (type.contains('Manutenção')) {
      icon = Icons.build_circle;
      color = Colors.orange;
    } else if (type.contains('Reembolso')) {
      icon = Icons.attach_money;
      color = Colors.green;
    } else {
      icon = Icons.map;
      color = Colors.blue;
    }
    return Icon(icon, color: color, size: 28);
  }
}