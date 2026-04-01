import 'package:flutter/material.dart';
import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/controladores/gestionLibroController.dart';
import 'package:frontend_flutter/utilidades/dialogos.dart';
import 'package:frontend_flutter/utilidades/actionsAppBar.dart';
import 'package:frontend_flutter/decoraciones/fondoBase.dart';
import 'package:frontend_flutter/utilidades/formularioLibro.dart';

import 'package:frontend_flutter/modelo/libro.dart';

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
  // Instanciamos la lógica
  final Libreria libreria = Libreria();

  // Variable booleana para saber si estamos editando o añadiendo
  bool get esModoEdicion => widget.libroExistente != null;

  // El problema era que la función alConfirmar del diálogo era una función
  // normal (no async), por lo que no podía usar await ni acceder a 'mounted'.
  // La solución es extraer la lógica async FUERA del callback y pasarle
  // solo una función síncrona al diálogo que llame a ese método async.
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

        child: FormularioLibro(
          libroParaEditar: widget.libroExistente ?? widget.libroPrerellenado,
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
    );
  }
}
