import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:frontend_flutter/modelo/almacenPropiedades.dart';
import 'package:frontend_flutter/modelo/propiedad.dart';
import 'package:frontend_flutter/servicio/ApiService.dart';
import 'package:frontend_flutter/utilidades/dialogosConfiguracion.dart';
import 'package:frontend_flutter/utilidades/widgetsFormulario.dart';
import '../../modelo/libro.dart';

class FormularioLibro extends StatefulWidget {
  final Libro? libroParaEditar; // Si es null, estamos creando. Si no, editando.
  final Function(Libro)? alGuardar; // Acción que haremos al pulsar el botón

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

  // Lista local para manejar los cambios en las propiedades dinámicas
  late List<Propiedad> _propiedadesDinamicas;

  List<String> _autoresSugeridos = [];
  List<String> _sagasSugeridas = [];

  List<double> _numerosOcupados = [];

  File? _imagenSeleccionada; // Para guardar el archivo físico en Android
  final ImagePicker _picker = ImagePicker();

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
      // Si el servidor está apagado, los autocompletes quedan vacíos
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

  @override
  void dispose() {
    // Buena práctica: liberar los controladores cuando el widget se destruye
    _tituloController.dispose();
    _autorController.dispose();
    _sagaNombreController.dispose();
    _numLibroSagaController.dispose();
    super.dispose();
  }

  Future<void> _actualizarSugerenciaSaga(String nombreSaga) async {
    if (nombreSaga.isEmpty) return;
    try {
      // Petición 1: siguiente volumen sugerido
      final double siguiente = await ApiService.fetchSugerenciaVolumen(
        nombreSaga,
      );

      // Petición 2: volúmenes ya ocupados (para la validación visual)
      // Reutilizamos el endpoint que ya tienes en LibroRepository
      final List<double> ocupados = await ApiService.fetchVolumenesOcupados(
        nombreSaga,
      );

      if (!mounted) return;
      setState(() {
        _numerosOcupados = ocupados;
        _numLibroSagaController.text = siguiente.toString();
      });
    } catch (_) {
      // Si falla la petición, no hacemos nada: el usuario puede escribir
      // el volumen manualmente sin perder lo que ya tenía en el campo.
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

  // Método para seleccionar la imagen
  Future<void> _seleccionarImagen() async {
    final XFile? imagenTemporal = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (imagenTemporal != null) {
      // 1. Obtenemos el directorio permanente de la app
      final directorio = await getApplicationDocumentsDirectory();

      // 2. Creamos un nombre único para el archivo (usando la fecha actual)
      final String nombreArchivo =
          'libro_${DateTime.now().millisecondsSinceEpoch}.png';
      final String rutaPermanente = '${directorio.path}/$nombreArchivo';

      // 3. Copiamos el archivo de la caché a la carpeta permanente
      final File imagenGuardada = await File(
        imagenTemporal.path,
      ).copy(rutaPermanente);

      setState(() {
        _imagenSeleccionada = imagenGuardada;
        // Ahora esta es la ruta que enviaremos a Java y MySQL
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
          _imagenSeleccionada?.path ??
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
        widget.alGuardar?.call(libroFinal);

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

    return SingleChildScrollView(
      // Ayuda con el segundo error (overflow)
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- SECCIÓN DE CAMPOS FIJOS ---
            // 1. IMAGEN
            WidgetsFormulario.buildSelectorImagen(
              imagenArchivo: _imagenSeleccionada,
              rutaImagenInicial: widget.libroParaEditar?.rutaImagen,
              primaryColor: colores.primary,
              alPulsar: _seleccionarImagen, // Tu método con ImagePicker
            ),
            const SizedBox(height: 24),
            // 2. TITULO
            WidgetsFormulario.buildTextField(
              _tituloController,
              "Título",
              Icons.book,
              colores,
            ),
            const SizedBox(height: 15),
            // 3. AUTOR
            WidgetsFormulario.buildSearchField(
              controller: _autorController,
              opciones: _autoresSugeridos,
              label: "Autor/a",
              icono: Icons.person,
              colores: colores,
            ),
            const SizedBox(height: 15),
            // 4. SAGAS -> Buscador en la DB
            WidgetsFormulario.buildSearchField(
              controller: _sagaNombreController,
              opciones: _sagasSugeridas,
              label: "Saga",
              icono: Icons.library_books,
              colores: colores,
              onSelected: (saga) => _actualizarSugerenciaSaga(saga),
            ),
            const SizedBox(height: 15),
            // 5. VOLUMEN del libro en la Saga
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
            // 6. CAMBIO DE ESTADO
            WidgetsFormulario.buildDropdownEstado(
              _estadoSeleccionado,
              colores,
              (val) => _cambiarEstado(val!),
            ),
            const SizedBox(height: 20),
            // 7. FECHA INCIO
            if (_estaEmpezado)
              WidgetsFormulario.buildDatePicker(
                context,
                "Fecha Inicio",
                _fechaInicio,
                (d) => setState(() => _fechaInicio = d),
              ),
            // 8. FECHA FIN
            if (_esLeido)
              WidgetsFormulario.buildDatePicker(
                context,
                "Fecha Fin",
                _fechaFin,
                (d) => setState(() => _fechaFin = d),
              ),
            const SizedBox(height: 20),
            // 9. PUNTUACIÓN
            WidgetsFormulario.buildSelectorPuntuacion(
              _puntuacionActual,
              _esLeido,
              (val) {
                setState(() => _puntuacionActual = val);
              },
            ),
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
            ..._propiedadesDinamicas.map(
              (prop) => WidgetsFormulario.buildCampoDinamico(prop, colores),
            ),

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
        ),
      ),
    );
  }
}
