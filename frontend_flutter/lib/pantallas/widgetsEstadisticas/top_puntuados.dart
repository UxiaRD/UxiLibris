import 'package:flutter/material.dart';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/pantallas/widgetsEstadisticas/helpers_estadisticas.dart';

class SeccionTopPuntuados extends StatelessWidget {
  final List<Libro> libros;
  final ColorScheme colores;
  final Future<void> Function(Libro) onToggleFavorito;

  const SeccionTopPuntuados({
    super.key,
    required this.libros,
    required this.colores,
    required this.onToggleFavorito,
  });

  @override
  Widget build(BuildContext context) {
    if (libros.isEmpty) return SinDatosTexto(colores: colores);

    return Column(
      children: libros.asMap().entries.map((entry) {
        final pos = entry.key + 1;
        final libro = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '$pos.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colores.primary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      libro.titulo,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      libro.autorNombre,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: colores.outline),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Estrellas(puntuacion: libro.puntuacion, colores: colores),
              GestureDetector(
                onTap: libro.id != null ? () => onToggleFavorito(libro) : null,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(
                    libro.favorito
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 18,
                    color: libro.favorito ? Colors.redAccent : colores.outline,
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