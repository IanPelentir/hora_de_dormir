import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sleep_provider.dart';
import '../controllers/sleep_controller.dart';
import '../widgets/sleep_card.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  // Função para formatar a data (ex: 11/05/2026)
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    // Escuta as mudanças no SleepProvider
    final provider = context.watch<SleepProvider>();
    final history = provider.history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Sono'),
        actions: [
          // Botão para atualizar manualmente se necessário
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.loadHistory(),
          ),
        ],
      ),
      body: provider.isLoading 
          ? const Center(child: CircularProgressIndicator()) // Mostra carregando
          : history.isEmpty
              ? Center(
                  child: Text(
                    "Nenhum registro encontrado.",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white54,
                        ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(24.0),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    // Como o provider já faz insert(0), pegamos o index direto
                    final session = history[index];

                    // Usamos a duração calculada no modelo
                    final duration = session.duration;

                    // Busca o feedback (Ótimo, Bom, etc) via Controller
                    final feedback = SleepController.getSleepQualityFeedback(duration);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: SleepCard(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatDate(session.sleepStart),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  // ✅ AGORA USA O GETTER FORMATADO DO MODELO
                                  // Isso garante que apareça "10s" ou "5min" ou "8h"
                                  session.formattedDuration, 
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.indigoAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                feedback,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}