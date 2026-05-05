import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sleep_provider.dart';
import '../controllers/sleep_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/sleep_card.dart';
import '../widgets/info_tile.dart';
import '../widgets/sleep_chart.dart';
import 'history_view.dart';

class SleepView extends StatelessWidget {
  const SleepView({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    return "${hours}h ${minutes}m";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SleepProvider>();
    final isSleeping = provider.isSleeping;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitor de Sono'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Histórico',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryView()),
              );
            },
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [

              /// 🌙 TEXTO
              Text(
                isSleeping ? "Monitorando seu sono..." : "Pronto para dormir?",
                style: const TextStyle(fontSize: 26, color: Colors.white),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              /// 🛏 CARD
              SleepCard(
                child: Column(
                  children: [
                    Icon(
                      isSleeping ? Icons.nights_stay : Icons.bed,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),

                    if (isSleeping) ...[
                      const Text("Sessão atual"),
                      Text(
                        _formatDuration(provider.currentDuration),
                        style: const TextStyle(fontSize: 32),
                      ),
                    ] else ...[
                      const Text("Último sono"),
                      Text(
                        _formatDuration(provider.currentDuration),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// 🎯 CONFIGURAÇÕES (IDADE + META)
              if (!isSleeping) ...[

                /// IDADE
                SleepCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Sua idade"),
                      Slider(
                        value: provider.age.toDouble(),
                        min: 10,
                        max: 80,
                        divisions: 70,
                        label: provider.age.toString(),
                        onChanged: (value) {
                          provider.setAge(value.toInt());
                        },
                      ),
                      Text("Idade: ${provider.age} anos"),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// META DE SONO
                SleepCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Meta de sono"),
                      Slider(
                        value: provider.sleepGoal,
                        min: 4,
                        max: 12,
                        divisions: 16,
                        label: "${provider.sleepGoal}h",
                        onChanged: (value) {
                          provider.setSleepGoal(value);
                        },
                      ),
                      Text("Meta: ${provider.sleepGoal.toStringAsFixed(1)} horas"),
                      Text(
                        "Recomendado: ${SleepController.getRecommendedSleep(provider.age)}",
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// 📊 GRÁFICO
                SleepCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Últimos 7 dias"),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220,
                        child: SleepChart(
                          weeklyHistory: provider.history,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              /// ▶️ BOTÃO
              CustomButton(
                text: isSleeping ? "Acordar" : "Dormir",
                icon: isSleeping ? Icons.wb_sunny : Icons.nightlight_round,
                color: isSleeping ? Colors.orange : Colors.indigo,
                onPressed: () {
                  isSleeping
                      ? provider.endSleep()
                      : provider.startSleep();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}