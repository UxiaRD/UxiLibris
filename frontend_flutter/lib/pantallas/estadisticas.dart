import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend_flutter/controladores/coleccionController.dart';
import 'package:frontend_flutter/controladores/estadisticasController.dart';
import 'package:frontend_flutter/decoraciones/appThemes.dart';
import 'package:frontend_flutter/decoraciones/fondoBase.dart';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/utilidades/actionsAppBar.dart';
import 'package:frontend_flutter/utilidades/drawerPrincipal.dart';

class PantallaEstadisticas extends StatefulWidget {
  const PantallaEstadisticas({super.key});

  @override
  State<PantallaEstadisticas> createState() => _PantallaEstadisticasState();
}

class _PantallaEstadisticasState extends State<PantallaEstadisticas> {
  bool _cargando = true;
  int _anioSeleccionado = DateTime.now().year;

  // Colores fijos para las líneas de la comparativa (uno por año)
  static const _coloresAnios = [
    AppThemes.moradoPrincipal,
    Colors.orange,
    Colors.teal,
    Colors.amber,
    Colors.pinkAccent,
  ];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    await ColeccionController.cargarLibros();
    if (mounted) setState(() => _cargando = false);
  }

  // ── Cómputos ────────────────────────────────────────────────────────────────

  // ── Delegación al controlador ────────────────────────────────────────────────

  List<Libro> get _leidos => EstadisticasController.leidos;
  List<int> get _anios => EstadisticasController.anios;
  Map<int, int> _librosPorMes(int anio) =>
      EstadisticasController.librosPorMes(anio);
  List<MapEntry<String, int>> _topAutores(int n) =>
      EstadisticasController.topAutores(n);
  List<Libro> _topPuntuados(int n) => EstadisticasController.topPuntuados(n);
  String get _mediaPuntuacion => EstadisticasController.mediaPuntuacion;
  String get _autorFavorito => EstadisticasController.autorFavorito;

  // ── Build principal ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final anios = _anios;
    final leidos = _leidos;
    final anioActual = DateTime.now().year;

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
            ? _pantallaVacia(colores)
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Resumen rápido
                    _tarjetasResumen(
                      leidos
                          .where((l) => l.fechaFin!.year == anioActual)
                          .length,
                      leidos.length,
                      colores,
                    ),
                    const SizedBox(height: 28),

                    // 2. Gráfica mensual
                    _tituloSeccion('Libros leídos por mes', colores),
                    const SizedBox(height: 8),
                    _selectorAnio(anios, colores),
                    const SizedBox(height: 12),
                    _graficaMensual(colores),

                    // 3. Comparativa entre años (solo si hay más de uno)
                    if (anios.length > 1) ...[
                      const SizedBox(height: 28),
                      _tituloSeccion('Comparativa por años', colores),
                      const SizedBox(height: 12),
                      _graficaComparativa(anios, colores),
                      const SizedBox(height: 8),
                      _leyendaAnios(anios),
                    ],

                    // 4. Top autores
                    const SizedBox(height: 28),
                    _tituloSeccion('Autores más leídos', colores),
                    const SizedBox(height: 12),
                    _seccionTopAutores(colores),

                    // 5. Top puntuados
                    const SizedBox(height: 28),
                    _tituloSeccion('Mejores puntuaciones', colores),
                    const SizedBox(height: 12),
                    _seccionTopPuntuados(colores),
                  ],
                ),
              ),
      ),
    );
  }

  // ── Pantalla vacía ───────────────────────────────────────────────────────────

  Widget _pantallaVacia(ColorScheme colores) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 72, color: colores.outline),
          const SizedBox(height: 16),
          Text(
            'Aún no hay datos',
            style: TextStyle(fontSize: 18, color: colores.outline),
          ),
          const SizedBox(height: 8),
          Text(
            'Marca libros como leídos para\nver tus estadísticas aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colores.outline),
          ),
        ],
      ),
    );
  }

  // ── Tarjetas de resumen ──────────────────────────────────────────────────────

  Widget _tarjetasResumen(int esteAnio, int totalLeidos, ColorScheme colores) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _tarjeta(
          'Leídos este año',
          '$esteAnio',
          Icons.calendar_today_outlined,
          colores,
        ),
        _tarjeta(
          'Total leídos',
          '$totalLeidos',
          Icons.check_circle_outline,
          colores,
        ),
        _tarjeta(
          'Nota media',
          _mediaPuntuacion,
          Icons.star_outline_rounded,
          colores,
        ),
        _tarjeta(
          'Autor favorito',
          _autorFavorito,
          Icons.person_outline,
          colores,
          valorPequeno: true,
        ),
      ],
    );
  }

  Widget _tarjeta(
    String titulo,
    String valor,
    IconData icono,
    ColorScheme colores, {
    bool valorPequeno = false,
  }) {
    return Card(
      elevation: 0,
      color: colores.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colores.primary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icono, size: 16, color: colores.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    titulo,
                    style: TextStyle(fontSize: 11, color: colores.outline),
                  ),
                ),
              ],
            ),
            Text(
              valor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: valorPequeno ? 13 : 22,
                fontWeight: FontWeight.bold,
                color: colores.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Selector de año ──────────────────────────────────────────────────────────

  Widget _selectorAnio(List<int> anios, ColorScheme colores) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: anios.map((anio) {
          final activo = anio == _anioSeleccionado;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('$anio'),
              selected: activo,
              onSelected: (_) => setState(() => _anioSeleccionado = anio),
              selectedColor: colores.primary,
              labelStyle: TextStyle(
                color: activo ? Colors.white : colores.onSurface,
                fontWeight: activo ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Gráfica de barras mensual ────────────────────────────────────────────────

  Widget _graficaMensual(ColorScheme colores) {
    final datos = _librosPorMes(_anioSeleccionado);
    final maxVal = datos.values.isEmpty
        ? 1
        : datos.values.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (maxVal + 1).toDouble(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.black87,
              getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                '${rod.toY.toInt()}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: maxVal <= 3 ? 1 : null,
                getTitlesWidget: (v, _) => v % 1 == 0 && v > 0
                    ? Text(
                        '${v.toInt()}',
                        style: TextStyle(fontSize: 10, color: colores.outline),
                      )
                    : const SizedBox(),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  const meses = [
                    'E',
                    'F',
                    'M',
                    'A',
                    'M',
                    'J',
                    'J',
                    'A',
                    'S',
                    'O',
                    'N',
                    'D',
                  ];
                  final i = v.toInt();
                  if (i < 0 || i >= 12) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      meses[i],
                      style: TextStyle(fontSize: 10, color: colores.outline),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: colores.outline.withValues(alpha: 0.15),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(12, (i) {
            final count = datos[i + 1] ?? 0;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: count.toDouble(),
                  color: count > 0
                      ? colores.primary
                      : colores.primary.withValues(alpha: 0.15),
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ── Gráfica de líneas comparativa ────────────────────────────────────────────

  Widget _graficaComparativa(List<int> anios, ColorScheme colores) {
    // Máximo global para escalar el eje Y
    int maxVal = 1;
    for (final anio in anios) {
      final m = _librosPorMes(anio).values.reduce((a, b) => a > b ? a : b);
      if (m > maxVal) maxVal = m;
    }

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minX: 1,
          maxX: 12,
          minY: 0,
          maxY: (maxVal + 1).toDouble(),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Colors.black87,
              getTooltipItems: (spots) => spots.map((s) {
                final anio = anios[s.barIndex];
                return LineTooltipItem(
                  '$anio: ${s.y.toInt()}',
                  TextStyle(
                    color: _coloresAnios[s.barIndex % _coloresAnios.length],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (v, _) {
                  const meses = [
                    'E',
                    'F',
                    'M',
                    'A',
                    'M',
                    'J',
                    'J',
                    'A',
                    'S',
                    'O',
                    'N',
                    'D',
                  ];
                  final i = v.toInt() - 1;
                  if (i < 0 || i >= 12) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      meses[i],
                      style: TextStyle(fontSize: 10, color: colores.outline),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: maxVal <= 3 ? 1 : null,
                getTitlesWidget: (v, _) => v % 1 == 0 && v > 0
                    ? Text(
                        '${v.toInt()}',
                        style: TextStyle(fontSize: 10, color: colores.outline),
                      )
                    : const SizedBox(),
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: colores.outline.withValues(alpha: 0.15),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: anios.asMap().entries.map((entry) {
            final i = entry.key;
            final anio = entry.value;
            final datos = _librosPorMes(anio);
            final color = _coloresAnios[i % _coloresAnios.length];
            return LineChartBarData(
              spots: List.generate(
                12,
                (m) =>
                    FlSpot((m + 1).toDouble(), (datos[m + 1] ?? 0).toDouble()),
              ),
              isCurved: true,
              curveSmoothness: 0.3,
              color: color,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                  radius: spot.y > 0 ? 3 : 0,
                  color: color,
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(show: false),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _leyendaAnios(List<int> anios) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 16,
        runSpacing: 4,
        children: anios.asMap().entries.map((entry) {
          final color = _coloresAnios[entry.key % _coloresAnios.length];
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 16, height: 3, color: color),
              const SizedBox(width: 4),
              Text(
                '${entry.value}',
                style: TextStyle(fontSize: 11, color: color),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Top autores ──────────────────────────────────────────────────────────────

  Widget _seccionTopAutores(ColorScheme colores) {
    final autores = _topAutores(5);
    if (autores.isEmpty) return _sinDatosTexto(colores);
    final maximo = autores.first.value;

    return Column(
      children: autores.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(
                width: 110,
                child: Text(
                  entry.key,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: entry.value / maximo,
                    minHeight: 14,
                    backgroundColor: colores.primary.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(colores.primary),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 20,
                child: Text(
                  '${entry.value}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colores.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Top puntuados ────────────────────────────────────────────────────────────

  Widget _seccionTopPuntuados(ColorScheme colores) {
    final libros = _topPuntuados(5);
    if (libros.isEmpty) return _sinDatosTexto(colores);

    return Column(
      children: libros.asMap().entries.map((entry) {
        final pos = entry.key + 1;
        final libro = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              // Posición
              SizedBox(
                width: 24,
                child: Text(
                  '$pos.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colores.primary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Título y autor
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      libro.titulo,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      libro.autorNombre,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: colores.outline),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Estrellas
              _estrellas(libro.puntuacion, colores),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _estrellas(double puntuacion, ColorScheme colores) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final llena = i < puntuacion.floor();
        final media = !llena && i < puntuacion;
        return Icon(
          media ? Icons.star_half_rounded : Icons.star_rounded,
          size: 16,
          color: llena || media
              ? Colors.amber
              : colores.outline.withValues(alpha: 0.3),
        );
      }),
    );
  }

  // ── Helpers de UI ────────────────────────────────────────────────────────────

  Widget _tituloSeccion(String texto, ColorScheme colores) {
    return Text(
      texto,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: colores.onSurface,
      ),
    );
  }

  Widget _sinDatosTexto(ColorScheme colores) {
    return Text(
      'Sin datos suficientes',
      style: TextStyle(color: colores.outline, fontSize: 13),
    );
  }
}
