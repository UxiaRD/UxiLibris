import 'package:flutter/material.dart';
import 'package:frontend_flutter/controladores/formularioLibroController.dart';
import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/modelo/saga.dart';
import 'package:frontend_flutter/servicio/ApiService.dart';

/// Controlador estático con la lógica de presentación de la pantalla de detalle de libro.
class DetalleLibroController {
  /// Calcula el estado textual de la saga asociada al libro.
  /// El prefijo 'Saga' distingue visualmente estos badges del estado propio del libro.
  static String? estadoSaga(Saga? saga) {
    if (saga == null) return null;
    if (saga.abandonada) return 'Saga abandonada';
    final libros = Libreria.todosLosLibros
        .where((l) => l.sagaNombre == saga.nombre)
        .toList();
    final total = saga.totalLibros;
    if (total != null &&
        total > 0 &&
        libros.length == total &&
        libros.every((l) => l.estado == EstadoLibro.leido)) {
      return 'Saga completada';
    }
    return 'Saga en lectura';
  }

  static Color colorEstadoSaga(String estado) => switch (estado) {
        'Saga completada' => const Color(0xFF7B2FBE),
        'Saga abandonada' => Colors.red,
        _ => Colors.teal,
      };

  static String labelEstado(EstadoLibro e) => switch (e) {
        EstadoLibro.leido => 'Leído',
        EstadoLibro.leyendo => 'Leyendo',
        EstadoLibro.pendiente => 'Pendiente',
        EstadoLibro.deseo => 'Deseo',
      };

  static Color colorEstado(EstadoLibro e) => switch (e) {
        EstadoLibro.leido => Colors.green,
        EstadoLibro.leyendo => Colors.lightBlueAccent,
        EstadoLibro.pendiente => Colors.orange,
        EstadoLibro.deseo => const Color(0xFFE91E8C),
      };

  static String labelFormato(FormatoLibro f) => switch (f) {
        FormatoLibro.fisico => 'Físico',
        FormatoLibro.digital => 'Digital',
      };

  /// Formatea el número de volumen: entero si no tiene decimales (1.0 → "1"), float si los tiene (1.5 → "1.5").
  static String volumenStr(double v) =>
      v % 1 == 0 ? v.toInt().toString() : v.toString();

  /// Formatea una fecha en DD/MM/YYYY, o '—' si es null.
  static String formatDate(DateTime? d) => d == null
      ? '—'
      : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  /// Abre la galería, sube el fondo y devuelve la nueva ruta local, o null si falla.
  static Future<String?> seleccionarFondo(int libroId) async {
    final imagen = await FormularioLibroController.seleccionarImagen();
    if (imagen == null) return null;
    final ok = await ApiService.actualizarFondoLibro(libroId, imagen.path);
    return ok ? imagen.path : null;
  }

  /// Elimina el fondo en el servidor. Devuelve true si tuvo éxito.
  static Future<bool> quitarFondo(int libroId) async {
    return ApiService.actualizarFondoLibro(libroId, null);
  }
}