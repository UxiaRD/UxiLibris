import 'package:flutter/material.dart';
import 'package:frontend_flutter/modelo/lectura.dart';

class FilaLectura extends StatelessWidget {
  final int numero;
  final Lectura lectura;
  final bool puedeEliminar;
  final bool editarFinPermitido;
  final ValueChanged<DateTime> onFechaInicio;
  final ValueChanged<DateTime> onFechaFin;
  final VoidCallback onEliminar;

  const FilaLectura({
    super.key,
    required this.numero,
    required this.lectura,
    required this.puedeEliminar,
    required this.editarFinPermitido,
    required this.onFechaInicio,
    required this.onFechaFin,
    required this.onEliminar,
  });

  String _formatDate(DateTime? d) =>
      d == null ? '—' : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<DateTime?> _pickDate(BuildContext context, DateTime? initial) =>
      showDialog<DateTime>(
        context: context,
        builder: (_) => DatePickerDialog(
          initialDate: initial ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colores.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colores.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colores.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$numero',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colores.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    final d = await _pickDate(context, lectura.fechaInicio);
                    if (d != null) onFechaInicio(d);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.play_arrow_rounded, size: 14, color: colores.primary),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(lectura.fechaInicio),
                        style: TextStyle(fontSize: 13, color: colores.onSurface),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: editarFinPermitido
                      ? () async {
                          final d = await _pickDate(context, lectura.fechaFin);
                          if (d != null) onFechaFin(d);
                        }
                      : null,
                  child: Row(
                    children: [
                      Icon(
                        Icons.stop_rounded,
                        size: 14,
                        color: lectura.estaActiva ? colores.outline : colores.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        lectura.estaActiva ? 'En curso' : _formatDate(lectura.fechaFin),
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: lectura.estaActiva ? FontStyle.italic : FontStyle.normal,
                          color: lectura.estaActiva ? colores.outline : colores.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (puedeEliminar)
            IconButton(
              icon: Icon(Icons.delete_outline, size: 20, color: colores.error),
              onPressed: onEliminar,
              tooltip: 'Eliminar lectura',
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}