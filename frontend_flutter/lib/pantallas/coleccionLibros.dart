import 'package:flutter/material.dart';
import 'package:frontend_flutter/decoraciones/fondoBase.dart';
import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/pantallas/seleccionMetodoCarga.dart';
import 'package:frontend_flutter/pantallas/widgetsColeccionLibros/barraBusqueda.dart';
import 'package:frontend_flutter/pantallas/widgetsColeccionLibros/gridViewColeccion.dart';
import 'package:frontend_flutter/servicio/ApiService.dart';

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

  bool _estaCargando = true;

  @override
  void initState() {
    super.initState();
    _cargarYFiltrar(); // Cambiamos la llamada inicial
  }

  // Nueva función para traer los datos de Java antes de filtrar
  Future<void> _cargarYFiltrar() async {
    setState(() => _estaCargando = true);
    // Si ya hay datos en memoria, solo filtrar sin ir al servidor
    if (Libreria.todosLosLibros.isNotEmpty) {
      _buscarLibros(_controladorDeBusqueda.text);
      setState(() => _estaCargando = false);
      return;
    }
    try {
      // 1. Llamamos al ApiService (AQUÍ ES DONDE DABA EL 404)
      // Debes asegurarte que en ApiService.dart la ruta sea exacta a Java
      var librosBackend = await ApiService.fetchLibros();

      // 2. Actualizamos la lista estática global
      Libreria.todosLosLibros = librosBackend;

      // 3. Aplicamos los filtros que ya tenías
      _buscarLibros(_controladorDeBusqueda.text);
    } catch (e) {
      print("Error al cargar libros: $e");
      // Si da 404, al menos detenemos el indicador de carga
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

      // Guardamos el resultado final en la variable que lee el GridColeccion
      librosFiltrados = Libreria(libros: resultadoFinal);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoBase(
        rutaImagen: 'assets/images/fondos/estanteria.png',
        child: _estaCargando
            ? const Center(
                child: CircularProgressIndicator(),
              ) // Mientras descarga de Java
            : Column(
                children: [
                  // BARRA BÚSQUEDA
                  BarraBusqueda(
                    controladorBusqueda: _controladorDeBusqueda,
                    onChanged: (valor) => _buscarLibros(valor),
                  ),

                  SizedBox(height: 20),

                  // LIBROS
                  // Pasamos una función para que el Grid avise cuando algo cambie
                  GridColeccion(
                    librosPantalla: librosFiltrados,
                    alCambiar: () => _buscarLibros(_controladorDeBusqueda.text),
                  ),
                ],
              ),
      ),

      // BOTÓN FLOTANTE (+)
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SeleccionMetodoCarga()),
          );
          // Llamamos a la función con el texto que haya en el buscador (aunque esté vacío)
          // para que refresque la lista respetando la pestaña actual.
          _buscarLibros(_controladorDeBusqueda.text);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
