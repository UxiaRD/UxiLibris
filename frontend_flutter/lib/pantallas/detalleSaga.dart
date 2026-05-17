import 'package:flutter/material.dart';
import 'package:frontend_flutter/controladores/gestionLibroController.dart';
import 'package:frontend_flutter/decoraciones/fondoBase.dart';
import 'package:frontend_flutter/modelo/almacenPropiedades.dart';
import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/modelo/saga.dart';
import 'package:frontend_flutter/pantallas/detalleLibro.dart';
import 'package:frontend_flutter/pantallas/gestionLibro.dart';
import 'package:frontend_flutter/pantallas/gestionSaga.dart';
import 'package:frontend_flutter/pantallas/widgetsColeccionLibros/cardLibro.dart';
import 'package:frontend_flutter/pantallas/widgetsDetalleSaga/lineaRoja.dart';
import 'package:frontend_flutter/pantallas/widgetsDetalleSaga/cardHueco.dart';
import 'package:frontend_flutter/servicio/ApiService.dart';
import 'package:frontend_flutter/utilidades/dialogoAsignarSaga.dart';
import 'package:frontend_flutter/utilidades/dialogos.dart';

/// Pantalla de detalle de una saga: muestra el grid de libros con sus huecos,
/// permite añadir libros nuevos o existentes, y marcar la saga como abandonada.
class PantallaDetalleSaga extends StatefulWidget {
  final Saga saga;

  const PantallaDetalleSaga({super.key, required this.saga});

  @override
  State<PantallaDetalleSaga> createState() => _PantallaDetalleSagaState();
}


class _PantallaDetalleSagaState extends State<PantallaDetalleSaga> {
  /// Devuelve los libros de esta saga desde la lista global, ordenados por volumen.
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

  /// Devuelve una lista de slots: Libro si está registrado, null si el hueco está vacío.
  /// Solo genera huecos si la saga tiene totalLibros definido.
  List<Libro?> _construirSlots(List<Libro> libros) {
    final total = widget.saga.totalLibros;
    if (total == null || total <= 0) return List<Libro?>.from(libros);

    return List.generate(total, (i) {
      final vol = (i + 1).toDouble();
      try {
        return libros.firstWhere((l) => l.numLibroSaga == vol);
      } catch (_) {
        return null;
      }
    });
  }

  /// Abre el formulario de libro pre-rellenado con el número de volumen del hueco pulsado.
  Future<void> _anadirNuevoLibro(int volumen) async {
    final prerellenado = Libro(
      titulo: '',
      autorNombre: '',
      sagaNombre: widget.saga.nombre,
      numLibroSaga: volumen.toDouble(),
      estado: EstadoLibro.pendiente,
      rutaImagen: 'assets/images/fondos/libro.png',
      almacen: AlmacenPropiedades(propiedades: []),
    );
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaGestionLibro(libroPrerellenado: prerellenado),
      ),
    );
    if (mounted) setState(() {});
  }

  /// Abre el diálogo para asignar un libro existente a esta saga.
  Future<void> _anadirLibroExistente() async {
    final cambiado = await DialogoAsignarSaga.mostrar(
      context: context,
      nombreSaga: widget.saga.nombre,
    );
    if (cambiado && mounted) setState(() {});
  }

  /// Navega al formulario de edición de saga. Si se guardaron cambios, cierra esta pantalla también.
  Future<void> _editarSaga() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PantallaGestionSaga(saga: widget.saga)),
    );
    if (resultado == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  /// Alterna el estado 'abandonada' de la saga y lo sincroniza con el servidor.
  Future<void> _toggleAbandonada() async {
    if (widget.saga.id == null) return;
    final nuevoValor = !widget.saga.abandonada;
    final ok = await ApiService.toggleAbandonadaSaga(widget.saga.id!, nuevoValor);
    if (ok && mounted) {
      setState(() => widget.saga.abandonada = nuevoValor);
    }
  }

  /// Muestra el diálogo de confirmación y elimina el libro de la saga si el usuario acepta.
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
              content: Text(
                'No se pudo eliminar el libro. Inténtalo de nuevo.',
              ),
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
    final slots = _construirSlots(libros);
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.saga.nombre),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: colores.primary),
            onSelected: (value) {
              if (value == 'editar') _editarSaga();
              if (value == 'abandonar') _toggleAbandonada();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'editar',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Editar saga'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'abandonar',
                child: ListTile(
                  leading: Icon(
                    widget.saga.abandonada ? Icons.replay : Icons.block,
                    color: widget.saga.abandonada ? Colors.green : Colors.red,
                  ),
                  title: Text(widget.saga.abandonada ? 'Retomar saga' : 'Abandonar saga'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _anadirLibroExistente,
        backgroundColor: Theme.of(context).colorScheme.primary,
        tooltip: 'Añadir libro existente',
        child: const Icon(Icons.playlist_add, color: Colors.white),
      ),
      body: FondoBase(
        rutaImagen: 'assets/images/fondos/fondoSagas.png',
        child: libros.isEmpty && (widget.saga.totalLibros == null || widget.saga.totalLibros == 0)
            ? const Center(
                child: Text('No hay libros registrados en esta saga'),
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(12, 40, 12, 12),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.60,
                  ),
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    final libro = slots[index];
                    if (libro == null) {
                      return GestureDetector(
                        onTap: () => _anadirNuevoLibro(index + 1),
                        child: CardHueco(volumen: index + 1),
                      );
                    }
                    final tachada = widget.saga.abandonada &&
                        libro.estado == EstadoLibro.pendiente;
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PantallaDetalleLibro(libro: libro, saga: widget.saga),
                          ),
                        );
                        if (mounted) setState(() {});
                      },
                      onLongPress: () => _confirmarEliminarLibro(libro),
                      child: Stack(
                        children: [
                          Cardlibro(
                            rutaImagen: libro.rutaImagen,
                            titulo: libro.titulo,
                            puntuacion: libro.puntuacion,
                            formato: libro.formato,
                            esDeseo: libro.estado == EstadoLibro.deseo,
                            favorito: libro.favorito,
                            onFavoritoToggle: libro.id == null ? null : () async {
                              libro.favorito = !libro.favorito;
                              setState(() {});
                              await ApiService.toggleFavorito(libro.id!, libro.favorito);
                            },
                          ),
                          if (tachada)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: CustomPaint(painter: LineaRoja()),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
