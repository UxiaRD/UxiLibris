import 'package:flutter/material.dart';
import 'package:frontend_flutter/modelo/almacenPropiedades.dart';
import 'package:frontend_flutter/modelo/propiedad.dart';
import 'package:frontend_flutter/utilidades/dialogosConfiguracion.dart';
import 'package:frontend_flutter/utilidades/widgetsFormulario.dart';
import '../../modelo/libro.dart';

class FormularioLibro extends StatefulWidget {
  final Libro? libroParaEditar; // Si es null, estamos creando. Si no, editando.
  final Function(Libro) alGuardar; // Acción que haremos al pulsar el botón

  const FormularioLibro({
    super.key,
    this.libroParaEditar,
    required this.alGuardar,
  });

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

  // Lista local para manejar los cambios en las propiedades dinámicas
  late List<Propiedad> _propiedadesDinamicas;

  List<String> _sagasSugeridas = [
    "Empireo",
    "Nacidos de la Bruma",
    "Crónica del Asesino de Reyes",
  ];

  List<String> _autoresSugeridos = ["Cervantes", "Jane Austen", "J.K. Rowling"];

  @override
  void initState() {
    super.initState();
    // Si se edita, usamos los valores del libro. Si no, valores por defecto.
    _tituloController = TextEditingController(
      text: widget.libroParaEditar?.titulo ?? "",
    );

    _autorController = TextEditingController(
      text: widget.libroParaEditar?.autorNombre ?? "",
    );

    _sagaNombreController = TextEditingController(
      text: widget.libroParaEditar?.sagaNombre ?? "",
    );

    _numLibroSagaController = TextEditingController(
      text: widget.libroParaEditar?.numLibroSaga?.toString() ?? "",
    );

    _estadoSeleccionado =
        widget.libroParaEditar?.estado ?? EstadoLibro.pendiente;

    _puntuacionActual = widget.libroParaEditar?.puntuacion ?? 0.0;

    // Inicializamos fechas desde el libro si existe
    _fechaInicio = widget.libroParaEditar?.fechaInicio;
    _fechaFin = widget.libroParaEditar?.fechaFin;

    // Cargamos las propiedades del almacén o una lista vacía si es nuevo
    _propiedadesDinamicas =
        widget.libroParaEditar?.almacen.propiedades
            .map(
              (p) => p.copyWith(),
            ) // Usamos copyWith para no alterar el original
            .toList() ??
        [];
  }

  List<double> _numerosOcupados = [];

  void _actualizarSugerenciaSaga(String nombreSaga) async {
    // 1. Simulación de llamada al Backend para obtener números ocupados
    // En el futuro será: _numerosOcupados = await api.getNumerosSaga(nombreSaga);
    _numerosOcupados = [1.0, 2.0];

    if (_numerosOcupados.isNotEmpty) {
      setState(() {
        // Sugerimos el siguiente número entero
        double maxActual = _numerosOcupados.reduce((a, b) => a > b ? a : b);
        _numLibroSagaController.text = (maxActual + 1).toString();
      });
    }
  }

  bool get _esLeido => _estadoSeleccionado == EstadoLibro.leido;
  bool get _estaEmpezado =>
      _estadoSeleccionado == EstadoLibro.leido ||
      _estadoSeleccionado == EstadoLibro.leyendo;

  void _cambiarEstado(EstadoLibro nuevoEstado) {
    setState(() {
      _estadoSeleccionado = nuevoEstado;

      // Lógica automática de fechas
      if (nuevoEstado == EstadoLibro.leido) {
        // Cambiamos el nombre según tu enum
        _fechaFin = _fechaFin ?? DateTime.now();
        _fechaInicio = _fechaInicio ?? DateTime.now();
      } else if (nuevoEstado == EstadoLibro.leyendo) {
        // 'leyendo' en tu enum
        _fechaInicio = _fechaInicio ?? DateTime.now();
      }
    });
  }

  void _gestionarNuevaPropiedad() async {
    // Llamamos a la utilidad externa
    final nuevaProp = await DialogosConfiguracion.mostrarDialogoNuevaPropiedad(
      context,
    );

    // Si el usuario no canceló, actualizamos la lista local
    if (nuevaProp != null) {
      setState(() {
        _propiedadesDinamicas.add(nuevaProp);
      });
    }
  }

