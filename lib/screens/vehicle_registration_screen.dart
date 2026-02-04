import 'package:flutter/material.dart';
import 'package:extensao3/widgets/custom_app_bar.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  const VehicleRegistrationScreen({super.key});

  @override
  State<VehicleRegistrationScreen> createState() => _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para capturar o texto digitado
  final _plateController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _odometerController = TextEditingController();

  // Variável para o Dropdown (Select)
  String? _selectedType = 'Caracterizada (Ostensiva)';

  // Opções de tipo de viatura
  final List<String> _vehicleTypes = [
    'Caracterizada (Ostensiva)',
    'Descaracterizada (Investigação)',
    'Transporte de Presos',
    'Administrativa',
    'Motocicleta',
  ];

  @override
  void dispose() {
    // É boa prática limpar os controladores quando sair da tela
    _plateController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  // --- LÓGICA DO "FAKE SAVE" ---
  void _saveVehicle() {
    // 1. Valida se os campos estão preenchidos
    if (_formKey.currentState!.validate()) {

      // (Aqui entraria a chamada para o MockDatabase no futuro)
      // Ex: MockDatabase.addVehicle(...);

      // 2. Feedback de Sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Viatura cadastrada com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // 3. Limpar os campos para o próximo cadastro
      _formKey.currentState!.reset(); // Reseta o estado do form (erros visuais)
      _plateController.clear();
      _modelController.clear();
      _yearController.clear();
      _odometerController.clear();

      // Volta o dropdown para o valor padrão
      setState(() {
        _selectedType = 'Caracterizada (Ostensiva)';
      });

      // Opcional: Se quiser fechar a tela após salvar, use: Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Nova Viatura'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Dados do Veículo",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // 1. PLACA
              TextFormField(
                controller: _plateController,
                textCapitalization: TextCapitalization.characters, // Força maiúscula
                decoration: InputDecoration(
                  labelText: 'Placa',
                  hintText: 'Ex: MXP-1234',
                  prefixIcon: const Icon(Icons.tag),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe a placa';
                  if (value.length < 7) return 'Placa inválida';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 2. MODELO
              TextFormField(
                controller: _modelController,
                decoration: InputDecoration(
                  labelText: 'Marca / Modelo',
                  hintText: 'Ex: Mitsubishi Pajero Dakar',
                  prefixIcon: const Icon(Icons.directions_car),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) => value!.isEmpty ? 'Informe o modelo' : null,
              ),
              const SizedBox(height: 16),

              // 3. TIPO (DROPDOWN)
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Tipo de Utilização',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: _vehicleTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) => setState(() => _selectedType = value),
              ),
              const SizedBox(height: 16),

              // 4. ANO E KM (Lado a Lado)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Ano Fab.',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _odometerController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'KM Atual',
                        prefixIcon: const Icon(Icons.speed),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) => value!.isEmpty ? 'Informe a KM' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // 5. BOTÃO SALVAR
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _saveVehicle,
                  icon: const Icon(Icons.save),
                  label: const Text("SALVAR VEÍCULO", style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}