import 'package:frontend_flutter/modelo/libro.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class Libreria {
  // Compartida por toda la app
  static List<Libro> todosLosLibros = [];

  List<Libro> libros;

  // Constructor que permite pasar una lista (uso en los filtros)
  Libreria({List<Libro>? libros}) : libros = libros ?? todosLosLibros;

  // Método estático para inicializar los datos
  static Future<Libreria> conDatosLocal() async {
    Libreria instancia = Libreria();
    await instancia._cargarDesdeJson();
    return instancia;
  }

  // Método de carga de los datos desde JSON
  Future<void> _cargarDesdeJson() async {
    try {
      // Cargar el String del archivo
      final String respuesta = await rootBundle.loadString(
        'assets/libros.json',
      );

      // Decodificar a una lista dinámica
      final List<dynamic> datos = json.decode(respuesta);

      // Convertir cada elemento en una instancia de Libro y llenar las lista estática
      todosLosLibros = datos.map((json) => Libro.fromJson(json)).toList();

      // También llenamos la lista de la instancia actual
      libros = List.from(todosLosLibros);
    } catch (e) {
      print("Error al cargar JSON: $e");
    }
  }

  /// Añade un libro nuevo a la lista global
  void agregarLibro(Libro nuevo) {
    todosLosLibros.add(nuevo);
  }

  /// Actualiza los datos de un libro existente
  void editarLibro(Libro original, Libro modificado) {
    original.titulo = modificado.titulo;
    original.autor = modificado.autor;
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
        return libro.titulo.toLowerCase().contains(busqueda) ||
            libro.autor.toLowerCase().contains(busqueda);
      }).toList();
    }
    return librosBuscados;
  }

  List<Libro> obtenerTodos() {
    return libros;
  }
}
