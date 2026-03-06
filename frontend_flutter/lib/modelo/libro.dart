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
      sagaNombre: json['sagaNombre'],
      // Usamos toDouble() para asegurar compatibilidad con la puntuación de 0.5
      numLibroSaga: json['numLibroSaga']?.toDouble(),
      puntuacion: json['puntuacion']?.toDouble(),
      estado: EstadoLibro.values.firstWhere(
        (e) => e.name.toLowerCase() == (json['estado'] as String).toLowerCase(),
        orElse: () => EstadoLibro.pendiente,
      ),
      fechaInicio: json['fechaInicio'] != null
          ? DateTime.parse(json['fechaInicio'])
          : null,
      fechaFin: json['fechaFin'] != null
          ? DateTime.parse(json['fechaFin'])
          : null,
      rutaImagen: json['rutaImagen'] ?? "assets/images/fondos/libro.png",

      // Cargamos el almacén desde la lista de propiedades del JSON
      almacen: AlmacenPropiedades.fromJson(json['propiedades'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'autorNombre': autorNombre,
      'sagaNombre': sagaNombre,
      'numLibroSaga': numLibroSaga, // Soporta el double (ej: 1.5)
      'puntuacion': puntuacion, // Soporta el paso de 0.5 [cite: 61, 78]
      'estado': estado.name, // Convertir Enum a String para Java
      'fechaInicio': fechaInicio?.toIso8601String(), // [cite: 60, 78]
      'fechaFin': fechaFin?.toIso8601String(), // [cite: 60, 78]
    };
  }
}
