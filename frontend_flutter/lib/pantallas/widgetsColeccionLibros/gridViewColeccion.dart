import 'package:flutter/material.dart';
import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/pantallas/detalleLibro.dart';
import 'package:frontend_flutter/pantallas/widgetsColeccionLibros/cardLibro.dart';
import 'package:frontend_flutter/servicio/ApiService.dart';

/// Grid responsivo de tarjetas de libro. Cada celda mide como máximo 150 px de ancho
/// y se adapta automáticamente al tamaño de pantalla gracias a [SliverGridDelegateWithMaxCrossAxisExtent].
class GridColeccion extends StatelessWidget {
  final Libreria librosPantalla;
  final VoidCallback alCambiar;
  final ScrollController? scrollController;

  const GridColeccion({
    super.key,
    required this.librosPantalla,
    required this.alCambiar,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    /* El padre (coleccionLibros) envuelve este widget en Expanded.
       Aquí devolvemos directamente el GridView sin Expanded propio. */
    return GridView.builder(
      controller: scrollController,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 150,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.60,
      ),
      itemCount: librosPantalla.obtenerTodos().length,

      itemBuilder: (context, index) {
        final libro = librosPantalla.obtenerTodos()[index];
        return GestureDetector(
          onTap: () async {
            FocusManager.instance.primaryFocus?.unfocus();
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PantallaDetalleLibro(libro: libro),
              ),
            );
            alCambiar();
          },

          child: Cardlibro(
            rutaImagen: libro.rutaImagen,
            titulo: libro.titulo,
            puntuacion: libro.puntuacion,
            formato: libro.formato,
            esDeseo: libro.estado == EstadoLibro.deseo,
            favorito: libro.favorito,
            onFavoritoToggle: libro.id == null ? null : () async {
              libro.favorito = !libro.favorito;
              alCambiar();
              await ApiService.toggleFavorito(libro.id!, libro.favorito);
            },
          ),
        );
      },
    );
  }
}