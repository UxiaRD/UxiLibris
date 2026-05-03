import 'package:flutter/material.dart';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/pantallas/widgetsEstadisticas/helpers_estadisticas.dart';

class SeccionFavoritos extends StatelessWidget {
  final List<Libro> favoritos;
  final ColorScheme colores;
  final Future<void> Function(Libro) onToggleFavorito;

  const SeccionFavoritos({
    super.key,
    required this.favoritos,
    required this.colores,
    required this.onToggleFavorito,
  });

  @override
  Widget build(BuildContext context) {
    if (favoritos.isEmpty) {
      return Text(
        'Aún no tienes ningún favorito marcado.',
        style: TextStyle(fontSize: 13, color: colores.outline),
      );
    }

    return Column(
      children: favoritos.map((libro) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              const Icon(Icons.favorite_rounded, size: 16, color: Colors.redAccent),
              const SizedBox(width: 8),
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
              const SizedBox(width: 8),
              Estrellas(puntuacion: libro.puntuacion, colores: colores),
              GestureDetector(
                onTap: libro.id != null ? () => onToggleFavorito(libro) : null,
                child: const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.favorite_rounded,
                    size: 18,
                    color: Colors.redAccent,
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