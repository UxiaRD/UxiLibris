import 'package:flutter/material.dart';
import 'package:frontend_flutter/modelo/almacenPropiedades.dart';
import 'package:frontend_flutter/modelo/propiedad.dart';
import 'package:frontend_flutter/servicio/ApiService.dart';
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

  List<String> _autoresSugeridos = [];
  List<String> _sagasSugeridas = [];

  List<double> _numerosOcupados = [];

  // Método auxiliar para no bloquear el initState
  Future<void> _cargarDatosDesdeServidor() async {
    try {
      final autores = await ApiService.fetchAutores(); // Petición GET a Java
      final sagas = await ApiService.fetchSagas(); // Petición GET a Java

      setState(() {
        _autoresSugeridos = autores;
        _sagasSugeridas = sagas;
      });
    } catch (e) {
      print("Error al conectar con el servidor: $e");
      // Aquí podrías mostrar un SnackBar si el servidor Java está apagado
    }
  }

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

    // Disparamos la carga asíncrona de autores y sagas desde Java
    _cargarDatosDesdeServidor();
  }

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

  Future<void> _guardarLibro() async {
    // 1. Mantenemos tu validación de título
    if (_tituloController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("El título es obligatorio")));
      return;
    }

    // 2. Creamos el objeto final (mezclando tu lógica actual con el nuevo envío)
    final libroFinal = Libro(
      id: widget
          .libroParaEditar
          ?.id, // Importante para que Java sepa si es UPDATE o INSERT
      titulo: _tituloController.text,
      autorNombre: _autorController.text,
      sagaNombre: _sagaNombreController.text,
      puntuacion: _puntuacionActual, // Soporta tus pasos de 0.5
      estado: _estadoSeleccionado,
      fechaInicio: _fechaInicio,
      fechaFin: _fechaFin,
      rutaImagen:
          widget.libroParaEditar?.rutaImagen ??
          "assets/images/fondos/libro.png",
      numLibroSaga: double.tryParse(
        _numLibroSagaController.text,
      ), // Soporta tus decimales
      almacen: AlmacenPropiedades(
        propiedades: _propiedadesDinamicas,
      ), // Tu sistema de personalización extrema
    );

    // 3. Envío asíncrono al Backend en Java
    try {
      // Mostramos un indicador de carga si quieres, o simplemente esperamos la respuesta
      bool exito = await ApiService.guardarLibro(libroFinal);

      if (exito) {
        // 4. Si el servidor responde OK, ejecutamos el callback local (si aún lo usas) y cerramos
        widget.alGuardar(libroFinal);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Libro guardado en la base de datos!")),
        );

        Navigator.pop(context, true); // Volvemos a la pantalla principal
      } else {
        throw Exception("El servidor no pudo procesar el guardado");
      }
    } catch (e) {
      // Si falla el servidor (ej: Spring Boot apagado), avisamos al usuario
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error de conexión: $e")));
    }
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: ElevatedButton.icon(
            onPressed: _guardarLibro, // Llamamos a nuestra función lógica
            icon: const Icon(Icons.save),
            label: Text(
              widget.libroParaEditar == null
                  ? "Registrar Libro"
                  : "Actualizar Libro",
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
    );
  }
}
