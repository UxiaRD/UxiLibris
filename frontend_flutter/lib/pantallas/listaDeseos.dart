import 'package:flutter/material.dart';
import 'package:frontend_flutter/controladores/coleccionController.dart';
import 'package:frontend_flutter/decoraciones/fondoBase.dart';
import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/pantallas/seleccionMetodoCarga.dart';
import 'package:frontend_flutter/pantallas/widgetsColeccionLibros/gridViewColeccion.dart';
import 'package:frontend_flutter/utilidades/drawerPrincipal.dart';

/// Pantalla que muestra la lista de libros con estado 'deseo' ordenada alfabéticamente.
class PantallaListaDeseos extends StatefulWidget {
  const PantallaListaDeseos({super.key});

  @override
  State<PantallaListaDeseos> createState() => _PantallaListaDeseosState();
}

class _PantallaListaDeseosState extends State<PantallaListaDeseos> {
  bool _estaCargando = true;
  late Libreria _librosDeseo = Libreria(libros: []);

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  /// Carga todos los libros y filtra los que tienen estado 'deseo'.
  Future<void> _cargar() async {
    setState(() => _estaCargando = true);
    try {
      await ColeccionController.cargarLibros();
      _aplicarFiltro();
    } catch (_) {
    } finally {
      if (mounted) setState(() => _estaCargando = false);
    }
  }

  /// Extrae y ordena alfabéticamente los libros con estado 'deseo' de la lista global.
  void _aplicarFiltro() {
    final deseos =
        Libreria.todosLosLibros
            .where((l) => l.estado == EstadoLibro.deseo)
            .toList()
          ..sort(
            (a, b) => a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase()),
          );
    _librosDeseo = Libreria(libros: deseos);
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Lista de Deseos'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      drawer: const DrawerPrincipal(pantallaActual: PantallaDrawer.deseos),
      body: FondoBase(
        rutaImagen: 'assets/images/fondos/fondoDeseos.png',
        child: _estaCargando
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _cargar,
                child: _librosDeseo.obtenerTodos().isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite_border_rounded,
                              size: 72,
                              color: colores.outlineVariant,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tu lista de deseos está vacía.\n¡Añade libros que quieras leer!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colores.onSurfaceVariant),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: GridColeccion(
                          librosPantalla: _librosDeseo,
                          alCambiar: () {
                            _aplicarFiltro();
                            setState(() {});
                          },
                        ),
                      ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const SeleccionMetodoCarga(estadoInicial: EstadoLibro.deseo),
            ),
          );
          await _cargar();
        },
        backgroundColor: colores.primary,
        tooltip: 'Añadir a lista de deseos',
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
