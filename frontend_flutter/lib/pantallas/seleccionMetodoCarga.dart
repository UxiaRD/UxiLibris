import 'package:flutter/material.dart';
import 'package:frontend_flutter/decoraciones/fondoBase.dart';
import 'package:frontend_flutter/modelo/almacenPropiedades.dart';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/pantallas/busquedaLibros.dart';
import 'package:frontend_flutter/pantallas/gestionLibro.dart';
import 'package:frontend_flutter/utilidades/botonMetodoCarga.dart';
import 'package:frontend_flutter/pantallas/escanerISBN.dart';

const Color _colorBusqueda = Color(0xFF00695C);

class SeleccionMetodoCarga extends StatelessWidget {
  /// Cuando no es null, todos los métodos pre-rellenan el estado del libro.
  final EstadoLibro? estadoInicial;

  const SeleccionMetodoCarga({super.key, this.estadoInicial});

  Libro? get _libroBase => estadoInicial == null
      ? null
      : Libro(
          titulo: '',
          autorNombre: '',
          estado: estadoInicial!,
          rutaImagen: 'assets/images/fondos/libro.png',
          almacen: AlmacenPropiedades(propiedades: []),
        );

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text("Añadir a UxiLibris")),
      body: FondoBase(
        rutaImagen: 'assets/images/fondos/eleccionAdd.png',
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BotonMetodoCarga(
                titulo: "Añadir Manualmente",
                subtitulo: "Introduce los detalles de tu libro paso a paso",
                rutaImagen: "assets/images/ilustraciones/registroManual.png",
                colorTexto: colores.onPrimary,
                colorFondo: colores.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PantallaGestionLibro(libroPrerellenado: _libroBase),
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
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PantallaEscanerISBN(estadoInicial: estadoInicial),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              BotonMetodoCarga(
                titulo: "Buscar por título",
                subtitulo:
                    "Busca por título o autor y selecciona tu libro de los resultados",
                rutaImagen: "assets/images/ilustraciones/registroTitulo.png",
                colorTexto: colores.onPrimary,
                colorFondo: colores.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PantallaBusquedaLibros(estadoInicial: estadoInicial),
                  ),
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}
