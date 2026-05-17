import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/servicio/ApiService.dart';

/// Controlador estático para la pantalla de búsqueda de libros en Google Books.
class BusquedaLibrosControlador {
  /// Lanza la búsqueda en la API de Google Books a través del backend.
  static Future<List<Libro>> buscar(String query) =>
      ApiService.buscarLibrosPorTexto(query);

  /// Comprueba si ya existe un libro con el mismo título en la biblioteca local.
  static bool tieneDuplicado(Libro libro) =>
      Libreria.todosLosLibros.any(
        (l) => l.titulo.toLowerCase() == libro.titulo.toLowerCase(),
      );
}