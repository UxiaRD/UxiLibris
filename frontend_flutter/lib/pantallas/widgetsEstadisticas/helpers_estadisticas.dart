import 'package:flutter/material.dart';
import 'package:frontend_flutter/decoraciones/appThemes.dart';

const coloresAnios = [
  AppThemes.moradoPrincipal,
  Colors.orange,
  Colors.teal,
  Colors.amber,
  Colors.pinkAccent,
];

class Estrellas extends StatelessWidget {
  final double puntuacion;
  final ColorScheme colores;

  const Estrellas({super.key, required this.puntuacion, required this.colores});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final llena = i < puntuacion.floor();
        final media = !llena && i < puntuacion;
        return Icon(
          media ? Icons.star_half_rounded : Icons.star_rounded,
          size: 16,
          color: llena || media
              ? Colors.amber
              : colores.outline.withValues(alpha: 0.3),
        );
      }),
    );
  }
}

class TituloSeccion extends StatelessWidget {
  final String texto;
  final ColorScheme colores;

  const TituloSeccion({super.key, required this.texto, required this.colores});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: colores.onSurface,
      ),
    );
  }
}

class SinDatosTexto extends StatelessWidget {
  final ColorScheme colores;

  const SinDatosTexto({super.key, required this.colores});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Sin datos suficientes',
      style: TextStyle(color: colores.outline, fontSize: 13),
    );
  }
}