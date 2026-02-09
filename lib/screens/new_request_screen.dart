import 'package:flutter/material.dart';
import 'package:extensao3/widgets/custom_app_bar.dart';
import '../../services/vehicle/request_service.dart';

class NewRequestScreen extends StatefulWidget {
  const NewRequestScreen({super.key});

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores
  final _cityController = TextEditingController();
  final _reasonController = TextEditingController();
  final _processController = TextEditingController();

  DateTime? _startDateTime;
  DateTime? _endDateTime;

  // Prioridade (Exigido pelo enum do banco: LOW, NORMAL, HIGH, URGENT)
  String _selectedPriority = 'NORMAL';
  final List<String> _priorities = ['LOW', 'NORMAL', 'HIGH', 'URGENT'];

  // Finalidade (Mapeado para o Enum 'purpose' do Banco)
  String _selectedPurposeUI = 'Diligência / Investigação';
  final Map<String, String> _purposeMap = {
    'Diligência / Investigação': 'DILLIGENCE',
    'Escolta / Apoio': 'ESCORT',
    'Plantão': 'ON_CALL',
    'Outros': 'OTHER',
  };

  @override
  void dispose() {
    _cityController.dispose();
    _reasonController.dispose();
    _processController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Solicitar Viatura'),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Dados da Missão",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Preencha os dados abaixo para análise do gestor.",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  // 1. NÚMERO DO PROCESSO (Coluna process_number)
                  TextFormField(
                    controller: _processController,
                    decoration: InputDecoration(
                      labelText: 'Número do Processo / Protocolo',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.assignment),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
                  ),

                  const SizedBox(height: 16),

                  // 2. PRIORIDADE E FINALIDADE
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedPriority,
                          decoration: InputDecoration(
                            labelText: 'Prioridade',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: _priorities.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                          onChanged: (value) => setState(() => _selectedPriority = value!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedPurposeUI,
                          decoration: InputDecoration(
                            labelText: 'Finalidade',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: _purposeMap.keys.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                          onChanged: (value) => setState(() => _selectedPurposeUI = value!),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 3. DATAS (Saída e Retorno)
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateTimePicker(
                          label: "Saída",
                          selectedDate: _startDateTime,
                          onPressed: () => _pickDateTime(isStart: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateTimePicker(
                          label: "Retorno",
                          selectedDate: _endDateTime,
                          onPressed: () => _pickDateTime(isStart: false),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 4. DESTINO (Cidade e Estado fixo TO)
                  TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'Cidade de Destino',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.place),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Informe a cidade' : null,
                  ),

                  const SizedBox(height: 16),

                  // 5. DESCRIÇÃO (Coluna description)
                  TextFormField(
                    controller: _reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Descrição / Detalhes',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.description),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Descreva a missão' : null,
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

  // WIDGET AUXILIAR PARA DATA/HORA
  Widget _buildDateTimePicker({required String label, required DateTime? selectedDate, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          selectedDate == null 
            ? 'Selecionar' 
            : "${selectedDate.day}/${selectedDate.month} ${selectedDate.hour}:${selectedDate.minute.toString().padLeft(2, '0')}",
          style: TextStyle(color: selectedDate == null ? Colors.grey : Colors.black87, fontSize: 13),
        ),
      ),
    );
  }

  // PICKER DE DATA E HORA
  Future<void> _pickDateTime({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;

    setState(() {
      final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      isStart ? _startDateTime = dt : _endDateTime = dt;
    });
  }

  // ENVIO PARA API
  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_startDateTime == null || _endDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Defina as datas de saída e retorno.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // JSON alinhado com o DTO Java e SQL do banco
      final Map<String, dynamic> data = {
        "priority": _selectedPriority,               // Enum: LOW, NORMAL, HIGH, URGENT 
        "startDateTime": _startDateTime!.toIso8601String(),
        "endDateTime": _endDateTime!.toIso8601String(),
        "purpose": _purposeMap[_selectedPurposeUI],  // Enum: DILLIGENCE, ESCORT, etc 
        "processNumber": _processController.text,    // NOT NULL no banco 
        "city": _cityController.text,                // Ajustado conforme erro 400
        "state": "TO",                               // Ajustado conforme erro 400
        "description": _reasonController.text,       // NOT NULL no banco 
      };

      await RequestService.create(data);

      if (!mounted) return;
      _showSuccess();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Sucesso"),
        content: const Text("Sua solicitação foi enviada e está aguardando aprovação."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).popUntil((route) => route.isFirst),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }
}