import 'package:flutter/material.dart';

class PantallaVaciaEstadisticas extends StatelessWidget {
  final ColorScheme colores;

  const PantallaVaciaEstadisticas({super.key, required this.colores});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 72, color: colores.outline),
          const SizedBox(height: 16),
          Text(
            'Aún no hay datos',
            style: TextStyle(fontSize: 18, color: colores.outline),
          ),
          const SizedBox(height: 8),
          Text(
            'Marca libros como leídos para\nver tus estadísticas aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colores.outline),
          ),
        ],
      ),
    );
  }
}