import 'dart:io';

import 'package:flutter/material.dart';

class PortadaDetalle extends StatelessWidget {
  final String rutaImagen;
  const PortadaDetalle({super.key, required this.rutaImagen});

  @override
  Widget build(BuildContext context) {
    const double w = 150;
    const double h = 220;
    final fallback = Image.asset(
      'assets/images/fondos/libro.png',
      fit: BoxFit.cover, width: w, height: h,
    );
    Widget img;
    if (rutaImagen.startsWith('http')) {
      img = Image.network(rutaImagen, fit: BoxFit.cover, width: w, height: h,
          errorBuilder: (_, _, _) => fallback);
    } else if (rutaImagen.startsWith('assets/')) {
      img = Image.asset(rutaImagen, fit: BoxFit.cover, width: w, height: h);
    } else {
      img = Image.file(File(rutaImagen), fit: BoxFit.cover, width: w, height: h,
          errorBuilder: (_, _, _) => fallback);
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: img),
    );
  }
}