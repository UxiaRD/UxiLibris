import 'package:flutter/material.dart';

class ScanOverlayPainter extends CustomPainter {
  final double scanProgress;
  final Color color;

  const ScanOverlayPainter({required this.scanProgress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const radius = Radius.circular(12);
    final frameW = size.width * 0.75;
    final frameH = frameW * 0.45;
    final left = (size.width - frameW) / 2;
    final top = (size.height - frameH) / 2;
    final frameRect = Rect.fromLTWH(left, top, frameW, frameH);

    canvas.drawPath(
      Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addRRect(RRect.fromRectAndRadius(frameRect, radius))
        ..fillType = PathFillType.evenOdd,
      Paint()..color = Colors.black.withValues(alpha: 0.65),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, radius),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    const double c = 22;
    final cp = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    _drawCorner(canvas, cp, Offset(left, top), c, 1, 1);
    _drawCorner(canvas, cp, Offset(left + frameW, top), c, -1, 1);
    _drawCorner(canvas, cp, Offset(left, top + frameH), c, 1, -1);
    _drawCorner(canvas, cp, Offset(left + frameW, top + frameH), c, -1, -1);

    final scanY = top + scanProgress * frameH;
    canvas.drawLine(
      Offset(left + 8, scanY),
      Offset(left + frameW - 8, scanY),
      Paint()
        ..shader = LinearGradient(
          colors: [
            color.withValues(alpha: 0),
            color.withValues(alpha: 0.9),
            color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(left, scanY, frameW, 2))
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawCorner(Canvas c, Paint p, Offset origin, double len, double dx, double dy) {
    c.drawLine(origin, origin + Offset(len * dx, 0), p);
    c.drawLine(origin, origin + Offset(0, len * dy), p);
  }

  @override
  bool shouldRepaint(ScanOverlayPainter old) => old.scanProgress != scanProgress;
}