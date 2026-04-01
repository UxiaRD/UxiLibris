import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend_flutter/controladores/formularioLibroController.dart';
import 'package:frontend_flutter/modelo/almacenPropiedades.dart';
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
  late double _puntuacionActual;

  DateTime? _fechaInicio;
  DateTime? _fechaFin;

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
    _puntuacionActual = widget.libroParaEditar?.puntuacion ?? 0.0;
    _fechaInicio = widget.libroParaEditar?.fechaInicio;
    _fechaFin = widget.libroParaEditar?.fechaFin;
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
    if (mounted)
      setState(() {
        _autoresSugeridos = autores;
        _sagasSugeridas = sagas;
      });
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
    final fechas = FormularioLibroController.calcularFechasAutomaticas(
      nuevoEstado: nuevoEstado,
      inicioActual: _fechaInicio,
      finActual: _fechaFin,
    );
    setState(() {
      _estadoSeleccionado = nuevoEstado;
      _fechaInicio = fechas.inicio;
      _fechaFin = fechas.fin;
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
        puntuacion: _puntuacionActual,
        fechaInicio: _fechaInicio,
        fechaFin: _fechaFin,
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
            const SizedBox(height: 20),
            if (_estaEmpezado)
              WidgetsFormulario.buildDatePicker(
                context,
                'Fecha Inicio',
                _fechaInicio,
                (d) => setState(() => _fechaInicio = d),
              ),
            if (_esLeido)
              WidgetsFormulario.buildDatePicker(
                context,
                'Fecha Fin',
                _fechaFin,
                (d) => setState(() => _fechaFin = d),
              ),
            const SizedBox(height: 20),
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
}
