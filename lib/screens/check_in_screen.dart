import 'package:flutter/material.dart';
import 'package:extensao3/widgets/custom_app_bar.dart';
import 'package:extensao3/data/mock_database.dart';

import 'driver_activies.dart'; // Para voltar para a lista depois

class CheckInScreen extends StatefulWidget {
  final Activity activity;

  const CheckInScreen({super.key, required this.activity});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _formKey = GlobalKey<FormState>(); // Para validar o formulário
  final _kmController = TextEditingController(); // Captura a KM digitada

  // Variáveis de Estado
  double _fuelLevel = 0.5; // Começa na metade (50%)

  // Checklist de itens obrigatórios
  bool _pneusOk = true;
  bool _luzesOk = true;
  bool _sireneOk = true;
  bool _documentosOk = true;

  // Simulação de Fotos (Lista de arquivos fictícios)
  final List<String> _photos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Vistoria de Saída'),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. CABEÇALHO DO VEÍCULO
              _buildVehicleHeader(),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. HODÔMETRO (KM)
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, informe a quilometragem.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // 3. COMBUSTÍVEL (SLIDER)
                    const Text("2. Nível de Combustível", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                            onChanged: (value) {
                              setState(() {
                                _fuelLevel = value;
                              });
                            },
                            activeColor: _fuelLevel < 0.2 ? Colors.red : Colors.blue,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 4. CHECKLIST RÁPIDO
                    const Text("3. Itens Obrigatórios", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300)
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text("Pneus Calibrados"),
                            value: _pneusOk,
                            onChanged: (v) => setState(() => _pneusOk = v),
                            secondary: const Icon(Icons.circle_outlined),
                          ),
                          SwitchListTile(
                            title: const Text("Luzes / Faróis / Setas"),
                            value: _luzesOk,
                            onChanged: (v) => setState(() => _luzesOk = v),
                            secondary: const Icon(Icons.highlight),
                          ),
                          SwitchListTile(
                            title: const Text("Sirene e Giroflex"),
                            value: _sireneOk,
                            onChanged: (v) => setState(() => _sireneOk = v),
                            secondary: const Icon(Icons.campaign),
                          ),
                          SwitchListTile(
                            title: const Text("Documento da Viatura"),
                            value: _documentosOk,
                            onChanged: (v) => setState(() => _documentosOk = v),
                            secondary: const Icon(Icons.description),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 5. FOTOS DE AVARIAS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("4. Registro de Avarias", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        TextButton.icon(
                          onPressed: _simulateAddPhoto,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text("Adicionar Foto"),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Lista horizontal de fotos "tiradas"
                    _photos.isEmpty
                        ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                      ),
                      child: const Center(child: Text("Nenhuma avaria registrada.", style: TextStyle(color: Colors.grey))),
                    )
                        : SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _photos.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(8),
                                image: const DecorationImage(
                                    image: NetworkImage('https://placehold.co/100x100/png?text=Avaria'), // Imagem falsa
                                    fit: BoxFit.cover
                                )
                            ),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _photos.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 40),

                    // 6. BOTÃO FINALIZAR
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _submitCheckIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("CONFIRMAR SAÍDA", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  // Header Azul com dados do carro
  Widget _buildVehicleHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.blue.shade800,
      child: Column(
        children: [
          const Icon(Icons.directions_car, size: 50, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            "${widget.activity.vehicleModel} - ${widget.activity.vehiclePlate}",
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Vistoria de Retirada",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Função para simular a câmera
  void _simulateAddPhoto() {
    setState(() {
      _photos.add("foto_dummy_${DateTime.now().millisecondsSinceEpoch}.jpg");
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Foto adicionada com sucesso!")),
    );
  }

  // Função de Envio
  void _submitCheckIn() {
    if (_formKey.currentState!.validate()) {
      // 1. Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // 2. Simular delay de envio para o servidor
      Future.delayed(const Duration(seconds: 2), () {
        // Fecha o loading
        Navigator.pop(context);

        // 3. Mostra Sucesso e Volta para a Home
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Check-in realizado! Boa viagem."),
            backgroundColor: Colors.green,
          ),
        );

        // Volta para a tela principal (removendo telas anteriores da pilha de "detalhes")
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DriverActivitiesScreen()), // Volta pra tela do motorista
                (route) => false // Limpa tudo
        );
      });
    }
  }
}