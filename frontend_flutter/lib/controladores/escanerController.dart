import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/servicio/ApiService.dart';

class EscanerController {
  /// Valida el formato del ISBN y lo busca en la API.
  /// Lanza [FormatException] si el ISBN no tiene 10 o 13 dígitos.
  /// Devuelve null si no se encuentra ningún resultado.
  /// Lanza [Exception] si hay error de red.
  static Future<Libro?> buscarPorISBN(String isbn) async {
    final limpio = isbn.replaceAll(RegExp(r'[\s\-]'), '');
    if (limpio.length != 10 && limpio.length != 13) {
      throw const FormatException('El ISBN debe tener 10 o 13 dígitos');
    }
    return await ApiService.buscarLibroPorISBN(limpio);
  }
}
