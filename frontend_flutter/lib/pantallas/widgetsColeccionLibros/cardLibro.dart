import 'package:flutter/material.dart';

class Cardlibro extends StatelessWidget {
  final String rutaImagen;
  final String titulo;
  final double puntuacion;

  const Cardlibro({
    super.key,
    required this.rutaImagen,
    required this.titulo,
    required this.puntuacion,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // La propiedad clipBehavior sirve para que los bordes curvos se vean suaves y no pixelados
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: Image.asset(
              rutaImagen, // Se saca la ruta del objeto
              fit: BoxFit.cover,
              width: double.infinity,
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
