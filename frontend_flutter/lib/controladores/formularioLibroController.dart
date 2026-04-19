import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:frontend_flutter/modelo/almacenPropiedades.dart';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/modelo/propiedad.dart';
import 'package:frontend_flutter/servicio/ApiService.dart';
import 'package:frontend_flutter/servicio/SessionManager.dart';

class FormularioLibroController {
  /// Carga autores y sagas sugeridos del servidor en paralelo.
  /// Devuelve (autores, sagas). Silencia errores de red (devuelve listas vacías).
  static Future<(List<String>, List<String>)> cargarSugerencias() async {
    try {
      final results = await Future.wait([
        ApiService.fetchAutores(),
        ApiService.fetchSagas(),
      ]);
      return (results[0], results[1]);
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

  /// Calcula el historial de lecturas automáticamente al cambiar el estado.
  /// Es una función pura: no tiene efectos secundarios.
  ///
  /// - pendiente → sin cambios en lecturas existentes
  /// - leyendo   → añade lectura activa (sin fechaFin) si no hay ninguna
  /// - leido     → cierra la lectura activa con fechaFin=hoy; si no hay activa,
  ///               añade una lectura completada sólo si la lista estaba vacía
  static List<Lectura> calcularLecturasAutomaticas({
    required EstadoLibro nuevoEstado,
    required List<Lectura> lecturasActuales,
  }) {
    final ahora = DateTime.now();
    final lecturas = List<Lectura>.from(lecturasActuales);
    final idxActiva = lecturas.indexWhere((l) => l.fechaFin == null);
    final tieneActiva = idxActiva != -1;

    if (nuevoEstado == EstadoLibro.leyendo) {
      if (!tieneActiva) {
        lecturas.add(Lectura(fechaInicio: ahora));
      }
    } else if (nuevoEstado == EstadoLibro.leido) {
      if (tieneActiva) {
        lecturas[idxActiva] = lecturas[idxActiva].withFechaFin(ahora);
      } else if (lecturas.isEmpty) {
        lecturas.add(Lectura(fechaInicio: ahora, fechaFin: ahora));
      }
    }
    // pendiente: no se modifican las lecturas existentes

    return lecturas;
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
    required FormatoLibro formato,
    required double puntuacion,
    required List<Lectura> lecturas,
    required File? imagenSeleccionada,
    required String? rutaImagenExistente,
    required List<Propiedad> propiedades,
  }) async {
    if (titulo.trim().isEmpty) {
      throw const FormatException('El título es obligatorio');
    }

    final libro = Libro(
      id: idExistente,
      usuarioId: SessionManager.usuarioId,
      titulo: titulo.trim(),
      autorNombre: autorNombre,
      sagaNombre: sagaNombre.isEmpty ? null : sagaNombre,
      // Si no hay saga, el número de saga tampoco tiene sentido
      numLibroSaga: sagaNombre.isEmpty ? null : double.tryParse(numLibroSagaTexto),
      puntuacion: puntuacion,
      estado: estado,
      formato: formato,
      lecturas: lecturas,
      rutaImagen:
          imagenSeleccionada?.path ??
          rutaImagenExistente ??
          'assets/images/fondos/libro.png',
      almacen: AlmacenPropiedades(propiedades: propiedades),
    );

    final libroGuardado = await ApiService.guardarLibro(libro);
    if (libroGuardado == null) throw Exception('El servidor no pudo procesar el guardado');

    return libroGuardado;
  }
}