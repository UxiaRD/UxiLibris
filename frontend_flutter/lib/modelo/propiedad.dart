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

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'tipo': tipo.name,
    'esOptativa': esOptativa,
    if (valor != null) 'valor': valor,
    if (opciones != null) 'opciones': opciones,
  };

  // Crea una Propiedad desde un mapa del JSON
  factory Propiedad.fromJson(Map<String, dynamic> json) {
    return Propiedad(
      nombre: json['nombre'] as String? ?? '',
      tipo: TipoDato.values.firstWhere(
        (e) => e.name.toLowerCase() == (json['tipo'] as String? ?? '').toLowerCase(),
        orElse: () => TipoDato.texto,
      ),
      esOptativa: json['esOptativa'] as bool? ?? true,
      valor: json['valor'],
      opciones: json['opciones'] != null
          ? List<String>.from(json['opciones'])
          : null,
    );
  }
}
