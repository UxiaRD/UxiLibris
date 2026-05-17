import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend_flutter/modelo/libro.dart';

/// Widget que muestra las portadas de una saga apiladas en perspectiva.
/// Los huecos (null en la lista de slots) se renderizan como una tarjeta vacía con un "+".
class PortadasApiladas extends StatelessWidget {
  final List<Libro> libros;
  final int? totalLibros;

  const PortadasApiladas({super.key, required this.libros, this.totalLibros});

  static const double _bookWidth = 55.0;
  static const double _bookHeight = 82.0;
  static const double _offset = 22.0;

  // Los null representan huecos: volúmenes que aún no están registrados en la saga.
  // Ej: saga de 5 libros con solo vols. 1, 3 y 5 → [libro, null, libro, null, libro].
  List<Libro?> _construirSlots() {
    if (libros.isEmpty && (totalLibros == null || totalLibros == 0)) return [];

    final todosConVolumen = libros.every((l) => l.numLibroSaga != null);

    int maxSlots;
    if (totalLibros != null && totalLibros! > 0) {
      maxSlots = totalLibros!;
    } else if (todosConVolumen && libros.isNotEmpty) {
      maxSlots = libros
          .map((l) => l.numLibroSaga!)
          .reduce((a, b) => a > b ? a : b)
          .ceil();
    } else {
      return List<Libro?>.from(libros);
    }

    return List.generate(maxSlots, (i) {
      final vol = (i + 1).toDouble();
      try {
        return libros.firstWhere((l) => l.numLibroSaga == vol);
      } catch (_) {
        return null;
      }
    });
  }

  /// Renderiza la portada de un libro distinguiendo entre asset, URL remota y fichero local.
  Widget _buildPortada(Libro libro) {
    final ruta = libro.rutaImagen;
    Widget imagen;
    if (ruta.startsWith('assets/')) {
      imagen = Image.asset(ruta, fit: BoxFit.cover);
    } else if (ruta.startsWith('http')) {
      imagen = Image.network(
        ruta,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            Image.asset('assets/images/fondos/libro.png', fit: BoxFit.cover),
      );
    } else {
      imagen = Image.file(
        File(ruta),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            Image.asset('assets/images/fondos/libro.png', fit: BoxFit.cover),
      );
    }
    return ClipRRect(borderRadius: BorderRadius.circular(4), child: imagen);
  }

  /// Renderiza el placeholder gris para un volumen aún no registrado.
  Widget _buildHueco() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.add, color: Colors.grey, size: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slots = _construirSlots();
    final n = slots.length;
    if (n == 0) return const SizedBox(width: 55, height: 82);

    final totalWidth = _bookWidth + (n - 1) * _offset;

    return SizedBox(
      width: totalWidth,
      height: _bookHeight,
      child: Stack(
        children: [
          for (int i = n - 1; i >= 0; i--)
            Positioned(
              left: i * _offset,
              top: 0,
              bottom: 0,
              width: _bookWidth,
              child: slots[i] != null
                  ? _buildPortada(slots[i]!)
                  : _buildHueco(),
            ),
        ],
      ),
    );
  }
}