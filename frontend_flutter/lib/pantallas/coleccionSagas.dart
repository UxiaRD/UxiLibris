import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend_flutter/decoraciones/fondoBase.dart';
import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/modelo/saga.dart';
import 'package:frontend_flutter/pantallas/cardSaga.dart';
import 'package:frontend_flutter/pantallas/detalleSaga.dart';
import 'package:frontend_flutter/pantallas/gestionSaga.dart';
import 'package:frontend_flutter/servicio/ApiService.dart';
import 'package:frontend_flutter/utilidades/actionsAppBar.dart';
import 'package:frontend_flutter/utilidades/drawerPrincipal.dart';

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

  final ScrollController _scrollController = ScrollController();
  String _letraActual = '';
  bool _mostrarLetra = false;
  Timer? _timerLetra;

  // Altura estimada de cada CardSaga: padding (24) + portadas (82) + gap (10) + texto (42) + margen (16)
  static const double _alturaEstimadaCard = 174.0;

  @override
  void initState() {
    super.initState();
    _busquedaController.addListener(() {
      setState(() => _textoBusqueda = _busquedaController.text);
    });
    _scrollController.addListener(_actualizarLetra);
    _cargar();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    _scrollController.dispose();
    _timerLetra?.cancel();
    super.dispose();
  }

  List<Saga> get _sagasFiltradas {
    if (_textoBusqueda.isEmpty) return _sagas;
    final query = _textoBusqueda.toLowerCase();
    return _sagas.where((s) => s.nombre.toLowerCase().contains(query)).toList();
  }

  void _actualizarLetra() {
    final filtradas = _sagasFiltradas;
    if (filtradas.isEmpty) return;

    final offset = _scrollController.offset;
    // Padding superior del ListView es 8px
    final indice = ((offset - 8) / _alturaEstimadaCard)
        .floor()
        .clamp(0, filtradas.length - 1);
    final letra = filtradas[indice].nombre[0].toUpperCase();

    _timerLetra?.cancel();
    if (_letraActual != letra || !_mostrarLetra) {
      setState(() {
        _letraActual = letra;
        _mostrarLetra = true;
      });
    }
    _timerLetra = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _mostrarLetra = false);
    });
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

  @override
  Widget build(BuildContext context) {
    final filtradas = _sagasFiltradas;
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const DrawerPrincipal(pantallaActual: PantallaDrawer.sagas),
      appBar: AppBar(
        title: const Text('Sagas'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: ActionsAppBar.obtenerAcciones(context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        backgroundColor: colores.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FondoBase(
        rutaImagen: 'assets/images/fondos/fondoSagas.png',
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
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
                        fillColor: colores.surface.withValues(alpha: 0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),

                  // Lista de sagas + indicador de letra
                  Expanded(
                    child: Stack(
                      children: [
                        RefreshIndicator(
                          onRefresh: _cargar,
                          child: filtradas.isEmpty
                              ? ListView(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    8,
                                    16,
                                    16,
                                  ),
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
                                  controller: _scrollController,
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    8,
                                    16,
                                    16,
                                  ),
                                  itemCount: filtradas.length,
                                  itemBuilder: (context, index) {
                                    final saga = filtradas[index];
                                    final libros = _librosDeNombre(saga.nombre);
                                    return CardSaga(
                                      saga: saga,
                                      libros: libros,
                                      onTap: () async {
                                        final recargo =
                                            await Navigator.push<bool>(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    PantallaDetalleSaga(
                                                      saga: saga,
                                                    ),
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

                        // Indicador de letra flotante
                        if (_letraActual.isNotEmpty)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Center(
                                child: AnimatedOpacity(
                                  opacity: _mostrarLetra ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 250),
                                  child: Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: colores.primary.withValues(
                                        alpha: 0.85,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      _letraActual,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}