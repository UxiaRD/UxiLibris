import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_flutter/modelo/lectura.dart';

void main() {
  group('Lectura.fromJson', () {
    test('parsea fechas en formato string ISO', () {
      final lectura = Lectura.fromJson({
        'id': 1,
        'fechaInicio': '2024-01-15',
        'fechaFin': '2024-02-20',
      });

      expect(lectura.id, 1);
      expect(lectura.fechaInicio, DateTime(2024, 1, 15));
      expect(lectura.fechaFin, DateTime(2024, 2, 20));
    });

    test('parsea fechas en formato array [año, mes, día]', () {
      final lectura = Lectura.fromJson({
        'fechaInicio': [2024, 3, 10],
        'fechaFin': [2024, 4, 5],
      });

      expect(lectura.fechaInicio, DateTime(2024, 3, 10));
      expect(lectura.fechaFin, DateTime(2024, 4, 5));
    });

    test('acepta fechaFin null para lecturas en curso', () {
      final lectura = Lectura.fromJson({'fechaInicio': '2024-01-01'});

      expect(lectura.fechaFin, isNull);
    });

    test('acepta json completamente vacío', () {
      final lectura = Lectura.fromJson({});

      expect(lectura.fechaInicio, isNull);
      expect(lectura.fechaFin, isNull);
    });
  });

  group('Lectura.toJson', () {
    test('serializa fechas en formato YYYY-MM-DD', () {
      final lectura = Lectura(
        id: 1,
        fechaInicio: DateTime(2024, 1, 15),
        fechaFin: DateTime(2024, 2, 20),
      );

      final json = lectura.toJson();

      expect(json['id'], 1);
      expect(json['fechaInicio'], '2024-01-15');
      expect(json['fechaFin'], '2024-02-20');
    });

    test('omite fechaFin si es null', () {
      final lectura = Lectura(fechaInicio: DateTime(2024, 1, 1));

      final json = lectura.toJson();

      expect(json.containsKey('fechaFin'), isFalse);
    });

    test('omite id si es null', () {
      final lectura = Lectura(fechaInicio: DateTime(2024, 1, 1));

      final json = lectura.toJson();

      expect(json.containsKey('id'), isFalse);
    });
  });

  group('Lectura.estaActiva / estaCompletada', () {
    test('estaActiva es true cuando fechaFin es null', () {
      final lectura = Lectura(fechaInicio: DateTime(2024, 1, 1));

      expect(lectura.estaActiva, isTrue);
      expect(lectura.estaCompletada, isFalse);
    });

    test('estaCompletada es true cuando fechaFin no es null', () {
      final lectura = Lectura(
        fechaInicio: DateTime(2024, 1, 1),
        fechaFin: DateTime(2024, 2, 1),
      );

      expect(lectura.estaCompletada, isTrue);
      expect(lectura.estaActiva, isFalse);
    });
  });

  group('Lectura.withFechaInicio', () {
    test('crea copia con nueva fecha de inicio preservando el resto', () {
      final original = Lectura(
        id: 5,
        fechaInicio: DateTime(2024, 1, 1),
        fechaFin: DateTime(2024, 2, 1),
      );

      final copia = original.withFechaInicio(DateTime(2024, 3, 15));

      expect(copia.id, 5);
      expect(copia.fechaInicio, DateTime(2024, 3, 15));
      expect(copia.fechaFin, DateTime(2024, 2, 1));
    });

    test('no modifica el objeto original', () {
      final original = Lectura(fechaInicio: DateTime(2024, 1, 1));

      original.withFechaInicio(DateTime(2025, 6, 1));

      expect(original.fechaInicio, DateTime(2024, 1, 1));
    });
  });

  group('Lectura.withFechaFin', () {
    test('crea copia con nueva fecha de fin preservando el resto', () {
      final original = Lectura(
        id: 3,
        fechaInicio: DateTime(2024, 1, 1),
      );

      final copia = original.withFechaFin(DateTime(2024, 12, 31));

      expect(copia.id, 3);
      expect(copia.fechaInicio, DateTime(2024, 1, 1));
      expect(copia.fechaFin, DateTime(2024, 12, 31));
    });
  });
}