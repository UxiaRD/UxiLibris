import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend_flutter/controladores/formularioLibroController.dart';
import 'package:frontend_flutter/modelo/propiedad.dart';
import 'package:frontend_flutter/utilidades/dialogosConfiguracion.dart';
import 'package:frontend_flutter/utilidades/widgetsFormulario.dart';
import '../../modelo/libro.dart';

class FormularioLibro extends StatefulWidget {
  final Libro? libroParaEditar;
  final Function(Libro)? alGuardar;

  const FormularioLibro({super.key, this.libroParaEditar, this.alGuardar});

  @override
  State<FormularioLibro> createState() => _FormularioLibroState();
}

class _FormularioLibroState extends State<FormularioLibro> {
  late TextEditingController _tituloController;
  late TextEditingController _autorController;
  late TextEditingController _sagaNombreController;
  late TextEditingController _numLibroSagaController;
  late EstadoLibro _estadoSeleccionado;
  late FormatoLibro _formatoSeleccionado;
  late double _puntuacionActual;

  late List<Lectura> _lecturas;

  late List<Propiedad> _propiedadesDinamicas;

  List<String> _autoresSugeridos = [];
  List<String> _sagasSugeridas = [];
  List<double> _numerosOcupados = [];

  File? _imagenSeleccionada;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(
      text: widget.libroParaEditar?.titulo ?? '',
    );
    _autorController = TextEditingController(
      text: widget.libroParaEditar?.autorNombre ?? '',
    );
    _sagaNombreController = TextEditingController(
      text: widget.libroParaEditar?.sagaNombre ?? '',
    );
    _numLibroSagaController = TextEditingController(
      text: widget.libroParaEditar?.numLibroSaga?.toString() ?? '',
    );
    _estadoSeleccionado =
        widget.libroParaEditar?.estado ?? EstadoLibro.pendiente;
    _formatoSeleccionado =
        widget.libroParaEditar?.formato ?? FormatoLibro.fisico;
    _puntuacionActual = widget.libroParaEditar?.puntuacion ?? 0.0;
    _lecturas = List<Lectura>.from(widget.libroParaEditar?.lecturas ?? []);
    _propiedadesDinamicas =
        widget.libroParaEditar?.almacen.propiedades
            .map((p) => p.copyWith())
            .toList() ??
        [];

