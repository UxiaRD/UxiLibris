import 'package:frontend_flutter/modelo/libro.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:frontend_flutter/servicio/ApiService.dart';

class Libreria {
  // Compartida por toda la app
  static List<Libro> todosLosLibros = [];
  List<Libro> libros;

  // Constructor que permite pasar una lista (uso en los filtros)
  Libreria({List<Libro>? libros}) : libros = libros ?? todosLosLibros;

  // Método estático para inicializar los datos
  static Future<Libreria> conDatosBackend() async {
    Libreria instancia = Libreria();
    await instancia._cargarDesdeBackend();
    return instancia;
  }

  // Sustituto de _cargarDesdeJson
  Future<void> _cargarDesdeBackend() async {
    try {
      // Usamos el ApiService que creamos para obtener los datos de Java
      final List<Libro> librosDesdeServidor = await ApiService.fetchLibros();

      // Actualizamos la lista compartida con los datos reales de MySQL
      todosLosLibros = librosDesdeServidor;
      libros = List.from(todosLosLibros);

      print(
        "Conexión con UxiLibrisDB exitosa: ${todosLosLibros.length} libros cargados.",
      );
    } catch (e) {
      print("Error al conectar con el Backend en Java: $e");
      // Opcional: podrías cargar una lista vacía para que la app no crashee
      todosLosLibros = [];
      libros = [];
    }
  }

  /// Añade un libro nuevo a la lista global
  void agregarLibro(Libro nuevo) {
    todosLosLibros.add(nuevo);
  }

  /// Actualiza los datos de un libro existente
  void editarLibro(Libro original, Libro modificado) {
    original.titulo = modificado.titulo;
    original.autorId = modificado.autorId;
    original.estado = modificado.estado;
    original.puntuacion = modificado.puntuacion;
    original.rutaImagen = modificado.rutaImagen;
  }

  /// Elimina un libro de la lista
  void eliminarLibro(Libro libro) {
    todosLosLibros.remove(libro);
  }

  // Método para filtrar por el estado del libro (leyendo, pendiente, leido)
  List<Libro> filtarPorEstado(String filtroEstado) {
    List<Libro> librosPorPestana = [];

    if (filtroEstado == "todos") {
      librosPorPestana = libros;
    } else {
      // Se filtra comparando el nombre del enum con el String que viene de la pestaña
      librosPorPestana = libros.where((libro) {
        return libro.estado.name == filtroEstado;
      }).toList();
    }
    return librosPorPestana;
  }

  // Método para filtrar por el texto de la barra de búsqueda
  List<Libro> filtrarPorBusqueda(String consulta) {
    List<Libro> librosBuscados = [];

    if (consulta.isEmpty) {
      librosBuscados = libros;
    } else {
      String busqueda = consulta.toLowerCase();

      librosBuscados = libros.where((libro) {
        // Busqueda por titulo o por autor
        return libro.titulo.toLowerCase().contains(busqueda);
      }).toList();
    }
    return librosBuscados;
  }

  List<Libro> obtenerTodos() {
    return libros;
  }
}
