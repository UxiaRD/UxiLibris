import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/servicio/ApiService.dart';

class GestionLibroController {
  /// Elimina el libro del servidor y de la lista local en memoria.
  /// No hace nada si el libro no tiene ID.
  /// Lanza [Exception] si el servidor no confirma la eliminación.
  static Future<void> eliminarLibro(Libro libro) async {
    final id = libro.id;
    if (id == null) return;

    final exito = await ApiService.eliminarLibro(id);
    if (!exito) throw Exception('No se pudo eliminar el libro');

    Libreria().eliminarLibro(libro);
  }
}
