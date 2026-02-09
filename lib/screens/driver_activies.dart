import 'package:flutter/material.dart';
import 'package:extensao3/widgets/custom_app_bar.dart';
import 'package:extensao3/screens/trip_details_screen.dart';
import '../services/driver/usage_service.dart'; 

class DriverActivitiesScreen extends StatefulWidget {
  const DriverActivitiesScreen({super.key});

  @override
  State<DriverActivitiesScreen> createState() => _DriverActivitiesScreenState();
}

class _DriverActivitiesScreenState extends State<DriverActivitiesScreen> {
  DateTime _selectedDate = DateTime.now();
  List<dynamic> _allActivities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final data = await UsageService.getMyUsages();
      
      if (mounted) {
        setState(() {
          _allActivities = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getWeekDay(int weekday) {
    const days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final dayActivities = _allActivities.where((a) {
      final request = a['vehicleRequest'] ?? a['request'];
      if (request == null || request['startDateTime'] == null) return false;

      DateTime activityDate = DateTime.parse(request['startDateTime']).toLocal();
      return _isSameDay(activityDate, _selectedDate);
    }).toList();

    dayActivities.sort((a, b) {
       DateTime t1 = DateTime.parse((a['vehicleRequest'] ?? a['request'])['startDateTime']);
       DateTime t2 = DateTime.parse((b['vehicleRequest'] ?? b['request'])['startDateTime']);
       return t1.compareTo(t2);
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const CustomAppBar(title: 'Minhas Viagens'),
      body: Column(
        children: [
          _buildDateSelector(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : dayActivities.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadActivities,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: dayActivities.length,
                          itemBuilder: (context, index) {
                            final activity = dayActivities[index];
                            bool isFirstToday = index == 0 && _isSameDay(_selectedDate, DateTime.now());

                            if (isFirstToday) {
                              return Column(
                                children: [
                                  const SizedBox(height: 8),
                                  _buildHeroCard(activity),
                                  const SizedBox(height: 24),
                                  if (dayActivities.length > 1)
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Próximas paradas",
                                        style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                ],
                              );
                            }
                            return _buildTimelineItem(activity, isLast: index == dayActivities.length - 1);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

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
        itemCount: 14, 
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = _isSameDay(date, _selectedDate);

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
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
                  Text(
                    _getWeekDay(date.weekday),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white70 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
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

  Widget _buildHeroCard(dynamic activity) {
    final request = activity['vehicleRequest'] ?? activity['request'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade800, Colors.blue.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  (activity['status'] ?? "PENDENTE").toString().replaceAll('_', ' '),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.timer, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 16),
          Text(request['purpose'] ?? "Missão", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("Destino: ${request['destCity'] ?? 'Não informado'}", style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TripDetailsScreen(activity: activity))),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue.shade800, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: const Size(double.infinity, 50)),
            child: const Text("VER DETALHES"),
          )
        ],
      ),
    );
  }

  Widget _buildTimelineItem(dynamic activity, {bool isLast = false}) {
    final request = activity['vehicleRequest'] ?? activity['request'];
    DateTime time = DateTime.parse(request['startDateTime']).toLocal();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Text("${time.hour}:${time.minute.toString().padLeft(2, '0')}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                if (!isLast) Expanded(child: Container(width: 2, color: Colors.grey.shade300)),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 12, height: 12,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.blueAccent, width: 2), color: Colors.white),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TripDetailsScreen(activity: activity))),
              child: Container(
                margin: const EdgeInsets.only(bottom: 24.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.0), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 3))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request['purpose'] ?? "Missão", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text("${request['destCity']} - ${request['destState']}", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}