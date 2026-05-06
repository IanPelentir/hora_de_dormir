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
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () {
                    final now = DateTime.now();

                    final sleepDT = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      _sleepTime.hour,
                      _sleepTime.minute,
                    );

                    var wakeDT = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      _wakeTime.hour,
                      _wakeTime.minute,
                    );

                    if (wakeDT.isBefore(sleepDT)) {
                      wakeDT = wakeDT.add(const Duration(days: 1));
                    }

                    /// 🔥 AGORA O CONTROLLER FAZ O RESTO
                    controller.addSleep(sleepDT, wakeDT);
                  },
                  child: const Text("Salvar sono"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "HISTÓRICO",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          Expanded(
            child: controller.sleepList.isEmpty
                ? const Center(child: Text("Sem dados ainda"))
                : ListView.builder(
                    itemCount: controller.sleepList.length,
                    itemBuilder: (context, index) {
                      final item = controller.sleepList[index];

                      return Padding(
                        padding: const EdgeInsets.all(8),
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