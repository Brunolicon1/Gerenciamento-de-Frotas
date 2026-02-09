import 'package:flutter/material.dart';
import 'package:extensao3/widgets/custom_app_bar.dart';
import '../../../services/driver/usage_service.dart'; // Ajuste o path se necessário
import 'driver_activies.dart';

class CheckInScreen extends StatefulWidget {
  final dynamic activity; // Recebe o objeto dinâmico da API

  const CheckInScreen({super.key, required this.activity});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kmController = TextEditingController();
  bool _isLoading = false;

  // Variáveis de Checklist (mantidas para a UI, mesmo que a API atual peça apenas KM)
  double _fuelLevel = 0.5;
  bool _pneusOk = true;
  bool _luzesOk = true;
  bool _sireneOk = true;
  bool _documentosOk = true;
  final List<String> _photos = [];

  @override
  void dispose() {
    _kmController.dispose();
    super.dispose();
  }

  // Função de Envio Real para a API
  Future<void> _submitCheckIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Limpa a string da KM e converte para Inteiro
        int km = int.parse(_kmController.text.replaceAll('.', '').replaceAll(',', ''));

        // Chama o service: /usages/{id}/check-in
        // Note: activity['id'] deve ser o ID da tabela vehicle_usage
        await UsageService.checkIn(widget.activity['id'], km);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Check-in realizado! Boa viagem."),
            backgroundColor: Colors.green,
          ),
        );

        // Volta para a lista de atividades limpando a pilha
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DriverActivitiesScreen()),
          (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao realizar check-in: $e"), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Vistoria de Saída'),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildVehicleHeader(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("1. Quilometragem Atual", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _kmController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Digite a KM do painel',
                            suffixText: 'Km',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.speed),
                          ),
                          validator: (value) => (value == null || value.isEmpty) ? 'Informe a quilometragem.' : null,
                        ),
                        const SizedBox(height: 24),
                        
                        // Componentes de UI mantidos para garantir a vistoria visual do motorista
                        _buildFuelSlider(),
                        const SizedBox(height: 24),
                        _buildChecklist(),
                        const SizedBox(height: 24),
                        _buildPhotoSection(),
                        
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _submitCheckIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("CONFIRMAR RETIRADA", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildVehicleHeader() {
    // Acessando dados do mapa retornado pela API
    final vehicle = widget.activity['vehicle'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.blue.shade800,
      child: Column(
        children: [
          const Icon(Icons.directions_car, size: 50, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            "${vehicle['model']} - ${vehicle['value']}", // 'value' é a placa no seu SQL
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text("Vistoria de Retirada", style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildFuelSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("2. Nível de Combustível", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Vazio", style: TextStyle(color: Colors.red)),
                  Text("${(_fuelLevel * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Text("Cheio", style: TextStyle(color: Colors.green)),
                ],
              ),
              Slider(
                value: _fuelLevel,
                onChanged: (v) => setState(() => _fuelLevel = v),
                activeColor: _fuelLevel < 0.2 ? Colors.red : Colors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChecklist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("3. Itens Obrigatórios", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
          child: Column(
            children: [
              SwitchListTile(title: const Text("Pneus Calibrados"), value: _pneusOk, onChanged: (v) => setState(() => _pneusOk = v)),
              SwitchListTile(title: const Text("Luzes / Faróis"), value: _luzesOk, onChanged: (v) => setState(() => _luzesOk = v)),
              SwitchListTile(title: const Text("Sirene e Giroflex"), value: _sireneOk, onChanged: (v) => setState(() => _sireneOk = v)),
              SwitchListTile(title: const Text("Documentos"), value: _documentosOk, onChanged: (v) => setState(() => _documentosOk = v)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("4. Registro de Avarias", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextButton.icon(onPressed: () => setState(() => _photos.add("img")), icon: const Icon(Icons.camera_alt), label: const Text("Foto")),
          ],
        ),
        if (_photos.isEmpty) 
          const Text("Nenhuma avaria registrada.", style: TextStyle(color: Colors.grey, fontSize: 12))
        else
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _photos.length,
              itemBuilder: (ctx, i) => Container(
                width: 80, margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.image),
              ),
            ),
          ),
      ],
    );
  }
}