import 'package:flutter/material.dart';
import 'package:frontend_flutter/decoraciones/fondoBase.dart';
import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/pantallas/seleccionMetodoCarga.dart';
import 'package:frontend_flutter/utilidades/barraBusqueda.dart';
import 'package:frontend_flutter/pantallas/widgetsColeccionLibros/gridViewColeccion.dart';
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
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _cargarYFiltrar() async {
    setState(() => _estaCargando = true);
    try {
      await ColeccionController.cargarLibros();
      _buscarLibros(_controladorDeBusqueda.text);
    } catch (e) {
      print("Error al cargar libros: $e");
    } finally {
      if (mounted) setState(() => _estaCargando = false);
    }
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
            ? const Center(child: CircularProgressIndicator())
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
                          _BarraLetras(
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

// Barra lateral de letras (Opción 2: siempre visible, letra activa resaltada)
class _BarraLetras extends StatelessWidget {
  final List<String> letras;
  final String letraActiva;
  final void Function(String) alSeleccionar;

  const _BarraLetras({
    required this.letras,
    required this.letraActiva,
    required this.alSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    if (letras.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: 28,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: letras.map((letra) {
          final activa = letra == letraActiva;
          return Expanded(
            child: GestureDetector(
              onTap: () => alSeleccionar(letra),
              behavior: HitTestBehavior.opaque,
              child: Center(
                child: Text(
                  letra,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: activa ? FontWeight.bold : FontWeight.normal,
                    color: activa ? colores.primary : colores.outline,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
