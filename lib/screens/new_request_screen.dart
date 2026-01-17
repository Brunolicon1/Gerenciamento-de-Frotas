import 'package:flutter/material.dart';
import 'package:extensao3/widgets/custom_app_bar.dart';

class NewRequestScreen extends StatefulWidget {
  const NewRequestScreen({super.key});

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores e Variáveis
  final _destinController = TextEditingController();
  final _reasonController = TextEditingController();

  DateTime? _startDateTime;
  DateTime? _endDateTime;

  String _selectedVehicleType = 'Caracterizada (Ostensiva)';
  final List<String> _vehicleTypes = [
    'Caracterizada (Ostensiva)',
    'Discreta (Investigação)',
    'Rabecão / Transporte',
    'Administrativa',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Solicitar Viatura'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TÍTULO E INSTRUÇÃO
              const Text(
                "Dados da Missão",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Preencha os dados para aprovação do gestor.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // 2. TIPO DE VEÍCULO (Dropdown)
              DropdownButtonFormField<String>(
                value: _selectedVehicleType,
                decoration: InputDecoration(
                  labelText: 'Tipo de Veículo Necessário',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.directions_car),
                ),
                items: _vehicleTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) => setState(() => _selectedVehicleType = value!),
              ),

              const SizedBox(height: 16),

              // 3. DATAS (Início e Fim)
              Row(
                children: [
                  Expanded(
                    child: _buildDateTimePicker(
                      label: "Data/Hora Saída",
                      selectedDate: _startDateTime,
                      onPressed: () => _pickDateTime(isStart: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateTimePicker(
                      label: "Previsão Retorno",
                      selectedDate: _endDateTime,
                      onPressed: () => _pickDateTime(isStart: false),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 4. DESTINO
              TextFormField(
                controller: _destinController,
                decoration: InputDecoration(
                  labelText: 'Destino / Local',
                  hintText: 'Ex: Fórum Central, Bairro X...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.place),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe o destino';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // 5. JUSTIFICATIVA / FINALIDADE
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Finalidade da Missão',
                  hintText: 'Descreva brevemente o motivo da solicitação...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Descreva a finalidade';
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // 6. BOTÃO DE ENVIO
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _submitRequest,
                  icon: const Icon(Icons.send),
                  label: const Text("ENVIAR SOLICITAÇÃO", style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildDateTimePicker({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          selectedDate == null
              ? 'Selecionar'
              : "${selectedDate.day}/${selectedDate.month} às ${selectedDate.hour}:${selectedDate.minute.toString().padLeft(2, '0')}",
          style: TextStyle(
            color: selectedDate == null ? Colors.grey : Colors.black87,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // --- LÓGICA ---

  Future<void> _pickDateTime({required bool isStart}) async {
    // 1. Escolher Data
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null) return;

    // 2. Escolher Hora
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    // 3. Juntar Data + Hora
    final fullDateTime = DateTime(
        date.year, date.month, date.day, time.hour, time.minute
    );

    setState(() {
      if (isStart) {
        _startDateTime = fullDateTime;
      } else {
        _endDateTime = fullDateTime;
      }
    });
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      if (_startDateTime == null || _endDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, defina os horários de saída e retorno.')),
        );
        return;
      }

      if (_endDateTime!.isBefore(_startDateTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('O retorno não pode ser antes da saída!')),
        );
        return;
      }

      // SUCESSO!
      // Aqui chamaríamos o MockDatabase.addRequest(...)

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Solicitação Enviada"),
          content: const Text("Seu pedido foi encaminhado para aprovação do gestor."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Fecha Dialog
                Navigator.pop(context); // Fecha Tela e volta pra Home
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    }
  }
}