// CLASE Libro

import 'package:frontend_flutter/modelo/almacenPropiedades.dart';

enum EstadoLibro { leyendo, pendiente, leido }

class Libro {
  final int? id; // ID de la base de datos SQL
  String titulo;
  int? autorId; // Relación con la tabla autoras
  String
  autorNombre; // Para mostrar en la App y usar en el utilidades/formularioLibro.dart
  int? sagaId; // Relación con la tabla sagas
  String? sagaNombre; // Para mostrar en la App
  double? numLibroSaga;
  double puntuacion;
  EstadoLibro estado;
  DateTime? fechaInicio;
  DateTime? fechaFin;
  String rutaImagen;

  // Base para la personalización
  AlmacenPropiedades almacen;

  // Constructor
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
  // Recibir el Libro del JSON
  factory Libro.fromJson(Map<String, dynamic> json) {
    return Libro(
      id: json['id'],
      titulo: json['titulo'],
      autorNombre: json['autorNombre'],
      sagaNombre: json['sagaNombre'],
      numLibroSaga: json['numLibroSaga']?.toDouble(),
      puntuacion: json['puntuacion']?.toDouble() ?? 0.0,
      estado: EstadoLibro.values.firstWhere(
        (e) =>
            e.name.toLowerCase() ==
            (json['estado'] as String? ?? 'pendiente').toLowerCase(),
        orElse: () => EstadoLibro.pendiente,
      ),
      fechaInicio: json['fechaInicio'] != null
          ? DateTime.parse(json['fechaInicio'])
          : null,
      fechaFin: json['fechaFin'] != null
          ? DateTime.parse(json['fechaFin'])
          : null,
      rutaImagen: json['rutaImagen'] ?? "assets/images/fondos/libro.png",

      // Se carga el almacén desde la lista de propiedades del JSON
      almacen: AlmacenPropiedades.fromJson(json['propiedades'] ?? []),
    );
  }

  // Enviar el Libro con JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'titulo': titulo,
      'autorNombre': autorNombre,
      'sagaNombre': sagaNombre,
      'numLibroSaga': numLibroSaga,
      'puntuacion': puntuacion,
      'estado': estado.name.toUpperCase(),
      'fechaInicio': fechaInicio?.toIso8601String(),
      'fechaFin': fechaFin?.toIso8601String(),
      'rutaImagen': rutaImagen,
    };
  }
}
