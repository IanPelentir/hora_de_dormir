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
  final TextEditingController _goalController =
      TextEditingController(text: "8");

  TimeOfDay _sleepTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 6, minute: 0);

  @override
  void initState() {
    super.initState();
    // 💡 SOLUÇÃO PARA PERSISTÊNCIA:
    // Carrega os dados do Firebase assim que a página abre.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SleepController>().fetchSleepRecords();
    });
  }

  Future<void> _pickTime(bool isSleepTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isSleepTime ? _sleepTime : _wakeTime,
    );

    if (picked != null) {
      setState(() {
        if (isSleepTime) {
          _sleepTime = picked;
        } else {
          _wakeTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SleepController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sleep Tracker"),
        backgroundColor: Colors.indigo,
        actions: [
          // Ícone visual para indicar sincronização
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchSleepRecords(),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Idade",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _goalController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Meta (h)",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.flag),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // Botões de seleção de hora para melhorar a UX
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _pickTime(true),
                      icon: const Icon(Icons.nightlight_round),
                      label: Text("Dormi: ${_sleepTime.format(context)}"),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _pickTime(false),
                      icon: const Icon(Icons.wb_sunny),
                      label: Text("Acordei: ${_wakeTime.format(context)}"),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final age = int.tryParse(_ageController.text) ?? 0;
                    if (age <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Insira uma idade válida!")),
                      );
                      return;
                    }

                    final now = DateTime.now();
                    final sleepDT = DateTime(now.year, now.month, now.day,
                        _sleepTime.hour, _sleepTime.minute);
                    var wakeDT = DateTime(now.year, now.month, now.day,
                        _wakeTime.hour, _wakeTime.minute);

                    if (wakeDT.isBefore(sleepDT)) {
                      wakeDT = wakeDT.add(const Duration(days: 1));
                    }

                    // Agora passamos a idade para o controller salvar no Firebase com lógica
                    controller.addSleep(sleepDT, wakeDT, age);
                  },
                  child: const Text("SALVAR NO BACKEND"),
                ),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "HISTÓRICO SINCRONIZADO",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Expanded(
            child: controller.sleepList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: controller.sleepList.length,
                    itemBuilder: (context, index) {
                      // Passamos a lista para o widget de gráfico/card
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: SleepChart(
                          weeklyHistory: controller.sleepList,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}