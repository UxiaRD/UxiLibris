import 'package:flutter/material.dart';

class SelectorAnio extends StatelessWidget {
  final List<int> anios;
  final int anioSeleccionado;
  final ValueChanged<int> onChanged;
  final ColorScheme colores;

  const SelectorAnio({
    super.key,
    required this.anios,
    required this.anioSeleccionado,
    required this.onChanged,
    required this.colores,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: anios.map((anio) {
          final activo = anio == anioSeleccionado;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('$anio'),
              selected: activo,
              onSelected: (_) => onChanged(anio),
              selectedColor: colores.primary,
              labelStyle: TextStyle(
                color: activo ? Colors.white : colores.onSurface,
                fontWeight: activo ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}