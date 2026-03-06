import 'dart:convert';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // URL base para el emulador de Android (localhost de la máquina)
  static const String baseUrl = "http://10.0.2.2:8080/api/libros";

  static Future<List<Libro>> fetchLibros() async {
    try {
      // Realizamos la petición GET al endpoint principal
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        // Decodificamos el cuerpo de la respuesta (un JSON Array)
        List<dynamic> body = json.decode(response.body);

        // Mapeamos cada elemento del JSON a una instancia de la clase Libro
        return body.map((dynamic item) => Libro.fromJson(item)).toList();
      } else {
        throw Exception("Error del servidor: ${response.statusCode}");
      }
    } catch (e) {
      // Si el backend está apagado o no hay internet, propagamos el error
      print("Error en ApiService.fetchLibros: $e");
      rethrow;
    }
  }

  // 1. Obtener autores para el Autocomplete [cite: 62, 78]
  static Future<List<String>> fetchAutores() async {
    final response = await http.get(Uri.parse("$baseUrl/autores"));
    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body));
    }
    return [];
  }

  // 2. Obtener sagas para el Autocomplete [cite: 52, 78]
  static Future<List<String>> fetchSagas() async {
    final response = await http.get(Uri.parse("$baseUrl/sagas"));
    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body));
    }
    return [];
  }

  // 3. Obtener sugerencia de volumen
  static Future<double> fetchSugerenciaVolumen(String saga) async {
    final response = await http.get(
      Uri.parse("$baseUrl/sugerir-volumen?saga=$saga"),
    );
    if (response.statusCode == 200) {
      return double.parse(response.body);
    }
    return 1.0;
  }

  // 4. Guardar un nuevo libro
  static Future<bool> guardarLibro(Libro libro) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(
        libro.toJson(),
      ), // Debes tener el método toJson en tu modelo
    );
    return response.statusCode == 200;
  }
}
