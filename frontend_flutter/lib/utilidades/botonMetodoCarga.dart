import 'package:flutter/material.dart';

class BotonMetodoCarga extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final String rutaImagen;
  final Color colorTexto;
  final Color colorFondo;
  final VoidCallback onTap;

  const BotonMetodoCarga({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.rutaImagen,
    required this.colorTexto,
    required this.colorFondo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias, // Para que la imagen respete las esquinas redondeadas
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(color: colorFondo),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.3,
                  child: Image.asset(
                    rutaImagen,
                    width: 150,
                    fit: BoxFit.contain,
                    // Fallback si el asset no existe — evita romper la tarjeta
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.image_not_supported,
                        size: 100,
                        color: Colors.white.withValues(alpha: 0.2),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorTexto,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 200,
                      child: Text(
                        subtitulo,
                        style: TextStyle(fontSize: 14, color: colorTexto),
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned(
                right: 150,
                top: 0,
                bottom: 0,
                child: Icon(Icons.arrow_forward_ios, color: Colors.white24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}