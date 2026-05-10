import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_flutter/modelo/almacenPropiedades.dart';
import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/modelo/libro.dart';

Libro _libro({
  required String titulo,
  required EstadoLibro estado,
  String autorNombre = 'Autor',
  String? sagaNombre,
}) => Libro(
  titulo: titulo,
  autorNombre: autorNombre,
  estado: estado,
  rutaImagen: 'ruta',
  sagaNombre: sagaNombre,
  almacen: AlmacenPropiedades.fromJson([]),
);

void main() {
  setUp(() => Libreria.todosLosLibros = []);

  group('Libreria.filtrarPorEstado', () {
    test('filtro "todos" excluye libros en lista de deseos', () {
      final libreria = Libreria(libros: [
        _libro(titulo: 'Leído',     estado: EstadoLibro.leido),
        _libro(titulo: 'Pendiente', estado: EstadoLibro.pendiente),
        _libro(titulo: 'Deseo',     estado: EstadoLibro.deseo),
      ]);

      final resultado = libreria.filtrarPorEstado('todos');

      expect(resultado, hasLength(2));
      expect(resultado.any((l) => l.estado == EstadoLibro.deseo), isFalse);
    });

    test('filtro por estado concreto devuelve solo ese estado', () {
      final libreria = Libreria(libros: [
        _libro(titulo: 'L1', estado: EstadoLibro.leido),
        _libro(titulo: 'L2', estado: EstadoLibro.pendiente),
        _libro(titulo: 'L3', estado: EstadoLibro.leyendo),
      ]);

      final resultado = libreria.filtrarPorEstado('leido');

      expect(resultado, hasLength(1));
      expect(resultado.first.titulo, 'L1');
    });

    test('devuelve lista vacía si no hay libros con ese estado', () {
      final libreria = Libreria(libros: [
        _libro(titulo: 'Pendiente', estado: EstadoLibro.pendiente),
      ]);

      expect(libreria.filtrarPorEstado('leido'), isEmpty);
    });

    test('filtro "todos" sobre librería vacía devuelve lista vacía', () {
      final libreria = Libreria(libros: []);

      expect(libreria.filtrarPorEstado('todos'), isEmpty);
    });
  });

  group('Libreria.filtrarPorBusqueda', () {
    test('consulta vacía devuelve todos los libros', () {
      final libreria = Libreria(libros: [
        _libro(titulo: 'Dune',       estado: EstadoLibro.leido),
        _libro(titulo: 'Foundation', estado: EstadoLibro.pendiente),
      ]);

      expect(libreria.filtrarPorBusqueda(''), hasLength(2));
    });

    test('búsqueda por título es case-insensitive', () {
      final libreria = Libreria(libros: [
        _libro(titulo: 'El Señor de los Anillos', estado: EstadoLibro.leido),
        _libro(titulo: 'Dune',                    estado: EstadoLibro.pendiente),
      ]);

      final resultado = libreria.filtrarPorBusqueda('señor');

      expect(resultado, hasLength(1));
      expect(resultado.first.titulo, 'El Señor de los Anillos');
    });

    test('búsqueda por autor funciona correctamente', () {
      final libreria = Libreria(libros: [
        _libro(titulo: 'Dune',       estado: EstadoLibro.leido,     autorNombre: 'Frank Herbert'),
        _libro(titulo: 'Foundation', estado: EstadoLibro.pendiente, autorNombre: 'Isaac Asimov'),
      ]);

      final resultado = libreria.filtrarPorBusqueda('asimov');

      expect(resultado, hasLength(1));
      expect(resultado.first.titulo, 'Foundation');
    });

    test('búsqueda por nombre de saga funciona correctamente', () {
      final libreria = Libreria(libros: [
        _libro(titulo: 'Libro A', estado: EstadoLibro.leido,     sagaNombre: 'Saga Galáctica'),
        _libro(titulo: 'Libro B', estado: EstadoLibro.pendiente, sagaNombre: null),
      ]);

      final resultado = libreria.filtrarPorBusqueda('galáctica');

      expect(resultado, hasLength(1));
      expect(resultado.first.titulo, 'Libro A');
    });

    test('consulta sin coincidencias devuelve lista vacía', () {
      final libreria = Libreria(libros: [
        _libro(titulo: 'Dune', estado: EstadoLibro.leido),
      ]);

      expect(libreria.filtrarPorBusqueda('xyz123nada'), isEmpty);
    });

    test('un libro puede coincidir por título y saga simultáneamente', () {
      final libreria = Libreria(libros: [
        _libro(titulo: 'Dune', estado: EstadoLibro.leido, sagaNombre: 'Dune'),
      ]);

      // Solo debe aparecer una vez aunque coincida en dos campos
      expect(libreria.filtrarPorBusqueda('dune'), hasLength(1));
    });
  });
}