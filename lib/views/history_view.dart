import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sleep_provider.dart';
import '../controllers/sleep_controller.dart';
import '../widgets/sleep_card.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    // Carrega histórico do Firebase ao abrir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SleepProvider>().loadHistory();
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final weekday = weekdays[date.weekday - 1];
    return "$weekday, ${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  String _formatTime(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  Color _getQualityColor(Duration duration) {
    final hours = duration.inMinutes / 60.0;
    if (hours <= 0) return Colors.grey;
    if (hours < 6) return Colors.redAccent;
    if (hours < 7) return Colors.orangeAccent;
    if (hours <= 9) return Colors.greenAccent;
    if (hours <= 10) return Colors.lightBlueAccent;
    return Colors.purpleAccent;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SleepProvider>();
    final history = provider.history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Sono'),
        actions: [
          IconButton(
            icon: AnimatedBuilder(
              animation: _staggerController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _staggerController.value * 2 * 3.14159,
                  child: child,
                );
              },
              child: const Icon(Icons.refresh),
            ),
            onPressed: () {
              _staggerController.reset();
              _staggerController.forward();
              provider.loadHistory();
            },
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.indigoAccent),
                  SizedBox(height: 16),
                  Text(
                    "Carregando histórico...",
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            )
          : history.isEmpty
              ? _buildEmptyState()
              : _buildHistoryList(history),
    );
  }

  /// ✅ Estado vazio mais visual e acolhedor
  Widget _buildEmptyState() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bedtime_outlined,
              size: 100,
              color: Colors.indigoAccent.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            const Text(
              "Nenhum registro ainda",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                "Comece a monitorar seu sono e veja seu histórico aqui!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 14),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.nightlight_round),
              label: const Text("Registrar Sono"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.indigoAccent,
                side: const BorderSide(color: Colors.indigoAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Lista com animação escalonada
  Widget _buildHistoryList(List history) {
    return ListView.builder(
      padding: const EdgeInsets.all(24.0),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final session = history[index];
        final duration = session.duration;
        final feedback = SleepController.getSleepQualityFeedback(duration);
        final qualityColor = _getQualityColor(duration);

        // Animação escalonada para cada item
        final delay = (index * 0.1).clamp(0.0, 0.8);
        final itemAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(delay, (delay + 0.3).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
          ),
        );

        return AnimatedBuilder(
          animation: itemAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(50 * (1 - itemAnimation.value), 0),
              child: Opacity(
                opacity: itemAnimation.value,
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: SleepCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Data e badge de qualidade
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(session.sleepStart),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: qualityColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: qualityColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          feedback,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: qualityColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Duração grande
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        session.formattedDuration,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Barra visual proporcional
                      Expanded(
                        child: Container(
                          height: 6,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: (duration.inMinutes / 600.0).clamp(0.0, 1.0),
                              backgroundColor: Colors.white12,
                              valueColor: AlwaysStoppedAnimation<Color>(qualityColor),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Horários detalhados
                  Row(
                    children: [
                      Icon(Icons.nights_stay, size: 14, color: Colors.white38),
                      const SizedBox(width: 4),
                      Text(
                        "Dormiu: ${_formatTime(session.sleepStart)}",
                        style: const TextStyle(fontSize: 12, color: Colors.white38),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.wb_sunny, size: 14, color: Colors.white38),
                      const SizedBox(width: 4),
                      Text(
                        "Acordou: ${_formatTime(session.sleepEnd)}",
                        style: const TextStyle(fontSize: 12, color: Colors.white38),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}