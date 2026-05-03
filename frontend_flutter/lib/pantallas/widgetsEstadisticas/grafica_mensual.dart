import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GraficaMensual extends StatelessWidget {
  final Map<int, int> datos;
  final ColorScheme colores;

  const GraficaMensual({super.key, required this.datos, required this.colores});

  @override
  Widget build(BuildContext context) {
    final maxVal = datos.values.isEmpty
        ? 1
        : datos.values.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (maxVal + 1).toDouble(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.black87,
              getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                '${rod.toY.toInt()}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: maxVal <= 3 ? 1 : null,
                getTitlesWidget: (v, _) => v % 1 == 0 && v > 0
                    ? Text(
                        '${v.toInt()}',
                        style: TextStyle(fontSize: 10, color: colores.outline),
                      )
                    : const SizedBox(),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  const meses = [
                    'E', 'F', 'M', 'A', 'M', 'J',
                    'J', 'A', 'S', 'O', 'N', 'D',
                  ];
                  final i = v.toInt();
                  if (i < 0 || i >= 12) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      meses[i],
                      style: TextStyle(fontSize: 10, color: colores.outline),
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
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: colores.outline.withValues(alpha: 0.15),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(12, (i) {
            final count = datos[i + 1] ?? 0;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: count.toDouble(),
                  color: count > 0
                      ? colores.primary
                      : colores.primary.withValues(alpha: 0.15),
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}