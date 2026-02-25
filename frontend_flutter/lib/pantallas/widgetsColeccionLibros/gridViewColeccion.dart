import 'package:flutter/material.dart';
import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/pantallas/gestionLibro.dart';
import 'package:frontend_flutter/pantallas/widgetsColeccionLibros/cardLibro.dart';

class GridColeccion extends StatelessWidget {
  final Libreria librosPantalla;
  final VoidCallback alCambiar; // Para avisar a la pantalla principal

  const GridColeccion({
    super.key,
    required this.librosPantalla,
    required this.alCambiar,
  });

  @override
  Widget build(BuildContext context) {
    /* El expanded es imprescindible para darle un tamaño a la cuadricula
    independiente de la barra de busqueda*/
    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          // Sirve para que los libros se ajusten en función del tamaño de pantalla
          maxCrossAxisExtent:
              150, // Cada libro medirá como mucho 150 píxeles de ancho
          crossAxisSpacing: 15, // Espacio horizontal entre libros
          mainAxisSpacing: 15, // Espacio vertical entre libros
          childAspectRatio: 0.60, // Proporción de la portada (alto > ancho)
        ),
        itemCount: librosPantalla.obtenerTodos().length,

        itemBuilder: (context, index) {
          final libro = librosPantalla.obtenerTodos()[index];
          // GestureDetector es necesario para abrir la pantalla de edición del libro cuando haces clic en el
          return GestureDetector(
            onTap: () async {
              // Se navega a la pantalla de edición y se espera el resultado
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PantallaGestionLibro(libroExistente: libro),
                ),
              );
              alCambiar(); // Refrescamos al volver de editar
            },

            child: Cardlibro(
              rutaImagen: libro.rutaImagen,
              titulo: libro.titulo,
              puntuacion: libro.puntuacion,
            ),
          );
        },
      ),
    );
  }
}
