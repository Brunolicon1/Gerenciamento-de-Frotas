import 'package:flutter/material.dart';
import 'package:extensao3/widgets/custom_app_bar.dart';
import 'package:extensao3/screens/trip_details_screen.dart';
import '../services/driver/usage_service.dart';
import '../models/vehicle/vehicle_usage_model.dart';
import 'package:intl/intl.dart'; // Adicione intl no seu pubspec.yaml

class DriverActivitiesScreen extends StatefulWidget {
  const DriverActivitiesScreen({super.key});

  @override
  State<DriverActivitiesScreen> createState() => _DriverActivitiesScreenState();
}

class _DriverActivitiesScreenState extends State<DriverActivitiesScreen> {
  DateTime _selectedDate = DateTime.now();
  List<VehicleUsage> _allActivities = [];
  List<VehicleUsage> _filteredActivities = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

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
          _applyFilters(); // Aplica filtros iniciais
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

  // Lógica de filtro combinada (Data + Busca Texto)
  void _applyFilters() {
    setState(() {
      _filteredActivities = _allActivities.where((usage) {
        final matchesDate = _isSameDay(usage.usageStart.toLocal(), _selectedDate);
        final query = _searchController.text.toLowerCase();
        final matchesSearch = usage.vehicle.make.toLowerCase().contains(query) ||
            usage.vehicle.model.toLowerCase().contains(query) ||
            usage.vehicle.licensePlate.toLowerCase().contains(query) ||
            usage.status.toLowerCase().contains(query);

        return matchesDate && matchesSearch;
      }).toList();
    });
  }

  bool _isSameDay(DateTime d1, DateTime d2) =>
      d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Minhas Viagens'),
      body: Column(
        children: [
          _buildEnhancedHeader(),
          _buildSearchField(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredActivities.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadActivities,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredActivities.length,
                          itemBuilder: (context, index) {
                            final activity = _filteredActivities[index];
                            return _buildTimelineCard(activity, index == 0);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // Campo de busca moderno
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => _applyFilters(),
        decoration: InputDecoration(
          hintText: "Buscar por veículo, placa ou status...",
          prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  // Cabeçalho com Calendário Horizontal Responsivo
  Widget _buildEnhancedHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM, yyyy').format(_selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_month, color: Colors.blueAccent),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                      _applyFilters();
                    }
                  },
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16),
              itemCount: 30, // Mostra 30 dias a partir de hoje
              itemBuilder: (ctx, i) {
                final date = DateTime.now().add(Duration(days: i - 3)); // Começa 3 dias atrás
                final isSelected = _isSameDay(date, _selectedDate);
                
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDate = date);
                    _applyFilters();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 65,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blueAccent : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.blueAccent : Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(date).toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? Colors.white70 : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 20,
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
          ),
        ],
      ),
    );
  }

  // Card de Missão Estilo Timeline
  Widget _buildTimelineCard(VehicleUsage usage, bool isHero) {
    final bool isStarted = usage.status == "STARTED";
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TripDetailsScreen(activity: usage))),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: isHero && isStarted ? Colors.blueAccent : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Indicador de Status Lateral
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: isStarted ? Colors.orange : Colors.blue,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('HH:mm').format(usage.usageStart),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isHero && isStarted ? Colors.white : Colors.black54,
                              ),
                            ),
                            _buildStatusBadge(usage.status, isHero && isStarted),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "${usage.vehicle.make} ${usage.vehicle.model}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isHero && isStarted ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.tag, size: 14, color: isHero && isStarted ? Colors.white70 : Colors.grey),
                            Text(
                              " Placa: ${usage.vehicle.licensePlate}",
                              style: TextStyle(
                                color: isHero && isStarted ? Colors.white70 : Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isHero && isStarted ? Colors.white70 : Colors.grey.shade300,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isInverse) {
    Color color = status == "STARTED" ? Colors.orange : Colors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isInverse ? Colors.white.withOpacity(0.2) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
          color: isInverse ? Colors.white : color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          Icon(Icons.directions_bus_filled_outlined, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 20),
          const Text(
            "Nenhuma missão encontrada",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          const Text("Tente selecionar outra data ou termo de busca."),
        ],
      ),
    );
  }
}