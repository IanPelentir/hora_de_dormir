import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/sleep_model.dart';

class SleepChart extends StatelessWidget {
  final List<SleepModel> weeklyHistory;

  const SleepChart({
    super.key,
    required this.weeklyHistory,
  });

  @override
  Widget build(BuildContext context) {
    /// Garante até 7 dias
    final List<double> data = List.generate(7, (index) {
      if (index < weeklyHistory.length) {
        return weeklyHistory[index].duration.inMinutes / 60.0;
      }
      return 0.0;
    });

    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 12,

          /// TOOLTIP
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toStringAsFixed(1)} h',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),

          /// TÍTULOS
          titlesData: FlTitlesData(
            show: true,

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      days[value.toInt() % 7],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),

            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 4,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}h',
                    style: const TextStyle(
                      color: Colors.white54,
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

          /// GRID
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white24,
              strokeWidth: 1,
            ),
          ),

          /// BORDA
          borderData: FlBorderData(show: false),

          /// LINHA META
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: 8,
                color: Colors.greenAccent.withOpacity(0.6),
                strokeWidth: 2,
                dashArray: [6, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(right: 8),
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  labelResolver: (line) => 'Ideal (8h)',
                ),
              ),
            ],
          ),

          /// BARRAS
          barGroups: List.generate(7, (index) {
            final value = data[index];

            final isGoodSleep = value >= 7 && value <= 9;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: value,
                  color: isGoodSleep
                      ? Colors.indigoAccent
                      : Colors.deepPurpleAccent,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 12,
                    color: Colors.white12,
                  ),
                ),
              ],
            );
          }),
        ),

        swapAnimationDuration: const Duration(milliseconds: 800),
        swapAnimationCurve: Curves.easeInOut,
      ),
    );
  }
}