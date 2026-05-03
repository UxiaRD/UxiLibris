import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend_flutter/controladores/estadisticasController.dart';
import 'package:frontend_flutter/pantallas/widgetsEstadisticas/helpers_estadisticas.dart';

class GraficaComparativa extends StatelessWidget {
  final List<int> anios;
  final ColorScheme colores;

  const GraficaComparativa({
    super.key,
    required this.anios,
    required this.colores,
  });

  @override
  Widget build(BuildContext context) {
    int maxVal = 1;
    for (final anio in anios) {
      final vals = EstadisticasController.librosPorMes(anio).values;
      if (vals.isNotEmpty) {
        final m = vals.reduce((a, b) => a > b ? a : b);
        if (m > maxVal) maxVal = m;
      }
    }

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minX: 1,
          maxX: 12,
          minY: 0,
          maxY: (maxVal + 1).toDouble(),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Colors.black87,
              getTooltipItems: (spots) => spots.map((s) {
                final anio = anios[s.barIndex];
                return LineTooltipItem(
                  '$anio: ${s.y.toInt()}',
                  TextStyle(
                    color: coloresAnios[s.barIndex % coloresAnios.length],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (v, _) {
                  const meses = [
                    'E', 'F', 'M', 'A', 'M', 'J',
                    'J', 'A', 'S', 'O', 'N', 'D',
                  ];
                  final i = v.toInt() - 1;
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
          lineBarsData: anios.asMap().entries.map((entry) {
            final i = entry.key;
            final anio = entry.value;
            final datos = EstadisticasController.librosPorMes(anio);
            final color = coloresAnios[i % coloresAnios.length];
            return LineChartBarData(
              spots: List.generate(
                12,
                (m) => FlSpot((m + 1).toDouble(), (datos[m + 1] ?? 0).toDouble()),
              ),
              isCurved: true,
              curveSmoothness: 0.3,
              color: color,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                  radius: spot.y > 0 ? 3 : 0,
                  color: color,
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(show: false),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class LeyendaAnios extends StatelessWidget {
  final List<int> anios;

  const LeyendaAnios({super.key, required this.anios});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 16,
        runSpacing: 4,
        children: anios.asMap().entries.map((entry) {
          final color = coloresAnios[entry.key % coloresAnios.length];
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 16, height: 3, color: color),
              const SizedBox(width: 4),
              Text(
                '${entry.value}',
                style: TextStyle(fontSize: 11, color: color),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}