import 'package:flutter/material.dart';
import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/utilidades/dialogos.dart';
import 'package:frontend_flutter/utilidades/actionsAppBar.dart';
import 'package:frontend_flutter/decoraciones/fondoBase.dart';
import 'package:frontend_flutter/utilidades/formularioLibro.dart';

import 'package:frontend_flutter/modelo/libro.dart';

class PantallaGestionLibro extends StatefulWidget {
  final Libro?
  libroExistente; // Si existe el libro los editamos, si no lo añadimos
  const PantallaGestionLibro({super.key, this.libroExistente});

  @override
  State<PantallaGestionLibro> createState() => _PantallaGestionLibroState();
}

class _PantallaGestionLibroState extends State<PantallaGestionLibro> {
  // Instanciamos la lógica
  final Libreria libreria = Libreria();

  // Variable booleana para saber si estamos editando o añadiendo
  bool get esModoEdicion => widget.libroExistente != null;

  // Función para borrar el libro
  void _eliminarLibro() {
    DialogosApp.confirmarEliminacion(
      context: context,
      titulo: "¿Eliminar libro?",
      contenido:
          "Esta acción no se puede deshacer. ¿Deseas quitar '${widget.libroExistente?.titulo}' de tu biblioteca?",
      alConfirmar: () {
        // Usamos la lógica de la clase Libreria que definimos antes
        libreria.eliminarLibro(widget.libroExistente!);
        Navigator.pop(context); // Vuelve a la biblioteca
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar:
          true, // Extensión del body por detrás de al appBar

      appBar: AppBar(
        // El título cambia dinámicamente
        title: Text(esModoEdicion ? "Editar Libro" : "Añadir a la Estantería"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: ActionsAppBar.obtenerAcciones(
          context,
          mostrarCerrarSesion: false,
          // Solo se pasa el método eliminar si se está en modo edición
          alEliminar: esModoEdicion ? _eliminarLibro : null,
        ),
      ),

      body: FondoBase(
        rutaImagen: 'assets/images/fondos/addLibro.png',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: FormularioLibro(
            libroParaEditar: widget.libroExistente,
            alGuardar: (libroRecibido) {
              if (esModoEdicion) {
                // LLAMADA A LÓGICA DE EDICIÓN
                libreria.editarLibro(widget.libroExistente!, libroRecibido);
                Navigator.pop(context);
              } else {
                // LLAMADA A LÓGICA DE CREACIÓN
                libreria.agregarLibro(libroRecibido);
                Navigator.pop(context);
              }
            },
          ),
        ),
      ),
    );
  }
}
