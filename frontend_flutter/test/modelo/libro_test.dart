import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_flutter/modelo/almacenPropiedades.dart';
import 'package:frontend_flutter/modelo/libro.dart';

Libro _libroMinimo({EstadoLibro estado = EstadoLibro.pendiente}) => Libro(
  titulo: 'Título de prueba',
  autorNombre: 'Autor de prueba',
  estado: estado,
  rutaImagen: 'assets/images/fondos/libro.png',
  almacen: AlmacenPropiedades.fromJson([]),
);

void main() {
  group('Libro.fromJson', () {
    test('parsea todos los campos correctamente', () {
      final libro = Libro.fromJson({
        'id': 1,
        'usuarioId': 42,
        'titulo': 'El Señor de los Anillos',
        'autorNombre': 'J.R.R. Tolkien',
        'sagaNombre': 'El Señor de los Anillos',
        'numLibroSaga': 1.0,
        'puntuacion': 4.5,
        'estado': 'leido',
        'formato': 'fisico',
        'lecturas': [],
        'favorito': true,
        'rutaImagen': 'ruta/imagen.png',
        'propiedades': [],
      });

      expect(libro.id, 1);
      expect(libro.usuarioId, 42);
      expect(libro.titulo, 'El Señor de los Anillos');
      expect(libro.autorNombre, 'J.R.R. Tolkien');
      expect(libro.sagaNombre, 'El Señor de los Anillos');
      expect(libro.numLibroSaga, 1.0);
      expect(libro.puntuacion, 4.5);
      expect(libro.estado, EstadoLibro.leido);
      expect(libro.formato, FormatoLibro.fisico);
      expect(libro.favorito, isTrue);
      expect(libro.lecturas, isEmpty);
    });

    test('aplica valores por defecto cuando los campos son null o ausentes', () {
      final libro = Libro.fromJson({
        'titulo': 'Mínimo',
        'autorNombre': 'Autor',
        'propiedades': [],
      });

      expect(libro.puntuacion, 0.0);
      expect(libro.estado, EstadoLibro.pendiente);
      expect(libro.formato, FormatoLibro.fisico);
      expect(libro.favorito, isFalse);
      expect(libro.rutaImagen, 'assets/images/fondos/libro.png');
      expect(libro.sagaNombre, isNull);
    });

    test('estado desconocido se convierte a pendiente', () {
      final libro = Libro.fromJson({
        'titulo': 'Test',
        'autorNombre': 'Autor',
        'estado': 'estadoInventado',
        'propiedades': [],
      });

      expect(libro.estado, EstadoLibro.pendiente);
    });

    test('estado en mayúsculas se parsea correctamente', () {
      final libro = Libro.fromJson({
        'titulo': 'Test',
        'autorNombre': 'Autor',
        'estado': 'LEYENDO',
        'propiedades': [],
      });

      expect(libro.estado, EstadoLibro.leyendo);
    });

    test('parsea lecturas anidadas', () {
      final libro = Libro.fromJson({
        'titulo': 'Test',
        'autorNombre': 'Autor',
        'lecturas': [
          {'fechaInicio': '2024-01-01', 'fechaFin': '2024-02-01'},
          {'fechaInicio': '2024-03-01'},
        ],
        'propiedades': [],
      });

      expect(libro.lecturas, hasLength(2));
      expect(libro.lecturas[0].estaCompletada, isTrue);
      expect(libro.lecturas[1].estaActiva, isTrue);
    });
  });

  group('Libro.toJson', () {
    test('serializa el estado en mayúsculas', () {
      final libro = _libroMinimo(estado: EstadoLibro.leyendo);

      expect(libro.toJson()['estado'], 'LEYENDO');
    });

    test('serializa el formato en mayúsculas', () {
      final libro = Libro(
        titulo: 'Test',
        autorNombre: 'Autor',
        estado: EstadoLibro.pendiente,
        formato: FormatoLibro.digital,
        rutaImagen: 'ruta',
        almacen: AlmacenPropiedades.fromJson([]),
      );

      expect(libro.toJson()['formato'], 'DIGITAL');
    });

    test('no incluye id si es null', () {
      final libro = _libroMinimo();

      expect(libro.toJson().containsKey('id'), isFalse);
    });

    test('round-trip fromJson → toJson → fromJson mantiene los datos', () {
      final original = Libro.fromJson({
        'id': 5,
        'titulo': 'Dune',
        'autorNombre': 'Frank Herbert',
        'sagaNombre': 'Dune',
        'numLibroSaga': 1.0,
        'puntuacion': 5.0,
        'estado': 'leido',
        'formato': 'digital',
        'lecturas': [],
        'favorito': false,
        'rutaImagen': 'assets/dune.png',
        'propiedades': [],
      });

      final reconstructido = Libro.fromJson(original.toJson());

      expect(reconstructido.titulo, original.titulo);
      expect(reconstructido.estado, original.estado);
      expect(reconstructido.formato, original.formato);
      expect(reconstructido.puntuacion, original.puntuacion);
      expect(reconstructido.sagaNombre, original.sagaNombre);
    });
  });

  group('Libro.withEstado', () {
    test('crea una copia con el nuevo estado', () {
      final libro = _libroMinimo(estado: EstadoLibro.pendiente);

      final copia = libro.withEstado(EstadoLibro.leyendo);

      expect(copia.estado, EstadoLibro.leyendo);
      expect(copia.titulo, libro.titulo);
      expect(copia.autorNombre, libro.autorNombre);
    });

    test('no modifica el objeto original', () {
      final libro = _libroMinimo(estado: EstadoLibro.pendiente);

      libro.withEstado(EstadoLibro.leido);

      expect(libro.estado, EstadoLibro.pendiente);
    });

    test('preserva todos los campos al copiar', () {
      final libro = Libro.fromJson({
        'id': 10,
        'titulo': 'Test',
        'autorNombre': 'Autor',
        'sagaNombre': 'Una Saga',
        'numLibroSaga': 2.0,
        'puntuacion': 3.5,
        'estado': 'pendiente',
        'formato': 'digital',
        'lecturas': [],
        'favorito': true,
        'rutaImagen': 'ruta',
        'propiedades': [],
      });

      final copia = libro.withEstado(EstadoLibro.leido);

      expect(copia.id, libro.id);
      expect(copia.sagaNombre, libro.sagaNombre);
      expect(copia.puntuacion, libro.puntuacion);
      expect(copia.favorito, libro.favorito);
    });
  });
}