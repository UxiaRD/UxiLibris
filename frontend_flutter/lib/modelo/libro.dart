// CLASE Libro

import 'package:frontend_flutter/modelo/almacenPropiedades.dart';
import 'package:frontend_flutter/modelo/lectura.dart';

export 'package:frontend_flutter/modelo/lectura.dart';

enum EstadoLibro { leyendo, pendiente, leido, deseo }

enum FormatoLibro { fisico, digital }

class Libro {
  final int? id; // ID de la base de datos SQL
  int? usuarioId; // Relación con la tabla usuarios
  String titulo;
  int? autorId; // Relación con la tabla autoras
  String
  autorNombre; // Para mostrar en la App y usar en el utilidades/formularioLibro.dart
  int? sagaId; // Relación con la tabla sagas
  String? sagaNombre; // Para mostrar en la App
  double? numLibroSaga;
  double puntuacion;
  EstadoLibro estado;
  FormatoLibro formato;
  List<Lectura> lecturas;
  bool favorito;
  String rutaImagen;
  String? rutaFondo;

  // Base para la personalización
  AlmacenPropiedades almacen;

  // Constructor
  Libro({
    this.id,
    this.usuarioId,
    required this.titulo,
    this.autorId,
    required this.autorNombre,
    this.sagaId,
    this.sagaNombre,
    this.numLibroSaga,
    this.puntuacion = 0.0,
    required this.estado,
    this.formato = FormatoLibro.fisico,
    List<Lectura>? lecturas,
    this.favorito = false,
    required this.rutaImagen,
    this.rutaFondo,
    required this.almacen,
  }) : lecturas = lecturas ?? [];

  // Constructor factory para crear un Libro desde un Map (JSON)
  // Recibir el Libro del JSON
  factory Libro.fromJson(Map<String, dynamic> json) {
    return Libro(
      id: json['id'],
      usuarioId: json['usuarioId'] as int?,
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
      formato: FormatoLibro.values.firstWhere(
        (f) =>
            f.name.toLowerCase() ==
            (json['formato'] as String? ?? 'fisico').toLowerCase(),
        orElse: () => FormatoLibro.fisico,
      ),
      lecturas: (json['lecturas'] as List<dynamic>? ?? [])
          .map((e) => Lectura.fromJson(e as Map<String, dynamic>))
          .toList(),
      favorito: json['favorito'] as bool? ?? false,
      rutaImagen: json['rutaImagen'] ?? "assets/images/fondos/libro.png",
      rutaFondo: json['rutaFondo'] as String?,
      almacen: AlmacenPropiedades.fromJson(json['propiedades'] ?? []),
    );
  }

  Libro withEstado(EstadoLibro nuevoEstado) => Libro(
    id: id,
    usuarioId: usuarioId,
    titulo: titulo,
    autorNombre: autorNombre,
    sagaId: sagaId,
    sagaNombre: sagaNombre,
    numLibroSaga: numLibroSaga,
    puntuacion: puntuacion,
    estado: nuevoEstado,
    formato: formato,
    lecturas: List.from(lecturas),
    favorito: favorito,
    rutaImagen: rutaImagen,
    almacen: almacen,
  );

  // Enviar el Libro con JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (usuarioId != null) 'usuarioId': usuarioId,
      'titulo': titulo,
      'autorNombre': autorNombre,
      'sagaNombre': sagaNombre,
      'numLibroSaga': numLibroSaga,
      'puntuacion': puntuacion,
      'estado': estado.name.toUpperCase(),
      'formato': formato.name.toUpperCase(),
      'lecturas': lecturas.map((l) => l.toJson()).toList(),
      'favorito': favorito,
      'rutaImagen': rutaImagen,
      if (rutaFondo != null) 'rutaFondo': rutaFondo,
      'propiedades': almacen.propiedades.map((p) => p.toJson()).toList(),
    };
  }
}