class Saga {
  final int? id;
  String nombre;
  int? totalLibros;

  Saga({this.id, required this.nombre, this.totalLibros});

  factory Saga.fromJson(Map<String, dynamic> json) {
    return Saga(
      id: json['id'] as int?,
      nombre: json['nombre'] as String,
      totalLibros: json['totalLibros'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      if (totalLibros != null) 'totalLibros': totalLibros,
    };
  }
}
