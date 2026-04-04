import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend_flutter/decoraciones/fondoBase.dart';
import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/modelo/saga.dart';
import 'package:frontend_flutter/pantallas/detalleSaga.dart';
import 'package:frontend_flutter/pantallas/gestionSaga.dart';
import 'package:frontend_flutter/servicio/ApiService.dart';
import 'package:frontend_flutter/utilidades/actionsAppBar.dart';

class PantallaColeccionSagas extends StatefulWidget {
  const PantallaColeccionSagas({super.key});

  @override
  State<PantallaColeccionSagas> createState() => _PantallaColeccionSagasState();
}

class _PantallaColeccionSagasState extends State<PantallaColeccionSagas> {
  List<Saga> _sagas = [];
  bool _cargando = true;
  final TextEditingController _busquedaController = TextEditingController();
  String _textoBusqueda = '';

  @override
  void initState() {
    super.initState();
    _busquedaController.addListener(() {
      setState(() => _textoBusqueda = _busquedaController.text);
    });
    _cargar();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  List<Saga> get _sagasFiltradas {
    if (_textoBusqueda.isEmpty) return _sagas;
    final query = _textoBusqueda.toLowerCase();
    return _sagas.where((s) => s.nombre.toLowerCase().contains(query)).toList();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final sagas = await ApiService.fetchSagasCompletas();
    sagas.sort((a, b) => a.nombre.compareTo(b.nombre));
    if (mounted) {
      setState(() {
        _sagas = sagas;
        _cargando = false;
      });
    }
  }

  List<Libro> _librosDeNombre(String nombre) {
    return Libreria.todosLosLibros.where((l) => l.sagaNombre == nombre).toList()
      ..sort((a, b) {
        if (a.numLibroSaga == null && b.numLibroSaga == null) return 0;
        if (a.numLibroSaga == null) return 1;
        if (b.numLibroSaga == null) return -1;
        return a.numLibroSaga!.compareTo(b.numLibroSaga!);
      });
  }

  Future<void> _abrirFormulario([Saga? saga]) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PantallaGestionSaga(saga: saga)),
    );
    if (resultado == true) _cargar();
  }

  Widget _buildDrawer(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(color: colores.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Icon(Icons.menu_book, size: 30, color: colores.primary),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Mi Biblioteca',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.library_books),
            title: const Text('Colección de libros'),
            onTap: () {
              Navigator.pop(context); // cierra drawer
              Navigator.pop(context); // vuelve a la colección
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtradas = _sagasFiltradas;

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text('Sagas'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: ActionsAppBar.obtenerAcciones(context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FondoBase(
        rutaImagen: 'assets/images/fondos/estanteria.png',
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Espacio para la AppBar transparente
                  SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top),

                  // Buscador
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: TextField(
                      controller: _busquedaController,
                      decoration: InputDecoration(
                        hintText: 'Buscar saga...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _textoBusqueda.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => _busquedaController.clear(),
                              )
                            : null,
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      ),
                    ),
                  ),

                  // Lista de sagas
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _cargar,
                      child: filtradas.isEmpty
                          ? ListView(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              children: [
                                Center(
                                  child: Text(
                                    _textoBusqueda.isNotEmpty
                                        ? 'No se encontraron sagas con ese nombre'
                                        : 'No hay sagas registradas',
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              itemCount: filtradas.length,
                              itemBuilder: (context, index) {
                                final saga = filtradas[index];
                                final libros = _librosDeNombre(saga.nombre);
                                return _CardSaga(
                                  saga: saga,
                                  libros: libros,
                                  onTap: () async {
                                    final recargo = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PantallaDetalleSaga(saga: saga),
                                      ),
                                    );
                                    if (recargo == true) {
                                      _cargar();
                                    } else {
                                      setState(() {});
                                    }
                                  },
                                  onEditar: () => _abrirFormulario(saga),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Card de cada saga ─────────────────────────────────────────────────────────

class _CardSaga extends StatelessWidget {
  final Saga saga;
  final List<Libro> libros;
  final VoidCallback onTap;
  final VoidCallback onEditar;

  const _CardSaga({
    required this.saga,
    required this.libros,
    required this.onTap,
    required this.onEditar,
  });

  String _subtitulo() {
    final registrados = libros.length;
    final total = saga.totalLibros;
    if (total != null && total > 0) {
      return '$registrados de $total ${total == 1 ? 'libro' : 'libros'}';
    }
    return '$registrados ${registrados == 1 ? 'libro registrado' : 'libros registrados'}';
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _PortadasApiladas(libros: libros, totalLibros: saga.totalLibros),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      saga.nombre,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitulo(),
                      style: TextStyle(color: colores.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit_outlined, color: colores.primary),
                onPressed: onEditar,
                tooltip: 'Editar saga',
              ),
              Icon(Icons.chevron_right, color: colores.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Portadas apiladas ─────────────────────────────────────────────────────────

class _PortadasApiladas extends StatelessWidget {
  final List<Libro> libros;
  final int? totalLibros;

  const _PortadasApiladas({required this.libros, this.totalLibros});

  static const double _bookWidth = 55.0;
  static const double _bookHeight = 82.0;
  static const double _offset = 22.0;

  List<Libro?> _construirSlots() {
    if (libros.isEmpty && (totalLibros == null || totalLibros == 0)) return [];

    final todosConVolumen = libros.every((l) => l.numLibroSaga != null);

    int maxSlots;
    if (totalLibros != null && totalLibros! > 0) {
      maxSlots = totalLibros!;
    } else if (todosConVolumen && libros.isNotEmpty) {
      maxSlots = libros
          .map((l) => l.numLibroSaga!)
          .reduce((a, b) => a > b ? a : b)
          .ceil();
    } else {
      return List<Libro?>.from(libros);
    }

    return List.generate(maxSlots, (i) {
      final vol = (i + 1).toDouble();
      try {
        return libros.firstWhere((l) => l.numLibroSaga == vol);
      } catch (_) {
        return null;
      }
    });
  }

  Widget _buildPortada(Libro libro) {
    final ruta = libro.rutaImagen;
    Widget imagen;
    if (ruta.startsWith('assets/')) {
      imagen = Image.asset(ruta, fit: BoxFit.cover);
    } else if (ruta.startsWith('http')) {
      imagen = Image.network(
        ruta,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            Image.asset('assets/images/fondos/libro.png', fit: BoxFit.cover),
      );
    } else {
      imagen = Image.file(
        File(ruta),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            Image.asset('assets/images/fondos/libro.png', fit: BoxFit.cover),
      );
    }
    return ClipRRect(borderRadius: BorderRadius.circular(4), child: imagen);
  }

  Widget _buildHueco() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.add, color: Colors.grey, size: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slots = _construirSlots();
    final n = slots.length;
    if (n == 0) return const SizedBox(width: 55, height: 82);

    final totalWidth = _bookWidth + (n - 1) * _offset;

    return SizedBox(
      width: totalWidth,
      height: _bookHeight,
      child: Stack(
        children: [
          for (int i = n - 1; i >= 0; i--)
            Positioned(
              left: i * _offset,
              top: 0,
              bottom: 0,
              width: _bookWidth,
              child: slots[i] != null
                  ? _buildPortada(slots[i]!)
                  : _buildHueco(),
            ),
        ],
      ),
    );
  }
}