    _cargarSugerencias();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _autorController.dispose();
    _sagaNombreController.dispose();
    _numLibroSagaController.dispose();
    super.dispose();
  }

  // ── Métodos delegados al controlador ──────────────────────────────────────

  Future<void> _cargarSugerencias() async {
    final (autores, sagas) =
        await FormularioLibroController.cargarSugerencias();
    if (mounted) {
      setState(() {
        _autoresSugeridos = autores;
        _sagasSugeridas = sagas;
      });
    }
  }

  Future<void> _actualizarSugerenciaSaga(String nombreSaga) async {
    if (nombreSaga.isEmpty) return;
    final (siguiente, ocupados) =
        await FormularioLibroController.cargarDatosSaga(nombreSaga);
    if (!mounted) return;
    setState(() {
      _numerosOcupados = ocupados;
      _numLibroSagaController.text = siguiente.toString();
    });
  }

  Future<void> _seleccionarImagen() async {
    final imagen = await FormularioLibroController.seleccionarImagen();
    if (imagen != null && mounted) setState(() => _imagenSeleccionada = imagen);
  }

  void _cambiarEstado(EstadoLibro nuevoEstado) {
    final nuevasLecturas = FormularioLibroController.calcularLecturasAutomaticas(
      nuevoEstado: nuevoEstado,
      lecturasActuales: _lecturas,
    );
    setState(() {
      _estadoSeleccionado = nuevoEstado;
      _lecturas = nuevasLecturas;
    });
  }

  Future<void> _guardarLibro() async {
    try {
      final libro = await FormularioLibroController.guardarLibro(
        idExistente: widget.libroParaEditar?.id,
        titulo: _tituloController.text,
        autorNombre: _autorController.text,
        sagaNombre: _sagaNombreController.text,
        numLibroSagaTexto: _numLibroSagaController.text,
        estado: _estadoSeleccionado,
        formato: _formatoSeleccionado,
        puntuacion: _puntuacionActual,
        lecturas: _lecturas,
        imagenSeleccionada: _imagenSeleccionada,
        rutaImagenExistente: widget.libroParaEditar?.rutaImagen,
        propiedades: _propiedadesDinamicas,
      );

      widget.alGuardar?.call(libro);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Libro guardado en la base de datos!')),
      );
      Navigator.pop(context, true);
    } on FormatException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
    }
  }

  // ── Métodos que siguen en el widget (interacción pura con UI) ─────────────

  void _gestionarNuevaPropiedad() async {
    final nuevaProp = await DialogosConfiguracion.mostrarDialogoNuevaPropiedad(
      context,
    );
    if (nuevaProp != null) {
      setState(() => _propiedadesDinamicas.add(nuevaProp));
    }
  }

  // ── Gestión de lecturas ───────────────────────────────────────────────────

  void _actualizarFechaInicioLectura(int indice, DateTime fecha) {
    setState(() {
      _lecturas[indice] = _lecturas[indice].withFechaInicio(fecha);
    });
  }

  void _actualizarFechaFinLectura(int indice, DateTime fecha) {
    setState(() {
      _lecturas[indice] = _lecturas[indice].withFechaFin(fecha);
    });
  }

  void _eliminarLectura(int indice) {
    setState(() => _lecturas.removeAt(indice));
  }

  void _agregarLectura() {
    final ahora = DateTime.now();
    setState(() => _lecturas.add(Lectura(fechaInicio: ahora, fechaFin: ahora)));
  }

  // ── Getters de estado para la UI ──────────────────────────────────────────

  bool get _esLeido => _estadoSeleccionado == EstadoLibro.leido;
  bool get _estaEmpezado =>
      _estadoSeleccionado == EstadoLibro.leido ||
      _estadoSeleccionado == EstadoLibro.leyendo;

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final ColorScheme colores = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            WidgetsFormulario.buildSelectorImagen(
              imagenArchivo: _imagenSeleccionada,
              rutaImagenInicial: widget.libroParaEditar?.rutaImagen,
              primaryColor: colores.primary,
              alPulsar: _seleccionarImagen,
            ),
            const SizedBox(height: 24),
            WidgetsFormulario.buildTextField(
              _tituloController,
              'Título',
              Icons.book,
              colores,
            ),
            const SizedBox(height: 15),
            WidgetsFormulario.buildSearchField(
              controller: _autorController,
              opciones: _autoresSugeridos,
              label: 'Autor/a',
              icono: Icons.person,
              colores: colores,
            ),
            const SizedBox(height: 15),
            WidgetsFormulario.buildSearchField(
              controller: _sagaNombreController,
              opciones: _sagasSugeridas,
              label: 'Saga',
              icono: Icons.library_books,
              colores: colores,
              onSelected: (saga) => _actualizarSugerenciaSaga(saga),
            ),
            const SizedBox(height: 15),
            WidgetsFormulario.buildTextField(
              _numLibroSagaController,
              'Volumen en Saga',
              Icons.format_list_numbered,
              colores,
              esNumerico: true,
              errorText:
                  _numerosOcupados.contains(
                    double.tryParse(_numLibroSagaController.text),
                  )
                  ? 'Este volumen ya existe en la saga'
                  : null,
            ),
            const SizedBox(height: 20),
            WidgetsFormulario.buildDropdownEstado(
              _estadoSeleccionado,
              colores,
              (val) => _cambiarEstado(val!),
            ),
            const SizedBox(height: 15),
            WidgetsFormulario.buildSelectorFormato(
              _formatoSeleccionado,
              colores,
              (val) => setState(() => _formatoSeleccionado = val),
            ),
            const SizedBox(height: 20),

            // ── Sección de lecturas ──────────────────────────────────────
            if (_estaEmpezado) _buildSeccionLecturas(colores),

            WidgetsFormulario.buildSelectorPuntuacion(
              _puntuacionActual,
              _esLeido,
              (val) => setState(() => _puntuacionActual = val),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(),
            ),
            Text(
              'Campos Personalizados',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 15),
            ..._propiedadesDinamicas.map(
              (prop) => WidgetsFormulario.buildCampoDinamico(prop, colores),
            ),
            TextButton.icon(
              onPressed: _gestionarNuevaPropiedad,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Añadir campo personalizado'),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton.icon(
                onPressed: _guardarLibro,
                icon: const Icon(Icons.save),
                label: Text(
                  widget.libroParaEditar?.id == null
                      ? 'Registrar Libro'
                      : 'Actualizar Libro',
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: colores.primary,
                  foregroundColor: colores.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionLecturas(ColorScheme colores) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.menu_book_outlined, size: 18, color: colores.primary),
            const SizedBox(width: 8),
            Text(
              'Historial de lecturas',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colores.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (_lecturas.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Sin lecturas registradas',
              style: TextStyle(fontSize: 13, color: colores.outline),
            ),
          ),

        // Una fila por cada lectura
        ...List.generate(_lecturas.length, (i) {
          final lec = _lecturas[i];
          final puedeEliminar = _lecturas.length > 1 || _estadoSeleccionado == EstadoLibro.leido || lec.estaCompletada;
          return _FilaLectura(
            numero: i + 1,
            lectura: lec,
            puedeEliminar: puedeEliminar,
            editarFinPermitido: _esLeido || lec.estaCompletada,
            onFechaInicio: (d) => _actualizarFechaInicioLectura(i, d),
            onFechaFin: (d) => _actualizarFechaFinLectura(i, d),
            onEliminar: () => _eliminarLectura(i),
          );
        }),

        // Botón "Añadir lectura" solo en modo leído
        if (_esLeido)
          TextButton.icon(
            onPressed: _agregarLectura,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Añadir otra lectura'),
          ),

        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Widget auxiliar: fila de una lectura ─────────────────────────────────────

class _FilaLectura extends StatelessWidget {
  final int numero;
  final Lectura lectura;
  final bool puedeEliminar;
  final bool editarFinPermitido;
  final ValueChanged<DateTime> onFechaInicio;
  final ValueChanged<DateTime> onFechaFin;
  final VoidCallback onEliminar;

  const _FilaLectura({
    required this.numero,
    required this.lectura,
    required this.puedeEliminar,
    required this.editarFinPermitido,
    required this.onFechaInicio,
    required this.onFechaFin,
    required this.onEliminar,
  });

  String _formatDate(DateTime? d) =>
      d == null ? '—' : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<DateTime?> _pickDate(BuildContext context, DateTime? initial) =>
      showDialog<DateTime>(
        context: context,
        builder: (_) => DatePickerDialog(
          initialDate: initial ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colores.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colores.outlineVariant),
      ),
      child: Row(
        children: [
          // Número de lectura
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colores.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$numero',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colores.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Fechas
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fecha inicio
                GestureDetector(
                  onTap: () async {
                    final d = await _pickDate(context, lectura.fechaInicio);
                    if (d != null) onFechaInicio(d);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.play_arrow_rounded, size: 14, color: colores.primary),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(lectura.fechaInicio),
                        style: TextStyle(fontSize: 13, color: colores.onSurface),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // Fecha fin
                GestureDetector(
                  onTap: editarFinPermitido
                      ? () async {
                          final d = await _pickDate(context, lectura.fechaFin);
                          if (d != null) onFechaFin(d);
                        }
                      : null,
                  child: Row(
                    children: [
                      Icon(
                        Icons.stop_rounded,
                        size: 14,
                        color: lectura.estaActiva
                            ? colores.outline
                            : colores.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        lectura.estaActiva ? 'En curso' : _formatDate(lectura.fechaFin),
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: lectura.estaActiva
                              ? FontStyle.italic
                              : FontStyle.normal,
                          color: lectura.estaActiva
                              ? colores.outline
                              : colores.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Botón eliminar
          if (puedeEliminar)
            IconButton(
              icon: Icon(Icons.delete_outline, size: 20, color: colores.error),
              onPressed: onEliminar,
              tooltip: 'Eliminar lectura',
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}