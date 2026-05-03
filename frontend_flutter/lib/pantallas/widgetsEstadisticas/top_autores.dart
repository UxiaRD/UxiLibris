import 'package:flutter/material.dart';
import 'package:frontend_flutter/pantallas/widgetsEstadisticas/helpers_estadisticas.dart';

class SeccionTopAutores extends StatelessWidget {
  final List<MapEntry<String, int>> autores;
  final ColorScheme colores;

  const SeccionTopAutores({
    super.key,
    required this.autores,
    required this.colores,
  });

  @override
  Widget build(BuildContext context) {
    if (autores.isEmpty) return SinDatosTexto(colores: colores);
    final maximo = autores.first.value;

    return Column(
      children: autores.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(
                width: 110,
                child: Text(
                  entry.key,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: entry.value / maximo,
                    minHeight: 14,
                    backgroundColor: colores.primary.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(colores.primary),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 20,
                child: Text(
                  '${entry.value}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colores.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}