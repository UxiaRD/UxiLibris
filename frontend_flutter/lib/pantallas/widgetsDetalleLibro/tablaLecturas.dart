import 'package:flutter/material.dart';
import 'package:frontend_flutter/controladores/detalleLibroController.dart';
import 'package:frontend_flutter/modelo/lectura.dart';
import 'package:frontend_flutter/pantallas/widgetsDetalleLibro/glassCard.dart';

class TablaLecturas extends StatelessWidget {
  final List<Lectura> lecturas;
  const TablaLecturas({super.key, required this.lecturas});

  Widget _celda(String texto, {bool esEncabezado = false, bool cursiva = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
      child: Text(
        texto,
        style: TextStyle(
          color: esEncabezado ? Colors.white60 : Colors.white,
          fontSize: 13,
          fontWeight: esEncabezado ? FontWeight.w600 : FontWeight.normal,
          fontStyle: cursiva ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: FlexColumnWidth(),
          2: FlexColumnWidth(),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              ),
            ),
            children: [
              _celda('#', esEncabezado: true),
              _celda('Inicio', esEncabezado: true),
              _celda('Fin', esEncabezado: true),
            ],
          ),
          ...lecturas.asMap().entries.map((e) {
            final lec = e.value;
            return TableRow(
              children: [
                _celda('${e.key + 1}'),
                _celda(DetalleLibroController.formatDate(lec.fechaInicio)),
                _celda(
                  lec.fechaFin != null
                      ? DetalleLibroController.formatDate(lec.fechaFin)
                      : 'En curso',
                  cursiva: lec.fechaFin == null,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}