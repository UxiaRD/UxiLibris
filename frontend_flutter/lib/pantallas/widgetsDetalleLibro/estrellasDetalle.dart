import 'package:flutter/material.dart';

class EstrellasDetalle extends StatelessWidget {
  final double puntuacion;
  const EstrellasDetalle({super.key, required this.puntuacion});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final llena = i + 1 <= puntuacion;
        final media = !llena && i < puntuacion;
        return Icon(
          llena
              ? Icons.star_rounded
              : media
                  ? Icons.star_half_rounded
                  : Icons.star_border_rounded,
          color: Colors.amber,
          size: 24,
        );
      }),
    );
  }
}