import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend_flutter/modelo/libro.dart';

const Color _colorDigital = Color(0xFF7B2FBE);
const Color _colorDeseo = Color(0xFFE91E8C);
const Color _colorPendienteFisico = Colors.green;

/// Tarjeta visual de un libro en la cuadrícula: portada, título, estrellas de puntuación
/// y badges de favorito, deseo y formato digital con sus colores identificativos.
class Cardlibro extends StatelessWidget {
  final String rutaImagen;
  final String titulo;
  final double puntuacion;
  final FormatoLibro formato;
  final bool esDeseo;
  final bool esPendienteFisico;
  final bool favorito;
  final VoidCallback? onFavoritoToggle;

  const Cardlibro({
    super.key,
    required this.rutaImagen,
    required this.titulo,
    required this.puntuacion,
    this.formato = FormatoLibro.fisico,
    this.esDeseo = false,
    this.esPendienteFisico = false,
    this.favorito = false,
    this.onFavoritoToggle,
  });

  /// Carga la imagen de portada desde el bundle (assets/), una URL remota o un fichero local.
  Widget _buildImagen() {
    if (rutaImagen.startsWith('assets/')) {
      return Image.asset(rutaImagen, fit: BoxFit.cover, width: double.infinity);
    }
    if (rutaImagen.startsWith('http')) {
      return Image.network(
        rutaImagen,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/fondos/libro.png',
            fit: BoxFit.cover,
            width: double.infinity,
          );
        },
      );
    }
    return Image.file(
      File(rutaImagen),
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/fondos/libro.png',
          fit: BoxFit.cover,
          width: double.infinity,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final esDigital = formato == FormatoLibro.digital;

    // Deseo > digital > físico pendiente (prioridad descendente en el borde)
    final BorderSide? borde = esDeseo
        ? const BorderSide(color: _colorDeseo, width: 2)
        : esDigital
        ? const BorderSide(color: _colorDigital, width: 2)
        : esPendienteFisico
        ? const BorderSide(color: _colorPendienteFisico, width: 2)
        : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: borde != null
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: borde,
            )
          : null,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildImagen(),
                if (esDeseo)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: _colorDeseo.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                    ),
                  ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: onFavoritoToggle,
                    child: Icon(
                      favorito ? Icons.star_rounded : Icons.star_border_rounded,
                      color: favorito ? Colors.amber : Colors.white70,
                      size: 20,
                      shadows: const [
                        Shadow(color: Colors.black54, blurRadius: 6),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              children: [
                Text(
                  titulo,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (starIndex) {
                    return Icon(
                      starIndex < puntuacion
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
