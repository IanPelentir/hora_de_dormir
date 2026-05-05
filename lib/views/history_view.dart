import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sleep_provider.dart';
import '../controllers/sleep_controller.dart';
import '../widgets/sleep_card.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    return "${hours}h ${minutes}m";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SleepProvider>();
    final history = provider.history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep History'),
      ),
      body: history.isEmpty
          ? Center(
              child: Text(
                "No history yet. Start sleeping!",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white54,
                    ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24.0),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final session = history[history.length - 1 - index];

                final duration = session.duration ?? Duration.zero;

                final feedback =
                    SleepController.getSleepQualityFeedback(duration);

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
                              _formatDuration(duration),
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
                            color: Colors.deepPurpleAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            feedback,
                            style: const TextStyle(
                              fontSize: 14,
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