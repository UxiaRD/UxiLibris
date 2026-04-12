import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/modelo/libro.dart';

class EstadisticasController {
  /// Libros con estado "leído" y fecha de fin registrada
  static List<Libro> get leidos => Libreria.todosLosLibros
      .where((l) => l.estado == EstadoLibro.leido && l.fechaFin != null)
      .toList();

  /// Años distintos con al menos un libro leído, ordenados de menor a mayor
  static List<int> get anios {
    final lista = leidos.map((l) => l.fechaFin!.year).toSet().toList();
    lista.sort();
    return lista;
  }

  /// Mapa mes (1-12) → cantidad de libros leídos en ese mes del año dado
  static Map<int, int> librosPorMes(int anio) {
    final mapa = {for (int i = 1; i <= 12; i++) i: 0};
    for (final l in leidos.where((l) => l.fechaFin!.year == anio)) {
      mapa[l.fechaFin!.month] = mapa[l.fechaFin!.month]! + 1;
    }
    return mapa;
  }

  /// Top N autores por número de libros leídos
  static List<MapEntry<String, int>> topAutores(int n) {
    final conteo = <String, int>{};
    for (final l in leidos) {
      conteo[l.autorNombre] = (conteo[l.autorNombre] ?? 0) + 1;
    }
    return (conteo.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(n)
        .toList();
  }

  /// Top N libros por puntuación (incluye todos los estados)
  static List<Libro> topPuntuados(int n) {
    return (Libreria.todosLosLibros
            .where((l) => l.puntuacion > 0)
            .toList()
          ..sort((a, b) => b.puntuacion.compareTo(a.puntuacion)))
        .take(n)
        .toList();
  }

  /// Media de puntuación de los libros leídos con puntuación registrada
  static String get mediaPuntuacion {
    final con = leidos.where((l) => l.puntuacion > 0).toList();
    if (con.isEmpty) return '—';
    final media =
        con.map((l) => l.puntuacion).reduce((a, b) => a + b) / con.length;
    return media.toStringAsFixed(1);
  }

  /// Autor con más libros leídos
  static String get autorFavorito {
    final top = topAutores(1);
    return top.isEmpty ? '—' : top.first.key;
  }
}