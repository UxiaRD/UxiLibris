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
import 'package:frontend_flutter/utilidades/barraBusqueda.dart';
import 'package:frontend_flutter/utilidades/drawerPrincipal.dart';

// ── Clasificación de sagas ────────────────────────────────────────────────────

bool _sagaEstaCompleta(Saga saga, List<Libro> libros) {
  final total = saga.totalLibros;
  final relevantes = (total == null || total <= 0)
      ? libros
      : libros
            .where((l) => l.numLibroSaga != null && l.numLibroSaga! <= total)
            .toList();
  if (relevantes.isEmpty) return false;
  if (total != null && total > 0 && relevantes.length < total) return false;
  return relevantes.every((l) => l.estado == EstadoLibro.leido);
}

// ── Tipos de item para el ListView ───────────────────────────────────────────

sealed class _ListItem {}

class _HeaderItem extends _ListItem {
  final String titulo;
  final Color color;
  _HeaderItem(this.titulo, this.color);
}

class _SagaItem extends _ListItem {
  final Saga saga;
  _SagaItem(this.saga);
}

// ── Pantalla ──────────────────────────────────────────────────────────────────

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
    _busquedaController.addListener(
      () => setState(() => _textoBusqueda = _busquedaController.text),
    );
    _cargar();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final sagas = await ApiService.fetchSagasCompletas();
    sagas.sort((a, b) => a.nombre.compareTo(b.nombre));
    if (mounted) setState(() { _sagas = sagas; _cargando = false; });
  }

  List<Libro> _librosDeNombre(String nombre) {
    return Libreria.todosLosLibros
        .where((l) => l.sagaNombre == nombre)
        .toList()
      ..sort((a, b) {
        if (a.numLibroSaga == null && b.numLibroSaga == null) return 0;
        if (a.numLibroSaga == null) return 1;
        if (b.numLibroSaga == null) return -1;
        return a.numLibroSaga!.compareTo(b.numLibroSaga!);
      });
  }

  List<Saga> get _sagasFiltradas {
    if (_textoBusqueda.isEmpty) return _sagas;
    final query = _textoBusqueda.toLowerCase();
    return _sagas.where((s) => s.nombre.toLowerCase().contains(query)).toList();
  }

  /// Agrupa las sagas filtradas en tres secciones ordenadas alfabéticamente.
  List<_ListItem> _construirItems(ColorScheme colores) {
    final enLectura = <Saga>[];
    final completadas = <Saga>[];
    final abandonadas = <Saga>[];

    for (final saga in _sagasFiltradas) {
      if (saga.abandonada) {
        abandonadas.add(saga);
      } else if (_sagaEstaCompleta(saga, _librosDeNombre(saga.nombre))) {
        completadas.add(saga);
      } else {
        enLectura.add(saga);
      }
    }

    final items = <_ListItem>[];

    if (enLectura.isNotEmpty) {
      items.add(_HeaderItem('Sagas en lectura', colores.primary));
      items.addAll(enLectura.map(_SagaItem.new));
    }
    if (completadas.isNotEmpty) {
      items.add(_HeaderItem('Sagas completadas', const Color(0xFF7B2FBE)));
      items.addAll(completadas.map(_SagaItem.new));
    }
    if (abandonadas.isNotEmpty) {
      items.add(_HeaderItem('Sagas abandonadas', Colors.red));
      items.addAll(abandonadas.map(_SagaItem.new));
    }

    return items;
  }

  Future<void> _abrirFormulario([Saga? saga]) async {
    FocusScope.of(context).unfocus();
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PantallaGestionSaga(saga: saga)),
    );
    if (resultado == true) _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final items = _construirItems(colores);

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
                  BarraBusqueda(
                    controladorBusqueda: _busquedaController,
                    hintText: 'Buscar saga...',
                    onChanged: (valor) =>
                        setState(() => _textoBusqueda = valor),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _cargar,
                      child: items.isEmpty
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
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                if (item is _HeaderItem) {
                                  return _SectionHeader(
                                    titulo: item.titulo,
                                    color: item.color,
                                  );
                                }
                                final saga = (item as _SagaItem).saga;
                                final libros = _librosDeNombre(saga.nombre);
                                return CardSaga(
                                  saga: saga,
                                  libros: libros,
                                  onTap: () async {
                                    FocusScope.of(context).unfocus();
                                    final recargo = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            PantallaDetalleSaga(saga: saga),
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

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String titulo;
  final Color color;

  const _SectionHeader({required this.titulo, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Row(
        children: [
          Container(width: 4, height: 18, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}