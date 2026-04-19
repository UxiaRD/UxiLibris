import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend_flutter/modelo/libro.dart';

const Color _colorDigital = Color(0xFF7B2FBE);

class Cardlibro extends StatelessWidget {
  final String rutaImagen;
  final String titulo;
  final double puntuacion;
  final FormatoLibro formato;

  const Cardlibro({
    super.key,
    required this.rutaImagen,
    required this.titulo,
    required this.puntuacion,
    this.formato = FormatoLibro.fisico,
  });

  // El método _buildImagen va aquí dentro, como método PRIVADO del propio
  // widget. No hace falta un archivo aparte ni pasarlo como children.
  // Se llama directamente desde el build() igual que cualquier otro método.
  //
  // La lógica es:
  //   1. Si la ruta empieza por 'assets/' → Image.asset  (bundle de la app)
  //   2. Si no                            → Image.file   (galería / disco)
  //      con un errorBuilder de seguridad por si el archivo fue borrado.
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

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: esDigital
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: _colorDigital, width: 2),
            )
          : null,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildImagen(),
                if (esDigital)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: _colorDigital.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Icon(
                        Icons.tablet_android_rounded,
                        color: Colors.white,
                        size: 13,
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
                  titulo, // Se saca el título del objeto
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (starIndex) {
                    return Icon(
                      starIndex < puntuacion
                          ? Icons.star
                          : Icons.star_border, // Se saca la puntuacion
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
