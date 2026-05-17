import 'package:flutter/material.dart';
import 'package:frontend_flutter/decoraciones/appThemes.dart';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/modelo/saga.dart';
import 'package:frontend_flutter/pantallas/portadasApiladas.dart';

const Color _colorDigital = Color(0xFF7B2FBE);

/// Tarjeta que representa una saga en la lista: muestra las portadas apiladas,
/// el nombre, el progreso de lectura y el estado (completada / abandonada).
class CardSaga extends StatelessWidget {
  final Saga saga;
  final List<Libro> libros;
  final VoidCallback onTap;
  final VoidCallback onEditar;

  const CardSaga({
    super.key,
    required this.saga,
    required this.libros,
    required this.onTap,
    required this.onEditar,
  });

  // Excluye libros con volumen > totalLibros para que los bonus/spin-offs
  // no afecten al progreso ni al estado de completado de la saga.
  List<Libro> get _librosEnRango {
    final total = saga.totalLibros;
    if (total == null || total <= 0) return libros;
    return libros
        .where((l) => l.numLibroSaga != null && l.numLibroSaga! <= total)
        .toList();
  }

  /// Genera el texto de progreso: "X de Y libros" o "X libros registrados".
  String _subtitulo() {
    final total = saga.totalLibros;
    final registrados = _librosEnRango.length;
    if (total != null && total > 0) {
      return '$registrados de $total ${total == 1 ? 'libro' : 'libros'}';
    }
    return '$registrados ${registrados == 1 ? 'libro registrado' : 'libros registrados'}';
  }

  bool get _todosDigitales =>
      libros.isNotEmpty &&
      libros.every((l) => l.formato == FormatoLibro.digital);

  /// Devuelve true si todos los libros en rango tienen estado 'leído'.
  bool _estaCompleta() {
    final total = saga.totalLibros;
    final relevantes = _librosEnRango;
    if (relevantes.isEmpty) return false;
    if (total != null && total > 0 && relevantes.length < total) return false;
    return relevantes.every((l) => l.estado == EstadoLibro.leido);
  }

  /// Devuelve el color de fondo de la tarjeta según el estado de la saga.
  Color? _colorFondo() {
    if (saga.abandonada) return Colors.red.withValues(alpha: 0.12);
    if (_estaCompleta()) return AppThemes.moradoClaro.withValues(alpha: 0.55);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        color: _colorFondo(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: saga.abandonada
              ? BorderSide(color: Colors.red.withValues(alpha: 0.4), width: 1.5)
              : _todosDigitales
                  ? const BorderSide(color: _colorDigital, width: 2)
                  : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior: portadas + botones
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: PortadasApiladas(
                      libros: libros,
                      totalLibros: saga.totalLibros,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: colores.primary),
                    onPressed: onEditar,
                    tooltip: 'Editar saga',
                    visualDensity: VisualDensity.compact,
                  ),
                  Icon(Icons.chevron_right, color: colores.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 10),
              // Título y subtítulo debajo de las portadas
              Text(
                saga.nombre,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    _subtitulo(),
                    style: TextStyle(color: colores.onSurfaceVariant, fontSize: 13),
                  ),
                  if (saga.abandonada) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Abandonada',
                        style: TextStyle(fontSize: 11, color: Colors.red),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}