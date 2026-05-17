import 'package:flutter/material.dart';
import 'package:frontend_flutter/modelo/libro.dart';

class CardResultadoBusqueda extends StatelessWidget {
  final Libro libro;
  final VoidCallback onTap;

  const CardResultadoBusqueda({
    super.key,
    required this.libro,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: libro.rutaImagen.startsWith('http')
                    ? Image.network(
                        libro.rutaImagen,
                        width: 56,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _portadaVacia(colores),
                      )
                    : Image.asset(
                        'assets/images/fondos/libro.png',
                        width: 56,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      libro.titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (libro.autorNombre.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        libro.autorNombre,
                        style: TextStyle(
                          color: colores.onSurfaceVariant,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (libro.sagaNombre != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        libro.sagaNombre!,
                        style: TextStyle(color: colores.primary, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colores.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _portadaVacia(ColorScheme colores) => Container(
        width: 56,
        height: 80,
        color: colores.surfaceContainerHighest,
        child: Icon(Icons.book, color: colores.onSurfaceVariant, size: 28),
      );
}