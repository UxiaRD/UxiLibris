import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend_flutter/decoraciones/fondoBase.dart';
import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/pantallas/seleccionMetodoCarga.dart';
import 'package:frontend_flutter/utilidades/barraBusqueda.dart';
import 'package:frontend_flutter/pantallas/widgetsColeccionLibros/gridViewColeccion.dart';
import 'package:frontend_flutter/pantallas/widgetsColeccionLibros/barraLetras.dart';
import 'package:frontend_flutter/controladores/coleccionController.dart';

// WIDGET que gestiona la Colección de Libros

class PantallaColeccion extends StatefulWidget {
  final String filtro;
  const PantallaColeccion({super.key, required this.filtro});

  @override
  State<PantallaColeccion> createState() => _PantallaColeccionState();
}

class _PantallaColeccionState extends State<PantallaColeccion> {
  /*Lista de libros
  Instancia para usar los métodos de filtrado
  Al no pasarle parámetros, esta instancia se inicializa con la lista estática*/
  Libreria libreria = Libreria();

  // Lista que se mostrará en el Grid (inicialmente vacía hasta que initState ejecute el filtro)
  late Libreria librosFiltrados = Libreria(libros: []);

  /* Los TextFormField y TextField no guardan texto, necesitan un controlador que lo haga por ellos */
  final TextEditingController _controladorDeBusqueda = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  bool _estaCargando = true;
  bool _errorCarga = false;
  bool _mostrarMensajeEspera = false;
  Timer? _timerEspera;
  String _letraActiva = '';
  Map<String, int> _indicePorLetra = {};

