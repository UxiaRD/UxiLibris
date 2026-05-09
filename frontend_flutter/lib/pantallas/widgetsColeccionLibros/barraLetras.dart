import 'package:flutter/material.dart';

class BarraLetras extends StatelessWidget {
  final List<String> letras;
  final String letraActiva;
  final void Function(String) alSeleccionar;

  const BarraLetras({
    super.key,
    required this.letras,
    required this.letraActiva,
    required this.alSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    if (letras.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: 28,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: letras.map((letra) {
          final activa = letra == letraActiva;
          return Expanded(
            child: GestureDetector(
              onTap: () => alSeleccionar(letra),
              behavior: HitTestBehavior.opaque,
              child: Center(
                child: Text(
                  letra,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: activa ? FontWeight.bold : FontWeight.normal,
                    color: activa ? colores.primary : colores.outline,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}