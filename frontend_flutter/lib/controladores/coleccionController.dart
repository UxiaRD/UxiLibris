import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/servicio/ApiService.dart';

class ColeccionController {
  /// Devuelve la lista de libros del usuario.
  /// Si ya hay datos en caché local, los devuelve sin llamar al servidor.
  static Future<List<Libro>> cargarLibros() async {
    if (Libreria.todosLosLibros.isNotEmpty) return Libreria.todosLosLibros;

    final libros = await ApiService.fetchLibros();
    Libreria.todosLosLibros = libros;
    return libros;
  }
}
