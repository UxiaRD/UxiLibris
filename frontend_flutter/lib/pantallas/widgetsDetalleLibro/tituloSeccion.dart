import 'package:flutter/material.dart';

class TituloSeccion extends StatelessWidget {
  final String texto;
  const TituloSeccion(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}