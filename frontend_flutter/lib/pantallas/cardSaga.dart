import 'package:flutter/material.dart';
import 'package:frontend_flutter/decoraciones/appThemes.dart';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/modelo/saga.dart';
import 'package:frontend_flutter/pantallas/portadasApiladas.dart';

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

  String _subtitulo() {
    final registrados = libros.length;
    final total = saga.totalLibros;
    if (total != null && total > 0) {
      return '$registrados de $total ${total == 1 ? 'libro' : 'libros'}';
    }
    return '$registrados ${registrados == 1 ? 'libro registrado' : 'libros registrados'}';
  }

  bool _estaCompleta() {
    if (libros.isEmpty) return false;
    final total = saga.totalLibros;
    if (total != null && total > 0 && libros.length < total) return false;
    return libros.every((l) => l.estado == EstadoLibro.leido);
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final completa = _estaCompleta();

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        color: completa ? AppThemes.moradoClaro.withValues(alpha: 0.55) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              Text(
                _subtitulo(),
                style: TextStyle(color: colores.onSurfaceVariant, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}