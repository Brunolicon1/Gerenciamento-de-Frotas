import 'package:flutter/material.dart';
import 'package:extensao3/widgets/custom_app_bar.dart'; // <--- Importe seu widget
import 'package:extensao3/feature/login-screen.dart';   // <--- Para o botão de sair funcionar

// --- MOCK MODEL (Modelo fictício apenas para esta tela) ---
class Activity {
  final String id;
  final String title; // Ex: Entrega, Coleta
  final String route; // Ex: Centro -> Zona Sul
  final DateTime time;
  final String status; // 'pendente', 'em_andamento', 'concluido'

  Activity({
    required this.id,
    required this.title,
    required this.route,
    required this.time,
    required this.status,
  });
}

class DriverActivitiesScreen extends StatefulWidget {
  const DriverActivitiesScreen({super.key});

  @override
  State<DriverActivitiesScreen> createState() => _DriverActivitiesScreenState();
}

class _DriverActivitiesScreenState extends State<DriverActivitiesScreen> {
  // 1. Variável para controlar o dia selecionado (Começa com HOJE)
  DateTime _selectedDate = DateTime.now();

  // 2. Dados Fictícios (Misturando dias diferentes)
  final List<Activity> _allActivities = [
    // ATIVIDADES DE HOJE
    Activity(
      id: '1',
      title: 'Entrega Prioritária',
      route: 'CD Logística -> Mercado Central',
      time: DateTime.now().add(const Duration(hours: 1)), // Daqui a 1 hora
      status: 'em_andamento',
    ),
    Activity(
      id: '2',
      title: 'Coleta de Materiais',
      route: 'Fábrica ABC -> CD Logística',
      time: DateTime.now().add(const Duration(hours: 3)),
      status: 'pendente',
    ),
    Activity(
      id: '3',
      title: 'Abastecimento',
      route: 'Posto Shell - Rodovia',
      time: DateTime.now().add(const Duration(hours: 5)),
      status: 'pendente',
    ),

    // ATIVIDADES DE AMANHÃ
    Activity(
      id: '4',
      title: 'Rota Matinal',
      route: 'Zona Norte Completa',
      time: DateTime.now().add(const Duration(days: 1, hours: -2)),
      status: 'pendente',
    ),
  ];

  // Helper para verificar se duas datas são o mesmo dia (ignora horas)
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    // FILTRO: Pegamos apenas as atividades do dia selecionado
    final dayActivities = _allActivities
        .where((a) => _isSameDay(a.time, _selectedDate))
        .toList();

    // ORDENAÇÃO: Garantimos que estão por ordem de horário
    dayActivities.sort((a, b) => a.time.compareTo(b.time));

    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Fundo levemente cinza
      // ... dentro do Scaffold ...
      appBar: CustomAppBar(
        title: 'Minhas Viagens',

      ),
      // ... body: Column ...
      body: Column(
        children: [
          // --- PARTE 1: CALENDÁRIO HORIZONTAL ---
          _buildDateSelector(),

          // --- PARTE 2 e 3: LISTA DE ATIVIDADES ---
          Expanded(
            child: dayActivities.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: dayActivities.length,
              itemBuilder: (context, index) {
                final activity = dayActivities[index];

                // LÓGICA DO DESTAQUE:
                // Se for a primeira atividade da lista E for hoje,
                // mostramos o Card Heroico.
                bool isFirstToday = index == 0 && _isSameDay(_selectedDate, DateTime.now());

                if (isFirstToday) {
                  return Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildHeroCard(activity),
                      const SizedBox(height: 24),
                      // Um pequeno título para separar
                      if (dayActivities.length > 1)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Próximas paradas",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                    ],
                  );
                }

                // Itens normais (Timeline)
                return _buildTimelineItem(activity, isLast: index == dayActivities.length - 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: SELETOR DE DATA HORIZONTAL ---
  Widget _buildDateSelector() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        itemCount: 14, // Mostra os próximos 14 dias
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = _isSameDay(date, _selectedDate);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 12.0),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blueAccent : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16.0),
                border: isSelected ? null : Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Dia da semana (Seg, Ter...)
                  Text(
                    _getWeekDay(date.weekday),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white70 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Dia do mês (12, 13...)
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET: CARTÃO DE DESTAQUE (HERO) ---
  Widget _buildHeroCard(Activity activity) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "EM ANDAMENTO",
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.timer, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            activity.title,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            activity.route,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade800,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text("VER DETALHES"),
          )
        ],
      ),
    );
  }

  // --- WIDGET: ITEM DA LINHA DO TEMPO (TIMELINE) ---
  Widget _buildTimelineItem(Activity activity, {bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Coluna da Esquerda (Hora + Linha)
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Text(
                  "${activity.time.hour}:${activity.time.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                // A linha vertical
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),

          // 2. O Marcador (Bolinha)
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blueAccent, width: 2),
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // 3. O Cartão da Atividade
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        activity.route,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "Nenhuma atividade para este dia.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Helper simples para dia da semana
  String _getWeekDay(int weekday) {
    const days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return days[weekday - 1];
  }
}