import 'package:flutter/material.dart';

class LineaRoja extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withValues(alpha: 0.75)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height * 0.1), Offset(size.width, size.height * 0.9), paint);
    canvas.drawLine(Offset(size.width, size.height * 0.1), Offset(0, size.height * 0.9), paint);
  }

  @override
  bool shouldRepaint(LineaRoja _) => false;
}