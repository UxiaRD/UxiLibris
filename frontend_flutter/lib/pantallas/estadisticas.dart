import 'package:flutter/material.dart';
import 'package:frontend_flutter/controladores/estadisticasController.dart';
import 'package:frontend_flutter/decoraciones/fondoBase.dart';
import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/pantallas/widgetsEstadisticas/grafica_comparativa.dart';
import 'package:frontend_flutter/pantallas/widgetsEstadisticas/grafica_mensual.dart';
import 'package:frontend_flutter/pantallas/widgetsEstadisticas/helpers_estadisticas.dart';
import 'package:frontend_flutter/pantallas/widgetsEstadisticas/pantalla_vacia.dart';
import 'package:frontend_flutter/pantallas/widgetsEstadisticas/seccion_favoritos.dart';
import 'package:frontend_flutter/pantallas/widgetsEstadisticas/selector_anio.dart';
import 'package:frontend_flutter/pantallas/widgetsEstadisticas/tarjetas_resumen.dart';
import 'package:frontend_flutter/pantallas/widgetsEstadisticas/top_autores.dart';
import 'package:frontend_flutter/pantallas/widgetsEstadisticas/top_puntuados.dart';
import 'package:frontend_flutter/servicio/ApiService.dart';
import 'package:frontend_flutter/utilidades/actionsAppBar.dart';
import 'package:frontend_flutter/utilidades/drawerPrincipal.dart';

/// Pantalla de estadísticas de lectura: resumen anual, gráficas mensual y comparativa,
/// top de autores, libros mejor puntuados y sección de favoritos.
class PantallaEstadisticas extends StatefulWidget {
  const PantallaEstadisticas({super.key});

  @override
  State<PantallaEstadisticas> createState() => _PantallaEstadisticasState();
}

class _PantallaEstadisticasState extends State<PantallaEstadisticas> {
  bool _cargando = true;
  int _anioSeleccionado = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  /// Descarga los libros del servidor y activa la visualización de estadísticas.
  Future<void> _cargar() async {
    final libros = await ApiService.fetchLibros();
    Libreria.todosLosLibros = libros;
    if (mounted) setState(() => _cargando = false);
  }

  /// Alterna el estado favorito del libro en local y lo sincroniza con el servidor.
  Future<void> _toggleFavorito(Libro libro) async {
    setState(() => libro.favorito = !libro.favorito);
    await ApiService.toggleFavorito(libro.id!, libro.favorito);
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final anios = EstadisticasController.anios;
    final leidos = EstadisticasController.leidos;

    if (anios.isNotEmpty && !anios.contains(_anioSeleccionado)) {
      _anioSeleccionado = anios.last;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const DrawerPrincipal(
        pantallaActual: PantallaDrawer.estadisticas,
      ),
      appBar: AppBar(
        title: const Text('Estadísticas'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: ActionsAppBar.obtenerAcciones(context),
      ),
      body: FondoBase(
        rutaImagen: 'assets/images/fondos/fondoEstadisticas.png',
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : leidos.isEmpty
            ? PantallaVaciaEstadisticas(colores: colores)
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectorAnio(
                      anios: anios,
                      anioSeleccionado: _anioSeleccionado,
                      onChanged: (anio) => setState(() => _anioSeleccionado = anio),
                      colores: colores,
                    ),
                    const SizedBox(height: 20),

                    // 1. Resumen del año seleccionado
                    TarjetasResumen(
                      anio: _anioSeleccionado,
                      lecturasAnio: EstadisticasController.lecturasEnAnio(_anioSeleccionado),
                      totalLeidos: EstadisticasController.totalLecturas,
                      mediaPuntuacion: EstadisticasController.mediaPuntuacion(_anioSeleccionado),
                      autorFavorito: EstadisticasController.autorFavorito(_anioSeleccionado),
                      colores: colores,
                    ),
                    const SizedBox(height: 28),

                    // 2. Gráfica mensual del año seleccionado
                    TituloSeccion(texto: 'Libros leídos por mes', colores: colores),
                    const SizedBox(height: 12),
                    GraficaMensual(
                      datos: EstadisticasController.librosPorMes(_anioSeleccionado),
                      colores: colores,
                    ),

                    // 3. Comparativa entre años (solo si hay más de uno)
                    if (anios.length > 1) ...[
                      const SizedBox(height: 28),
                      TituloSeccion(texto: 'Comparativa por años', colores: colores),
                      const SizedBox(height: 12),
                      GraficaComparativa(anios: anios, colores: colores),
                      const SizedBox(height: 8),
                      LeyendaAnios(anios: anios),
                    ],

                    // 4. Top autores del año seleccionado
                    const SizedBox(height: 28),
                    TituloSeccion(texto: 'Autores más leídos', colores: colores),
                    const SizedBox(height: 12),
                    SeccionTopAutores(
                      autores: EstadisticasController.topAutores(5, _anioSeleccionado),
                      colores: colores,
                    ),

                    // 5. Top puntuados del año seleccionado
                    const SizedBox(height: 28),
                    TituloSeccion(texto: 'Mejores puntuaciones', colores: colores),
                    const SizedBox(height: 12),
                    SeccionTopPuntuados(
                      libros: EstadisticasController.topPuntuados(5, _anioSeleccionado),
                      colores: colores,
                      onToggleFavorito: _toggleFavorito,
                    ),

                    // 6. Favoritos del año seleccionado
                    const SizedBox(height: 28),
                    TituloSeccion(texto: 'Mis favoritos', colores: colores),
                    const SizedBox(height: 12),
                    SeccionFavoritos(
                      favoritos: EstadisticasController.favoritos(_anioSeleccionado),
                      colores: colores,
                      onToggleFavorito: _toggleFavorito,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}