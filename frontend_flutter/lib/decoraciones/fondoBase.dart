import 'package:flutter/material.dart';

// WIDGET que gestiona los fondos de las distintas ventanas

class FondoBase extends StatelessWidget {
  final Widget child; // Contenido de la página
  final String rutaImagen; // Ruta de la imagen de fondo

  const FondoBase({
    super.key, 
    required this.rutaImagen,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Se detecta el brillo para el filtro dinámico (colorFilter)
    final bool esClaro = Theme.of(context).brightness == Brightness.light;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(rutaImagen), // Uso de la variable que se recibe
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            esClaro 
                ? Colors.white.withValues(alpha: 0.85) 
                : Colors.black.withValues(alpha: 0.70),
            BlendMode.srcOver,
          ),
        ),
      ),

      /* El SafeArea evita que los textos o los iconos queden escondidos debajo de la cámara
      o barra de batería del movil */
      child: SafeArea(
        child: child,
      ),
    );
  }
}