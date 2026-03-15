import 'package:flutter/material.dart';
import 'package:frontend_flutter/decoraciones/fondoBase.dart';
import 'package:frontend_flutter/pantallas/gestionLibro.dart';
import 'package:frontend_flutter/utilidades/botonMetodoCarga.dart';
import 'package:frontend_flutter/utilidades/formularioLibro.dart';

class SeleccionMetodoCarga extends StatelessWidget {
  const SeleccionMetodoCarga({super.key});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text("Añadir a UxiLibris")),
      body: FondoBase(
        rutaImagen: 'assets/images/fondos/eleccionAdd.png',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BotonMetodoCarga(
                titulo: "Añadir Manualmente",
                subtitulo: "Introduce los detalles de tu libro paso a paso",
                rutaImagen: "assets/images/ilustraciones/registroManual.png",
                colorTexto: colores.onPrimary,
                colorFondo:
                    colores.primary, // Color sólido para resaltar texto blanco
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaGestionLibro(),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              BotonMetodoCarga(
                titulo: "Escanear ISBN",
                subtitulo:
                    "Escanea el código de barras y deja que nosotros lo busquemos",
                rutaImagen:
                    "assets/images/ilustraciones/registroAutomatico.png",
                colorTexto: colores.primary,
                colorFondo: colores.secondary,
                onTap: () => _mostrarProximamente(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarProximamente(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Funcionalidad de escaneo próximamente")),
    );
  }
}
