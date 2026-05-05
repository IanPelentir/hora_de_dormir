import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/sleep_controller.dart';
import '../models/sleep_model.dart';
import '../widgets/sleep_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _goalController = TextEditingController(text: "8"); // Meta padrão de 8h
  
  TimeOfDay _sleepTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 6, minute: 0);

  // Função para abrir o seletor de hora nativo
  Future<void> _pickTime(bool isSleepTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isSleepTime ? _sleepTime : _wakeTime,
    );
    if (picked != null) {
      setState(() {
        if (isSleepTime) _sleepTime = picked;
        else _wakeTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuta as mudanças no controller (Gerenciamento de Estado)
    final controller = context.watch<SleepController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sleep Tracker - Empresa Fictícia"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Área de Input Superior
          Container(
            color: Colors.indigo.withOpacity(0.1),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ageController,
                        decoration: const InputDecoration(
                          labelText: "Idade",
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _goalController,
                        decoration: const InputDecoration(
                          labelText: "Meta (h)",
                          prefixIcon: Icon(Icons.flag),
                          border: OutlineInputBorder(),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Seletores de Hora em forma de ListTile
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.nightlight_round, color: Colors.indigo),
                        title: const Text("Hora de Dormir"),
                        trailing: Text(_sleepTime.format(context), 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        onTap: () => _pickTime(true),
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: const Icon(Icons.wb_sunny, color: Colors.orange),
                        title: const Text("Hora de Acordar"),
                        trailing: Text(_wakeTime.format(context), 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        onTap: () => _pickTime(false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    final age = int.tryParse(_ageController.text) ?? 0;
                    final goal = double.tryParse(_goalController.text) ?? 8.0;

                    if (age <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Por favor, insira uma idade válida!")),
                      );
                      return;
                    }
                    
                    final now = DateTime.now();
                    DateTime sleepDT = DateTime(now.year, now.month, now.day, _sleepTime.hour, _sleepTime.minute);
                    DateTime wakeDT = DateTime(now.year, now.month, now.day, _wakeTime.hour, _wakeTime.minute);

                    // Trata caso a pessoa durma antes da meia-noite e acorde depois
                    if (wakeDT.isBefore(sleepDT)) {
                      wakeDT = wakeDT.add(const Duration(days: 1));
                    }
                    
                    final record = SleepRecord(
                      age: age,
                      sleepTime: sleepDT,
                      wakeTime: wakeDT,
                    );
                    
                    controller.addRecord(record);
                  },
                  icon: const Icon(Icons.calculate),
                  label: const Text("CALCULAR E ANALISAR", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          
          // Feedback e Histórico
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text("HISTÓRICO DE SONO", style: TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          
          Expanded(
            child: controller.records.isEmpty 
              ? const Center(child: Text("Nenhum registo disponível."))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.records.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SleepChart(record: controller.records[index]),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}