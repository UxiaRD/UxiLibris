import 'package:flutter/material.dart';

class BadgeLibro extends StatelessWidget {
  final String texto;
  final Color color;
  const BadgeLibro({super.key, required this.texto, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.55), width: 1),
      ),
      child: Text(
        texto,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}