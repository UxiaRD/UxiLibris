import 'package:flutter/material.dart';
import 'package:frontend_flutter/modelo/propiedad.dart';
import 'package:frontend_flutter/pantallas/widgetsDetalleLibro/glassCard.dart';

class PropiedadesDetalle extends StatelessWidget {
  final List<Propiedad> propiedades;
  const PropiedadesDetalle({super.key, required this.propiedades});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: propiedades.map((prop) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.label_outline, size: 15, color: Colors.white54),
                const SizedBox(width: 8),
                Text(
                  '${prop.nombre}  ',
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
                Expanded(
                  child: Text(
                    prop.valor?.toString() ?? '—',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}