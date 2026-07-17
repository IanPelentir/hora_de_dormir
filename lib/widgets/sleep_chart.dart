import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/sleep_model.dart';

/// Widget de gráfico de barras semanal — interativo e reativo.
///
/// Anima automaticamente ao receber novos dados via [weeklyHistory].
/// Suporta toque para exibir tooltip com o valor exato em horas.
class SleepChart extends StatefulWidget {
  final List<SleepModel> weeklyHistory;
  final double sleepGoal;

  const SleepChart({
    super.key,
    required this.weeklyHistory,
    this.sleepGoal = 8.0,
  });

  @override
  State<SleepChart> createState() => _SleepChartState();
}

class _SleepChartState extends State<SleepChart>
    with SingleTickerProviderStateMixin {
  int? _touchedIndex;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant SleepChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-anima quando os dados mudam
    if (oldWidget.weeklyHistory != widget.weeklyHistory ||
        oldWidget.weeklyHistory.length != widget.weeklyHistory.length) {
      _animController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Monta lista de 7 valores (horas decimais), do dia mais antigo ao mais recente.
  List<double> _buildDailyData() {
    // Agrupa por dia da semana (últimos 7 dias)
    final Map<int, double> dayMap = {};
    final now = DateTime.now();

    for (final session in widget.weeklyHistory) {
      final diff = now.difference(session.sleepStart).inDays;
      if (diff < 7) {
        // Índice 6 = hoje, 0 = 6 dias atrás
        final idx = 6 - diff;
        dayMap[idx] = (dayMap[idx] ?? 0.0) + session.durationInHours;
      }
    }

    return List.generate(7, (i) => (dayMap[i] ?? 0.0).clamp(0.0, 12.0));
  }

  /// Retorna as iniciais dos dias da semana a partir de hoje (pt-BR).
  List<String> _buildDayLabels() {
    const allDays = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
    final today = DateTime.now().weekday % 7; // 0=Dom, 1=Seg...
    return List.generate(7, (i) {
      final dayIndex = (today - 6 + i + 7) % 7;
      return allDays[dayIndex];
    });
  }

  Color _barColor(double value) {
    if (value <= 0) return Colors.white.withValues(alpha: 0.1);
    if (value >= widget.sleepGoal - 0.5 && value <= widget.sleepGoal + 1.5) {
      return Colors.indigoAccent;
    }
    if (value < widget.sleepGoal - 0.5) return Colors.deepOrangeAccent.withValues(alpha: 0.8);
    return Colors.tealAccent.shade700.withValues(alpha: 0.85);
  }

  @override
  Widget build(BuildContext context) {
    final data = _buildDailyData();
    final dayLabels = _buildDayLabels();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: AspectRatio(
        aspectRatio: 1.7,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 12,

            /// ─── INTERATIVIDADE: Toque nas barras ───
            barTouchData: BarTouchData(
              enabled: true,
              handleBuiltInTouches: true,
              touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      response == null ||
                      response.spot == null) {
                    _touchedIndex = null;
                    return;
                  }
                  _touchedIndex = response.spot!.touchedBarGroupIndex;
                });
              },
              touchTooltipData: BarTouchTooltipData(
                tooltipPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                tooltipMargin: 10,
                getTooltipColor: (group) =>
                    Colors.indigo.shade900.withValues(alpha: 0.95),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final hours = rod.toY;
                  final label = dayLabels[groupIndex];
                  if (hours <= 0) {
                    return BarTooltipItem(
                      '$label\nSem dados',
                      const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    );
                  }
                  final h = hours.floor();
                  final m = ((hours - h) * 60).round();
                  final formatted = m > 0 ? '${h}h ${m}min' : '${h}h';
                  return BarTooltipItem(
                    '$label\n$formatted',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  );
                },
              ),
            ),

            /// ─── TÍTULOS ───
            titlesData: FlTitlesData(
              show: true,

              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= dayLabels.length) {
                      return const SizedBox.shrink();
                    }
                    final isTouched = idx == _touchedIndex;
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          color: isTouched
                              ? Colors.white
                              : Colors.white60,
                          fontSize: isTouched ? 14 : 12,
                          fontWeight: isTouched
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        child: Text(dayLabels[idx]),
                      ),
                    );
                  },
                ),
              ),

              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 4,
                  reservedSize: 34,
                  getTitlesWidget: (value, meta) {
                    if (value == 0) return const SizedBox.shrink();
                    return Text(
                      '${value.toInt()}h',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),

              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),

            /// ─── GRID ───
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 4,
              getDrawingHorizontalLine: (_) => FlLine(
                color: Colors.white12,
                strokeWidth: 1,
                dashArray: [4, 4],
              ),
            ),

            borderData: FlBorderData(show: false),

            /// ─── LINHA DE META (dinâmica) ───
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: widget.sleepGoal,
                  color: Colors.greenAccent.withValues(alpha: 0.65),
                  strokeWidth: 2,
                  dashArray: [6, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.only(right: 8, bottom: 4),
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    labelResolver: (line) =>
                        'Meta (${line.y.toStringAsFixed(1)}h)',
                  ),
                ),
              ],
            ),

            /// ─── BARRAS ───
            barGroups: List.generate(7, (index) {
              final value = data[index];
              final isTouched = index == _touchedIndex;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: value,
                    color: _barColor(value),
                    width: isTouched ? 22 : 16,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: 12,
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                ],
                showingTooltipIndicators: isTouched ? [0] : [],
              );
            }),
          ),

          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        ),
      ),
    );
  }
}