  void _guardarFormulario() {
    // Validamos que al menos el título no esté vacío
    if (_tituloController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("El título es obligatorio")));
      return;
    }

    // Creamos el objeto Libro final combinando fijos y dinámicos
    final libroFinal = Libro(
      titulo: _tituloController.text,
      autorNombre: _autorController.text,
      sagaNombre: _sagaNombreController.text,
      puntuacion: _puntuacionActual,
      estado: _estadoSeleccionado,
      fechaInicio: _fechaInicio, // Guardamos fechas
      fechaFin: _fechaFin,
      rutaImagen:
          widget.libroParaEditar?.rutaImagen ??
          "assets/images/fondos/libro.png",
      numLibroSaga: double.tryParse(_numLibroSagaController.text),
      almacen: AlmacenPropiedades(propiedades: _propiedadesDinamicas),
    );

    widget.alGuardar(libroFinal);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colores = Theme.of(context).colorScheme;

    return Column(
      children: [
        // --- SECCIÓN DE CAMPOS FIJOS ---
        // 1. TITULO
        WidgetsFormulario.buildTextField(
          _tituloController,
          "Título",
          Icons.book,
          colores,
        ),
        const SizedBox(height: 15),
        // 2. AUTOR
        WidgetsFormulario.buildSearchField(
          controller: _autorController,
          opciones: _autoresSugeridos,
          label: "Autor/a",
          icono: Icons.person,
          colores: colores,
        ),
        const SizedBox(height: 15),
        // 3. SAGAS -> Buscador en la DB
        WidgetsFormulario.buildSearchField(
          controller: _sagaNombreController,
          opciones: _sagasSugeridas,
          label: "Saga",
          icono: Icons.library_books,
          colores: colores,
        ),
        const SizedBox(height: 15),
        // 4. VOLUMEN del libro en la Saga
        WidgetsFormulario.buildTextField(
          _numLibroSagaController,
          "Volumen en Saga",
          Icons.format_list_numbered,
          colores,
          esNumerico: true,
          // Pasamos la lógica de validación como argumento
          errorText:
              _numerosOcupados.contains(
                double.tryParse(_numLibroSagaController.text),
              )
              ? "Este volumen ya existe en la saga"
              : null,
        ),
        const SizedBox(height: 20),
        // 5. CAMBIO DE ESTADO
        WidgetsFormulario.buildDropdownEstado(
          _estadoSeleccionado,
          colores,
          (val) => _cambiarEstado(val!),
        ),
        const SizedBox(height: 20),
        // 6. FECHA INCIO
        if (_estaEmpezado)
          WidgetsFormulario.buildDatePicker(
            context,
            "Fecha Inicio",
            _fechaInicio,
            (d) => setState(() => _fechaInicio = d),
          ),
        // 7. FECHA FIN
        if (_esLeido)
          WidgetsFormulario.buildDatePicker(
            context,
            "Fecha Fin",
            _fechaFin,
            (d) => setState(() => _fechaFin = d),
          ),
        const SizedBox(height: 20),
        // 8. PUNTUACIÓN
        WidgetsFormulario.buildSelectorPuntuacion(_puntuacionActual, _esLeido, (
          val,
        ) {
          setState(() => _puntuacionActual = val);
        }),
        // Separador
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Divider(),
        ),
        // Titulo
        Text(
          "Campos Personalizados",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 15),

        // --- SECCIÓN DE CAMPOS DINÁMICOS (El Almacén) ---
        // Recorrer la lista y creamos un campo por cada propiedad
        ..._propiedadesDinamicas
            .map((prop) => WidgetsFormulario.buildCampoDinamico(prop, colores))
            .toList(),

        TextButton.icon(
          onPressed: _gestionarNuevaPropiedad,
          icon: const Icon(Icons.add_circle_outline),
          label: const Text("Añadir campo personalizado"),
        ),
        const SizedBox(height: 30),

        // BOTÓN GUARDAR
        ElevatedButton(
          onPressed: _guardarFormulario,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Text(
            widget.libroParaEditar == null ? "Añadir Libro" : "Guardar Cambios",
          ),
        ),
      ],
    );
  }
}
