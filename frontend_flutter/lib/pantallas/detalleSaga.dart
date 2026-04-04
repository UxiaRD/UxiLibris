import 'package:flutter/material.dart';
import 'package:frontend_flutter/controladores/gestionLibroController.dart';
import 'package:frontend_flutter/decoraciones/fondoBase.dart';
import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/modelo/saga.dart';
import 'package:frontend_flutter/pantallas/gestionLibro.dart';
import 'package:frontend_flutter/pantallas/gestionSaga.dart';
import 'package:frontend_flutter/pantallas/widgetsColeccionLibros/cardLibro.dart';
import 'package:frontend_flutter/utilidades/dialogoAsignarSaga.dart';
import 'package:frontend_flutter/utilidades/dialogos.dart';

class PantallaDetalleSaga extends StatefulWidget {
  final Saga saga;

  const PantallaDetalleSaga({super.key, required this.saga});

  @override
  State<PantallaDetalleSaga> createState() => _PantallaDetalleSagaState();
}

class _PantallaDetalleSagaState extends State<PantallaDetalleSaga> {
  List<Libro> _libros() {
    return Libreria.todosLosLibros
        .where((l) => l.sagaNombre == widget.saga.nombre)
        .toList()
      ..sort((a, b) {
        if (a.numLibroSaga == null && b.numLibroSaga == null) return 0;
        if (a.numLibroSaga == null) return 1;
        if (b.numLibroSaga == null) return -1;
        return a.numLibroSaga!.compareTo(b.numLibroSaga!);
      });
  }

  Future<void> _anadirLibroExistente() async {
    final cambiado = await DialogoAsignarSaga.mostrar(
      context: context,
      nombreSaga: widget.saga.nombre,
    );
    if (cambiado && mounted) setState(() {});
  }

  Future<void> _editarSaga() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaGestionSaga(saga: widget.saga),
      ),
    );
    if (resultado == true && mounted) {
      // Volvemos a la pantalla anterior para que recargue la lista de sagas
      Navigator.pop(context, true);
    }
  }

  Future<void> _confirmarEliminarLibro(Libro libro) async {
    DialogosApp.confirmarEliminacion(
      context: context,
      titulo: '¿Eliminar libro?',
      contenido:
          "Esta acción no se puede deshacer. ¿Deseas quitar "
          "'${libro.titulo}' de tu biblioteca?",
      alConfirmar: () async {
        try {
          await GestionLibroController.eliminarLibro(libro);
          if (mounted) setState(() {});
        } catch (_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo eliminar el libro. Inténtalo de nuevo.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final libros = _libros();
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.saga.nombre),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: colores.primary),
            tooltip: 'Editar saga',
            onPressed: _editarSaga,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _anadirLibroExistente,
        backgroundColor: Theme.of(context).colorScheme.primary,
        tooltip: 'Añadir libro existente',
        child: const Icon(Icons.playlist_add, color: Colors.white),
      ),
      body: FondoBase(
        rutaImagen: 'assets/images/fondos/estanteria.png',
        child: libros.isEmpty
            ? const Center(child: Text('No hay libros registrados en esta saga'))
            : Padding(
                padding: const EdgeInsets.fromLTRB(12, 100, 12, 12),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.60,
                  ),
                  itemCount: libros.length,
                  itemBuilder: (context, index) {
                    final libro = libros[index];
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PantallaGestionLibro(libroExistente: libro),
                          ),
                        );
                        if (mounted) setState(() {});
                      },
                      onLongPress: () => _confirmarEliminarLibro(libro),
                      child: Cardlibro(
                        rutaImagen: libro.rutaImagen,
                        titulo: libro.titulo,
                        puntuacion: libro.puntuacion,
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}