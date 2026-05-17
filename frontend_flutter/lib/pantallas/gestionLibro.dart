import 'package:flutter/material.dart';
import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/controladores/gestionLibroController.dart';
import 'package:frontend_flutter/utilidades/dialogos.dart';
import 'package:frontend_flutter/utilidades/actionsAppBar.dart';
import 'package:frontend_flutter/decoraciones/fondoBase.dart';
import 'package:frontend_flutter/utilidades/formularioLibro.dart';

import 'package:frontend_flutter/modelo/libro.dart';

/// Pantalla para crear un libro nuevo o editar uno existente.
/// El modo se detecta automáticamente: si [libroExistente] no es null, es edición.
class PantallaGestionLibro extends StatefulWidget {
  final Libro?
  libroExistente; // Si existe el libro los editamos, si no lo añadimos
  final Libro? libroPrerellenado; // Datos del escaner sin ID
  const PantallaGestionLibro({
    super.key,
    this.libroExistente,
    this.libroPrerellenado,
  });

  @override
  State<PantallaGestionLibro> createState() => _PantallaGestionLibroState();
}

class _PantallaGestionLibroState extends State<PantallaGestionLibro> {
  final Libreria libreria = Libreria();

  bool get esModoEdicion => widget.libroExistente != null;

  /// Ejecuta la eliminación del libro en el servidor y vuelve a la pantalla anterior.
  // El callback del diálogo es síncrono (VoidCallback), así que esta lógica async
  // se extrae aquí para poder usar await y comprobar 'mounted' con seguridad.
  Future<void> _confirmarEliminacion() async {
    if (widget.libroExistente == null) return;
    try {
      await GestionLibroController.eliminarLibro(widget.libroExistente!);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo eliminar el libro. Inténtalo de nuevo.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Muestra el diálogo de confirmación y, si el usuario acepta, llama a [_confirmarEliminacion].
  void _eliminarLibro() {
    // El diálogo recibe una función SÍNCRONA (VoidCallback).
    // Esa función llama al método async de arriba con el operador 'unawaited'.
    // Así no hay conflicto de tipos y 'widget'/'context' son accesibles.
    DialogosApp.confirmarEliminacion(
      context: context,
      titulo: '¿Eliminar libro?',
      contenido:
          "Esta acción no se puede deshacer. ¿Deseas quitar "
          "'${widget.libroExistente?.titulo}' de tu biblioteca?",
      alConfirmar: () {
        // Llamamos al método async sin await (el diálogo no necesita esperar)
        _confirmarEliminacion();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: Text(esModoEdicion ? "Editar Libro" : "Añadir a la Estantería"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: ActionsAppBar.obtenerAcciones(
          context,
          alEliminar: esModoEdicion ? _eliminarLibro : null,
        ),
      ),

      body: FondoBase(
        rutaImagen: 'assets/images/fondos/addLibro.png',

        child: FormularioLibro(
          libroParaEditar: widget.libroExistente ?? widget.libroPrerellenado,
          alGuardar: (libroRecibido) {
            if (esModoEdicion) {
              libreria.editarLibro(widget.libroExistente!, libroRecibido);
            } else {
              libreria.agregarLibro(libroRecibido);
            }
            // El pop lo gestiona formularioLibro.dart con Navigator.pop(context, true)
          },
        ),
      ),
    );
  }
}
