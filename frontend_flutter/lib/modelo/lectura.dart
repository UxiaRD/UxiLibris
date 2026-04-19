class Lectura {
  final int? id;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const Lectura({this.id, this.fechaInicio, this.fechaFin});

  factory Lectura.fromJson(Map<String, dynamic> json) => Lectura(
    id: json['id'] as int?,
    fechaInicio: _parseDate(json['fechaInicio']),
    fechaFin: _parseDate(json['fechaFin']),
  );

  // Spring puede devolver LocalDate como "2024-01-15" (con write-dates-as-timestamps=false)
  // o como [2024, 1, 15] (comportamiento por defecto). Manejamos ambos.
  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) return DateTime.parse(raw);
    if (raw is List) return DateTime(raw[0] as int, raw[1] as int, raw[2] as int);
    return null;
  }

  // Envía solo la parte de fecha (YYYY-MM-DD) porque el backend usa LocalDate.
  // toIso8601String() produce un datetime completo que LocalDate no acepta.
  static String _toDateString(DateTime d) => d.toIso8601String().substring(0, 10);

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (fechaInicio != null) 'fechaInicio': _toDateString(fechaInicio!),
    if (fechaFin != null) 'fechaFin': _toDateString(fechaFin!),
  };

  Lectura withFechaInicio(DateTime? d) =>
      Lectura(id: id, fechaInicio: d, fechaFin: fechaFin);

  Lectura withFechaFin(DateTime? d) =>
      Lectura(id: id, fechaInicio: fechaInicio, fechaFin: d);

  bool get estaActiva => fechaFin == null;

  bool get estaCompletada => fechaFin != null;
}