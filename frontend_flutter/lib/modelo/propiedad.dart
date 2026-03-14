enum TipoDato { texto, numero, lista, fecha, relacion }

class Propiedad {
  final String nombre;
  final TipoDato tipo;
  final bool esOptativa;

  // El valor puede ser un String, un int, o un objeto
  dynamic valor;

  // Si es tipo 'lista', aquí guardamos las opciones disponibles (ej: Editoriales)
  List<String>? opciones;

  Propiedad({
    required this.nombre,
    required this.tipo,
    this.esOptativa = true,
    this.valor,
    this.opciones,
  });

  // Método para facilitar la copia de la propiedad al editar
  Propiedad copyWith({dynamic nuevoValor}) {
    return Propiedad(
      nombre: nombre,
      tipo: tipo,
      esOptativa: esOptativa,
      valor: nuevoValor ?? valor,
      opciones: opciones,
    );
  }

  // Crea una Propiedad desde un mapa del JSON
  factory Propiedad.fromJson(Map<String, dynamic> json) {
    return Propiedad(
      nombre: json['nombre'],
      tipo: TipoDato.values.firstWhere((e) => e.name == json['tipo']),
      esOptativa: json['esOptativa'] ?? true,
      valor: json['valor'],
      opciones: json['opciones'] != null
          ? List<String>.from(json['opciones'])
          : null,
    );
  }
}
