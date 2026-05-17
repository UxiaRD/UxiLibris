import 'package:flutter/material.dart';

class FondoBase extends StatelessWidget {
  final Widget child;
  final String? rutaImagen; // null = sin imagen de fondo

  const FondoBase({
    super.key,
    this.rutaImagen,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final safeChild = SafeArea(child: child);

    if (rutaImagen == null || rutaImagen!.isEmpty) {
      return SizedBox(width: double.infinity, height: double.infinity, child: safeChild);
    }

    final bool esClaro = Theme.of(context).brightness == Brightness.light;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(rutaImagen!),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            esClaro
                ? Colors.white.withValues(alpha: 0.85)
                : Colors.black.withValues(alpha: 0.70),
            BlendMode.srcOver,
          ),
        ),
      ),
      child: safeChild,
    );
  }
}