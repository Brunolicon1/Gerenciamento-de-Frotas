// lib/screens/approvals_screen.dart

import 'package:flutter/material.dart';

class ApprovalsScreen extends StatelessWidget {
  const ApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos um ListView.builder. Esta é a forma mais eficiente
    // de construir uma lista, especialmente se ela for longa.
    // No nosso caso, vamos usar uma lista estática de 3 itens
    // apenas para o exemplo.

    // 1. DADOS FICTÍCIOS (MOCK DATA)
    // No futuro, isto viria de um banco de dados ou API
    final List<Map<String, String>> pendingApprovals = [
      {
        'type': 'Solicitação de Manutenção',
        'details': 'Veículo ABC-1234: Troca de óleo e filtros.',
        'requester': 'Por: João Silva (Motorista)',
      },
      {
        'type': 'Pedido de Reembolso',
        'details': 'Abastecimento emergencial - R\$ 150,00',
        'requester': 'Por: Maria Souza (Motorista)',
      },
      {
        'type': 'Ajuste de Rota',
        'details': 'Desvio de rota para cliente prioritário.',
        'requester': 'Por: Carlos Lima (Logística)',
      },
    ];

    // Se a lista estiver vazia (no futuro)
    if (pendingApprovals.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma aprovação pendente.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    // 2. CONSTRUÇÃO DA LISTA
    return ListView.builder(
      // Padding em volta da lista inteira
      padding: const EdgeInsets.all(16.0),

      // Quantos itens a lista terá
      itemCount: pendingApprovals.length,

      // Como construir cada item
      itemBuilder: (context, index) {
        final item = pendingApprovals[index];

        // Chamamos o nosso widget helper para construir o cartão
        return _buildApprovalCard(
          context: context,
          title: item['type']!,
          subtitle: item['details']!,
          requester: item['requester']!,
          onApprove: () {
            print('Aprovando item: ${item['type']}');
            // Lógica de aprovação (ex: remover item da lista)
          },
          onReject: () {
            print('Recusando item: ${item['type']}');
            // Lógica de recusa
          },
        );
      },
    );
  }

  // --- 3. WIDGET HELPER PARA O CARTÃO DE APROVAÇÃO ---
  Widget _buildApprovalCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String requester,
    required VoidCallback onApprove,
    required VoidCallback onReject,
  }) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Alinha o texto à esquerda
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Ícone e Título ---
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
                const SizedBox(width: 12.0),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),

            // --- Detalhes ---
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8.0),

            // --- Solicitante ---
            Text(
              requester,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),

            // Divisor
            const Divider(height: 24.0, thickness: 1.0),

            // --- 4. BOTÕES DE AÇÃO ---
            Row(
              // Coloca os botões no final (à direita)
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Botão Recusar (TextButton para menos destaque)
                TextButton(
                  onPressed: onReject,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Recusar'),
                ),
                const SizedBox(width: 8.0),

                // Botão Aprovar (ElevatedButton para mais destaque)
                ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Aprovar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}