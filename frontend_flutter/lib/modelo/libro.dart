// CLASE Libro

import 'package:frontend_flutter/modelo/almacenPropiedades.dart';

enum EstadoLibro { leyendo, pendiente, leido }

class Libro {
  final int? id; // ID de la base de datos SQL
  String titulo;
  int? autorId; // Relación con la tabla autoras
  String autorNombre; // Para mostrar en la App y usar en el Formulario
  int? sagaId; // Relación con la tabla sagas
  String? sagaNombre;
  double? numLibroSaga;
  double puntuacion;
  EstadoLibro estado; // El enum que ya tenías
  DateTime? fechaInicio;
  DateTime? fechaFin;
  String rutaImagen;

  // AQUÍ reside la personalización extrema
  AlmacenPropiedades almacen;

  Libro({
    this.id,
    required this.titulo,
    this.autorId,
    required this.autorNombre,
    this.sagaId,
    this.sagaNombre,
    this.numLibroSaga,
    this.puntuacion = 0.0,
    required this.estado,
    this.fechaInicio,
    this.fechaFin,
    required this.rutaImagen,
    required this.almacen,
  });

  // Constructor factory para crear un Libro desde un Map (JSON)
  factory Libro.fromJson(Map<String, dynamic> json) {
    return Libro(
      id: json['id'],
      titulo: json['titulo'],
      autorNombre: json['autorNombre'],
      sagaId: json['sagaId'],
      numLibroSaga: json['numLibroSaga'],
      puntuacion: (json['puntuacion'] as num?)?.toDouble() ?? 0.0,
      estado: EstadoLibro.values.firstWhere(
        (e) => e.name == json['estado'],
        orElse: () => EstadoLibro.pendiente,
      ),
      rutaImagen: json['rutaImagen'] ?? 'assets/images/fondos/libro.png',
      // Cargamos el almacén desde la lista de propiedades del JSON
      almacen: AlmacenPropiedades.fromJson(json['propiedades'] ?? []),
    );
  }
}
