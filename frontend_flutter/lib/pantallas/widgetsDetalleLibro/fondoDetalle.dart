import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

class FondoDetalle extends StatelessWidget {
  final String? rutaFondo;
  final String rutaImagen;

  const FondoDetalle({super.key, this.rutaFondo, required this.rutaImagen});

  Widget _buildImagen() {
    final ruta = rutaFondo ?? rutaImagen;
    final fallback = Image.asset(
      'assets/images/fondos/libro.png',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
    if (ruta.startsWith('http')) {
      return Image.network(
        ruta, fit: BoxFit.cover, width: double.infinity, height: double.infinity,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    if (ruta.startsWith('assets/')) {
      return Image.asset(ruta, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    }
    return Image.file(
      File(ruta), fit: BoxFit.cover, width: double.infinity, height: double.infinity,
      errorBuilder: (_, _, _) => fallback,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: _buildImagen(),
          ),
        ),
        Positioned.fill(
          child: Container(color: Colors.black.withValues(alpha: 0.38)),
        ),
      ],
    );
  }
}