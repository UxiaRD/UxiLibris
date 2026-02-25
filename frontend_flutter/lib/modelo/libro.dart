// CLASE Libro

enum EstadoLibro { leyendo, pendiente, leido }

class Libro {
  int id;
  String titulo;
  String autor;
  double puntuacion;
  String rutaImagen;
  EstadoLibro estado;
  static int contadorId = 1;

  Libro({
    required this.titulo,
    required this.autor,
    required this.puntuacion,
    required this.rutaImagen,
    required this.estado,
  }) : id = contadorId++;

  // Constructor factory para crear un Libro desde un Map (JSON)
  factory Libro.fromJson(Map<String, dynamic> json) {
    return Libro(
      titulo: json['titulo'],
      autor: json['autor'],
      puntuacion: (json['puntuacion'] as num).toDouble(),
      rutaImagen: json['rutaImagen'],
      estado: EstadoLibro.values.firstWhere(
        (e) => e.name == json['estado'],
        orElse: () => EstadoLibro.pendiente,
      ),
    );
  }
}
