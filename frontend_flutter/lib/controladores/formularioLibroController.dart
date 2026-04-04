import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:frontend_flutter/modelo/almacenPropiedades.dart';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/modelo/propiedad.dart';
import 'package:frontend_flutter/servicio/ApiService.dart';

class FormularioLibroController {
  /// Carga autores y sagas sugeridos del servidor en paralelo.
  /// Devuelve (autores, sagas). Silencia errores de red (devuelve listas vacías).
  static Future<(List<String>, List<String>)> cargarSugerencias() async {
    try {
      final results = await Future.wait([
        ApiService.fetchAutores(),
        ApiService.fetchSagas(),
      ]);
      return (results[0] as List<String>, results[1] as List<String>);
    } catch (_) {
      return (<String>[], <String>[]);
    }
  }

  /// Carga el volumen siguiente sugerido y los volúmenes ya ocupados para una saga.
  /// Devuelve (siguienteVolumen, volumenesOcupados). Silencia errores de red.
  static Future<(double, List<double>)> cargarDatosSaga(String saga) async {
    try {
      final siguiente = await ApiService.fetchSugerenciaVolumen(saga);
      final ocupados = await ApiService.fetchVolumenesOcupados(saga);
      return (siguiente, ocupados);
    } catch (_) {
      return (1.0, <double>[]);
    }
  }

  /// Abre la galería y copia la imagen seleccionada al directorio permanente.
  /// Devuelve el [File] guardado, o null si el usuario cancela.
  static Future<File?> seleccionarImagen() async {
    final temporal = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (temporal == null) return null;

    final directorio = await getApplicationDocumentsDirectory();
    final nombre = 'libro_${DateTime.now().millisecondsSinceEpoch}.png';
    return File(temporal.path).copy('${directorio.path}/$nombre');
  }

  /// Calcula las fechas automáticas al cambiar el estado de lectura.
  /// Es una función pura: no tiene efectos secundarios.
  static ({DateTime? inicio, DateTime? fin}) calcularFechasAutomaticas({
    required EstadoLibro nuevoEstado,
    required DateTime? inicioActual,
    required DateTime? finActual,
  }) {
    DateTime? inicio = inicioActual;
    DateTime? fin = finActual;

    if (nuevoEstado == EstadoLibro.leido) {
      fin = fin ?? DateTime.now();
      inicio = inicio ?? DateTime.now();
    } else if (nuevoEstado == EstadoLibro.leyendo) {
      inicio = inicio ?? DateTime.now();
    }

    return (inicio: inicio, fin: fin);
  }

  /// Valida, construye y envía el libro al servidor.
  ///
  /// Lanza [FormatException] si la validación falla (mensaje apto para SnackBar).
  /// Lanza [Exception] si la API devuelve error.
  /// Devuelve el [Libro] listo para actualizar el estado local en caso de éxito.
  static Future<Libro> guardarLibro({
    required int? idExistente,
    required String titulo,
    required String autorNombre,
    required String sagaNombre,
    required String numLibroSagaTexto,
    required EstadoLibro estado,
    required double puntuacion,
    required DateTime? fechaInicio,
    required DateTime? fechaFin,
    required File? imagenSeleccionada,
    required String? rutaImagenExistente,
    required List<Propiedad> propiedades,
  }) async {
    if (titulo.trim().isEmpty) {
      throw const FormatException('El título es obligatorio');
    }

    final libro = Libro(
      id: idExistente,
      titulo: titulo.trim(),
      autorNombre: autorNombre,
      sagaNombre: sagaNombre.isEmpty ? null : sagaNombre,
      // Si no hay saga, el número de saga tampoco tiene sentido
      numLibroSaga: sagaNombre.isEmpty ? null : double.tryParse(numLibroSagaTexto),
      puntuacion: puntuacion,
      estado: estado,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      rutaImagen:
          imagenSeleccionada?.path ??
          rutaImagenExistente ??
          'assets/images/fondos/libro.png',
      almacen: AlmacenPropiedades(propiedades: propiedades),
    );

    final exito = await ApiService.guardarLibro(libro);
    if (!exito) throw Exception('El servidor no pudo procesar el guardado');

    return libro;
  }
}
