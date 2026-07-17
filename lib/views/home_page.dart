import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/sleep_controller.dart';
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

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}min';
    return '${m}min';
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SleepController>();
    final goalHours = double.tryParse(_goalController.text) ?? 8.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sleep Tracker"),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchSleepRecords(),
          ),
        ],
      ),
      body: Column(
        children: [
          /// ─── FORMULÁRIO ───
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
                        onChanged: (_) => setState(() {}),
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
                        const SnackBar(
                            content: Text("Insira uma idade válida!")),
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

                    controller.addSleep(sleepDT, wakeDT, age);
                  },
                  child: const Text("SALVAR NO BACKEND"),
                ),
              ],
            ),
          ),

          const Divider(),

          /// ─── GRÁFICO SEMANAL (único, reativo) ───
          if (controller.sleepList.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "VISÃO SEMANAL",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SleepChart(
                    weeklyHistory: controller.sleepList,
                    sleepGoal: goalHours,
                  ),
                ],
              ),
            ),
            const Divider(),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "HISTÓRICO SINCRONIZADO",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
          ),

          /// ─── LISTA DE REGISTROS ───
          Expanded(
            child: controller.sleepList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: controller.sleepList.length,
                    itemBuilder: (context, index) {
                      final session = controller.sleepList[index];
                      final feedback = SleepController.getSleepQualityFeedback(
                          session.duration);

                      return ListTile(
                        leading: const Icon(Icons.nights_stay,
                            color: Colors.indigoAccent),
                        title: Text(
                          _formatDuration(session.duration),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${session.sleepStart.day.toString().padLeft(2, '0')}/"
                          "${session.sleepStart.month.toString().padLeft(2, '0')}/"
                          "${session.sleepStart.year}",
                        ),
                        trailing: Chip(
                          label: Text(
                            feedback,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor:
                              Colors.indigoAccent.withValues(alpha: 0.2),
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