  // Dimensiones del grid (deben coincidir con SliverGridDelegateWithMaxCrossAxisExtent)
  static const double _anchoSidebar = 28.0;
  static const double _maxAnchoCelda = 150.0;
  static const double _alturaItemGrid = _maxAnchoCelda / 0.60; // 250 px
  static const double _espaciadoGrid = 15.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_actualizarLetraActiva);
    _cargarYFiltrar();
  }

  @override
  void dispose() {
    _timerEspera?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _cargarYFiltrar() async {
    setState(() { _estaCargando = true; _errorCarga = false; _mostrarMensajeEspera = false; });
    _timerEspera?.cancel();
    _timerEspera = Timer(const Duration(seconds: 8), () {
      if (mounted && _estaCargando) setState(() => _mostrarMensajeEspera = true);
    });

    const maxIntentos = 8;
    const pausaEntreIntentos = Duration(seconds: 8);

    for (int intento = 0; intento < maxIntentos; intento++) {
      if (!mounted) return;
      try {
        await ColeccionController.cargarLibros();
        if (!mounted) return;
        _buscarLibros(_controladorDeBusqueda.text);
        _timerEspera?.cancel();
        setState(() { _estaCargando = false; _mostrarMensajeEspera = false; });
        return;
      } catch (_) {
        if (!mounted) return;
        if (intento < maxIntentos - 1) await Future.delayed(pausaEntreIntentos);
      }
    }

    _timerEspera?.cancel();
    if (mounted) setState(() { _estaCargando = false; _errorCarga = true; _mostrarMensajeEspera = false; });
  }

  @override
  void didUpdateWidget(covariant PantallaColeccion oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si el filtro que viene del padre ha cambiado (ej: de 'todos' a 'leido')
    if (oldWidget.filtro != widget.filtro) {
      _buscarLibros(_controladorDeBusqueda.text);
    }
  }

  // Función que maneja AMBOS filtros (El de pestaña y el de texto)
  void _buscarLibros(String consulta) {
    setState(() {
      // 1. Siempre partimos de la lista estática
      Libreria base = Libreria(libros: Libreria.todosLosLibros);

      // Paso 1: Filtramos por la pestaña actual (Estado)
      List<Libro> porEstado = base.filtrarPorEstado(widget.filtro);

      // Paso 2: Filtramos sobre el resultado anterior usando el texto de búsqueda
      Libreria temporalEstado = Libreria(libros: porEstado);
      List<Libro> resultadoFinal = temporalEstado.filtrarPorBusqueda(consulta);

      // Paso 3: Ordenar alfabéticamente por título
      resultadoFinal.sort(
        (a, b) => a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase()),
      );

      // Guardamos el resultado final en la variable que lee el GridColeccion
      librosFiltrados = Libreria(libros: resultadoFinal);

      // Construir índice letra → índice del primer libro con esa letra
      _indicePorLetra = {};
      for (int i = 0; i < resultadoFinal.length; i++) {
        final letra = resultadoFinal[i].titulo.isNotEmpty
            ? resultadoFinal[i].titulo[0].toUpperCase()
            : '#';
        _indicePorLetra.putIfAbsent(letra, () => i);
      }
      _letraActiva = _indicePorLetra.isNotEmpty
          ? _indicePorLetra.keys.first
          : '';
    });
  }

  // Actualiza la letra resaltada en la barra según la posición del scroll
  void _actualizarLetraActiva() {
    final libros = librosFiltrados.obtenerTodos();
    if (libros.isEmpty || !_scrollController.hasClients) return;

    final anchoDisponible = MediaQuery.of(context).size.width - _anchoSidebar;
    final numColumnas = (anchoDisponible / _maxAnchoCelda).ceil().clamp(1, 10);
    final alturaFila = _alturaItemGrid + _espaciadoGrid;
    final filaActual = (_scrollController.offset / alturaFila).floor();
    final indice = (filaActual * numColumnas).clamp(0, libros.length - 1);

    final letra = libros[indice].titulo.isNotEmpty
        ? libros[indice].titulo[0].toUpperCase()
        : '#';

    if (_letraActiva != letra) setState(() => _letraActiva = letra);
  }

  // Desplaza el grid hasta el primer libro que empieza por [letra]
  void _irALetra(String letra) {
    final index = _indicePorLetra[letra];
    if (index == null || !_scrollController.hasClients) return;

    final anchoDisponible = MediaQuery.of(context).size.width - _anchoSidebar;
    final numColumnas = (anchoDisponible / _maxAnchoCelda).ceil().clamp(1, 10);
    final alturaFila = _alturaItemGrid + _espaciadoGrid;
    final fila = index ~/ numColumnas;

    _scrollController.animateTo(
      fila * alturaFila,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _letraActiva = letra);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoBase(
        rutaImagen: 'assets/images/fondos/estanteria.png',
        child: _estaCargando
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    if (_mostrarMensajeEspera) ...[
                      const SizedBox(height: 20),
                      const Icon(Icons.cloud_outlined, size: 36),
                      const SizedBox(height: 8),
                      const Text(
                        'El servidor está arrancando.\nEsto puede tardar hasta 2 minutos\nla primera vez del día.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              )
            : _errorCarga
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off, size: 48),
                        const SizedBox(height: 12),
                        const Text('No se pudo conectar con el servidor'),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _cargarYFiltrar,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                onRefresh: _cargarYFiltrar,
                child: Column(
                  children: [
                    // BARRA BÚSQUEDA
                    BarraBusqueda(
                      controladorBusqueda: _controladorDeBusqueda,
                      hintText: 'Buscar libro...',
                      onChanged: (valor) => _buscarLibros(valor),
                    ),

                    const SizedBox(height: 20),

                    // LIBROS + BARRA DE LETRAS
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: GridColeccion(
                              librosPantalla: librosFiltrados,
                              scrollController: _scrollController,
                              alCambiar: () =>
                                  _buscarLibros(_controladorDeBusqueda.text),
                            ),
                          ),
                          BarraLetras(
                            letras: _indicePorLetra.keys.toList(),
                            letraActiva: _letraActiva,
                            alSeleccionar: _irALetra,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),

      // BOTÓN FLOTANTE (+)
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          FocusManager.instance.primaryFocus?.unfocus();
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SeleccionMetodoCarga()),
          );
          _buscarLibros(_controladorDeBusqueda.text);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
