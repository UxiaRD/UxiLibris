import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/modelo/libro.dart';

class EstadisticasController {
  static Iterable<Lectura> get _lecturasCompletadas => Libreria.todosLosLibros
      .expand((l) => l.lecturas)
      .where((lec) => lec.fechaFin != null);

  static Iterable<Lectura> _lecturasDeAnio(int anio) =>
      _lecturasCompletadas.where((l) => l.fechaFin!.year == anio);

  /// Libros con al menos una lectura completada (todos los tiempos).
  static List<Libro> get leidos => Libreria.todosLosLibros
      .where((l) => l.lecturas.any((lec) => lec.fechaFin != null))
      .toList();

  /// Libros con al menos una lectura completada en el año dado.
  static List<Libro> leidosEnAnio(int anio) => Libreria.todosLosLibros
      .where((l) => l.lecturas.any((lec) => lec.fechaFin?.year == anio))
      .toList();

  /// Años distintos con al menos una lectura completada, ordenados de menor a mayor.
  static List<int> get anios {
    final lista = _lecturasCompletadas.map((l) => l.fechaFin!.year).toSet().toList();
    lista.sort();
    return lista;
  }

  /// Número de lecturas completadas en un año concreto.
  static int lecturasEnAnio(int anio) => _lecturasDeAnio(anio).length;

  /// Total de lecturas completadas de todos los tiempos.
  static int get totalLecturas => _lecturasCompletadas.length;

  /// Mapa mes (1-12) → cantidad de lecturas completadas en ese mes del año dado.
  static Map<int, int> librosPorMes(int anio) {
    final mapa = {for (int i = 1; i <= 12; i++) i: 0};
    for (final lec in _lecturasDeAnio(anio)) {
      mapa[lec.fechaFin!.month] = mapa[lec.fechaFin!.month]! + 1;
    }
    return mapa;
  }

  /// Top N autores por número de lecturas completadas en el año dado.
  static List<MapEntry<String, int>> topAutores(int n, int anio) {
    final conteo = <String, int>{};
    for (final libro in Libreria.todosLosLibros) {
      final completadas = libro.lecturas
          .where((l) => l.fechaFin?.year == anio)
          .length;
      if (completadas > 0) {
        conteo[libro.autorNombre] = (conteo[libro.autorNombre] ?? 0) + completadas;
      }
    }
    return (conteo.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(n)
        .toList();
  }

  /// Top N libros por puntuación entre los leídos en el año dado.
  static List<Libro> topPuntuados(int n, int anio) {
    return (leidosEnAnio(anio)
            .where((l) => l.puntuacion > 0)
            .toList()
          ..sort((a, b) => b.puntuacion.compareTo(a.puntuacion)))
        .take(n)
        .toList();
  }

  /// Media de puntuación de los libros leídos en el año dado con puntuación registrada.
  static String mediaPuntuacion(int anio) {
    final con = leidosEnAnio(anio).where((l) => l.puntuacion > 0).toList();
    if (con.isEmpty) return '—';
    final media = con.map((l) => l.puntuacion).reduce((a, b) => a + b) / con.length;
    return media.toStringAsFixed(1);
  }

  /// Autor con más lecturas completadas en el año dado.
  static String autorFavorito(int anio) {
    final top = topAutores(1, anio);
    return top.isEmpty ? '—' : top.first.key;
  }

  /// Libros marcados como favorito con al menos una lectura completada en el año dado,
  /// ordenados por puntuación descendente.
  static List<Libro> favoritos(int anio) {
    return (leidosEnAnio(anio)
            .where((l) => l.favorito)
            .toList()
          ..sort((a, b) => b.puntuacion.compareTo(a.puntuacion)));
  }
}