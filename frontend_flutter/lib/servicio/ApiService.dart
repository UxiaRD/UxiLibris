import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_flutter/modelo/almacenPropiedades.dart';

class ApiService {
  // Detectamos la plataforma automáticamente para no tener que cambiar
  // el host a mano cada vez que cambiamos entre web y emulador Android:
  //
  //  · Web (kIsWeb = true)        → localhost  (el navegador habla directamente
  //                                              con el backend en tu máquina)
  //  · Emulador Android           → 10.0.2.2   (alias especial del emulador
  //                                              que apunta a la máquina host)
  //  · Dispositivo físico Android → cambia 10.0.2.2 por la IP local de tu
  //                                  máquina, ej: '192.168.1.50'
  static String get _host {
    if (kIsWeb) return 'localhost';
    return '192.168.1.200'; // emular en dispositivo físico
    //return '10.0.2.2'; // emulador Android
  }

  static const String _puerto = '8080';

  // baseUrl es ahora un getter (no const) porque _host también lo es
  static String get baseUrl => 'http://$_host:$_puerto/api';

  static Future<List<Libro>> fetchLibros() async {
    try {
      // Realizamos la petición GET al endpoint principal
      final response = await http.get(Uri.parse('$baseUrl/libros'));

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

  // 1. Obtener autores para el Autocomplete
  static Future<List<String>> fetchAutores() async {
    final response = await http.get(Uri.parse("$baseUrl/libros/autores"));
    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body));
    }
    return [];
  }

  // 2. Obtener sagas para el Autocomplete
  static Future<List<String>> fetchSagas() async {
    final response = await http.get(Uri.parse("$baseUrl/libros/sagas"));
    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body));
    }
    return [];
  }

  // 3. Obtener sugerencia de volumen
  static Future<double> fetchSugerenciaVolumen(String saga) async {
    final response = await http.get(
      Uri.parse("$baseUrl/libros/sugerir-volumen?saga=$saga"),
    );
    if (response.statusCode == 200) {
      return double.parse(response.body);
    }
    return 1.0;
  }

  // 4. Guardar un nuevo libro
  static Future<bool> guardarLibro(Libro libro) async {
    final response = await http.post(
      Uri.parse('$baseUrl/libros'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(
        libro.toJson(),
      ), // Debes tener el método toJson en tu modelo
    );
    return response.statusCode == 200;
  }

  static Future<bool> eliminarLibro(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/libros/$id'));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<bool> registrarUsuario(
    String username,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/registro'),
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    return response.statusCode == 200;
  }

  static Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      body: jsonEncode({'username': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );
    print("Respuesta del servidor: ${response.statusCode}");
    print("Cuerpo de respuesta: ${response.body}");

    return response.statusCode == 200;
  }

  /// Devuelve la lista de números de volumen ya ocupados para una saga.
  static Future<List<double>> fetchVolumenesOcupados(String saga) async {
    try {
      final response = await http.get(
        // Uri.encodeComponent convierte espacios y caracteres especiales
        // del nombre de la saga para que la URL sea válida
        // Ej: "El Señor de los Anillos" → "El%20Se%C3%B1or%20de%20los%20Anillos"
        Uri.parse(
          '$baseUrl/libros/volumenes?saga=${Uri.encodeComponent(saga)}',
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        // Convertimos cada elemento a double de forma segura
        return body.map((v) => (v as num).toDouble()).toList();
      }
      return [];
    } catch (_) {
      // Si falla la petición, devolvemos lista vacía para no bloquear la UI
      return [];
    }
  }

  /// Busca información de un libro por ISBN delegando en el backend.
  /// Devuelve un [Libro] pre-rellenado o null si no se encuentra (404).
  /// Lanza [Exception] si hay error de servidor o red.
  static Future<Libro?> buscarLibroPorISBN(String isbn) async {
    final response = await http.get(Uri.parse('$baseUrl/libros/isbn/$isbn'));

    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw Exception('Error del servidor: ${response.statusCode}');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    return Libro(
      titulo: data['titulo'] as String,
      autorNombre: data['autor'] as String? ?? '',
      sagaNombre: data['saga'] as String?,
      numLibroSaga: (data['numLibroSaga'] as num?)?.toDouble(),
      estado: EstadoLibro.pendiente,
      puntuacion: 0.0,
      rutaImagen: data['portada'] as String? ?? 'assets/images/fondos/libro.png',
      almacen: AlmacenPropiedades(propiedades: []),
    );
  }
}
