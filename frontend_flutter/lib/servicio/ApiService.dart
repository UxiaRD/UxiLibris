import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/modelo/saga.dart';
import 'package:frontend_flutter/servicio/SessionManager.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_flutter/modelo/almacenPropiedades.dart';

class ApiService {
  static const _timeout = Duration(seconds: 90);

  // URL del backend inyectada en tiempo de compilación con --dart-define.
  // Si no se pasa, se usa la lógica de detección automática de entorno.
  //
  // Ejemplos de uso:
  //   flutter run  --dart-define=BACKEND_URL=https://mi-app.onrender.com
  //   flutter build web --release --dart-define=BACKEND_URL=https://mi-app.onrender.com
  static const String _backendUrl =
      String.fromEnvironment('BACKEND_URL', defaultValue: '');

  // Cuando no hay BACKEND_URL definida, se detecta el entorno:
  //  · Web (kIsWeb = true)        → localhost (Docker local)
  //  · Dispositivo físico Android → 192.168.1.200 (cambiar por tu IP local)
  //  · Emulador Android           → descomentar 10.0.2.2
  static String get baseUrl {
    if (_backendUrl.isNotEmpty) return '$_backendUrl/api';
    if (kIsWeb) return 'http://localhost:8080/api';
    return 'http://192.168.1.200:8080/api';
    // return 'http://10.0.2.2:8080/api'; // emulador Android
  }

  // ── Libros ──────────────────────────────────────────────────────────────────

  // 1. Obtención de los libros del usuario autenticado
  static Future<List<Libro>> fetchLibros() async {
    try {
      final usuarioId = SessionManager.usuarioId;
      if (usuarioId == null) return [];
      final response = await http
          .get(Uri.parse('$baseUrl/libros?usuarioId=$usuarioId'))
          .timeout(_timeout);
      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((dynamic item) => Libro.fromJson(item)).toList();
      } else {
        throw Exception("Error del servidor: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }

  // 2. Obtener autores para el Autocomplete
  static Future<List<String>> fetchAutores() async {
    final response = await http.get(Uri.parse("$baseUrl/libros/autores"));
    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body));
    }
    return [];
  }

  // 3. Obtener sagas para el Autocomplete
  static Future<List<String>> fetchSagas() async {
    final response = await http.get(Uri.parse("$baseUrl/libros/sagas"));
    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body));
    }
    return [];
  }

  // 4. Obtener sugerencia de volumen
  static Future<double> fetchSugerenciaVolumen(String saga) async {
    final response = await http.get(
      Uri.parse("$baseUrl/libros/sugerir-volumen?saga=$saga"),
    );
    if (response.statusCode == 200) {
      return double.parse(response.body);
    }
    return 1.0;
  }

  /// Lanza [Exception] con mensaje legible según el código HTTP de error.
  static Exception _errorISBN(int statusCode) {
    switch (statusCode) {
      case 429:
        return Exception(
          'Cuota de Google Books agotada por hoy. '
          'Espera unas horas o configura una API key propia en el backend.',
        );
      case 503:
        return Exception('Google Books no está disponible. Inténtalo más tarde.');
      default:
        return Exception('Error del servidor ($statusCode) al buscar el ISBN.');
    }
  }

  /// Busca libros por texto libre en Google Books vía el backend.
  /// Lanza [Exception] con mensaje legible si hay error de cuota o red.
  static Future<List<Libro>> buscarLibrosPorTexto(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/libros/buscar?q=${Uri.encodeComponent(query)}'),
    );
    if (response.statusCode == 429) {
      throw Exception(
        'Cuota de Google Books agotada por hoy. '
        'Espera unas horas o configura una API key propia en el backend.',
      );
    }
    if (response.statusCode == 503) {
      throw Exception('Google Books no está disponible. Inténtalo más tarde.');
    }
    if (response.statusCode != 200) {
      throw Exception('Error del servidor (${response.statusCode}) al buscar.');
    }

    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => Libro(
      titulo: item['titulo'] as String,
      autorNombre: item['autor'] as String? ?? '',
      sagaNombre: item['saga'] as String?,
      numLibroSaga: (item['numLibroSaga'] as num?)?.toDouble(),
      estado: EstadoLibro.pendiente,
      puntuacion: 0.0,
      rutaImagen: item['portada'] as String? ?? 'assets/images/fondos/libro.png',
      almacen: AlmacenPropiedades(propiedades: []),
    )).toList();
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

  // 5. Guardar un libro (crea o edita).
  // Devuelve el Libro con el id asignado por el servidor, o null si falla.
  static Future<Libro?> guardarLibro(Libro libro) async {
    final headers = {"Content-Type": "application/json"};
    final body = json.encode(libro.toJson());
    final http.Response response;

    if (libro.id != null) {
      // Edición: PUT /libros/{id}
      response = await http.put(
        Uri.parse('$baseUrl/libros/${libro.id}'),
        headers: headers,
        body: body,
      );
    } else {
      // Creación: POST /libros
      response = await http.post(
        Uri.parse('$baseUrl/libros'),
        headers: headers,
        body: body,
      );
    }

    if (response.statusCode == 200) {
      return Libro.fromJson(json.decode(response.body));
    }
    return null;
  }

  // 6. Marcar / desmarcar un libro como favorito (optimistic-friendly)
  static Future<bool> toggleFavorito(int id, bool valor) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/libros/$id/favorito?valor=$valor'),
    );
    return response.statusCode == 200;
  }

  // 7. Actualizar imagen de fondo de la pantalla de detalle
  static Future<bool> actualizarFondoLibro(int id, String? rutaFondo) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/libros/$id/fondo'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'rutaFondo': rutaFondo}),
    );
    return response.statusCode == 200;
  }

  // 8. Eliminar un libro
  static Future<bool> eliminarLibro(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/libros/$id'));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  // ── Usuarios ──────────────────────────────────────────────────────────────────

  // Registro de un usuario
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

  // Login: devuelve true si OK y guarda la sesión; false si las credenciales son incorrectas
  static Future<bool> login(String username, String password) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/auth/login'),
          body: jsonEncode({'username': username, 'password': password}),
          headers: {'Content-Type': 'application/json'},
        )
        .timeout(_timeout);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      SessionManager.iniciar(
        data['userId'] as int,
        data['username'] as String,
        data['email'] as String? ?? '',
      );
      await SessionManager.guardar();
      return true;
    }
    return false;
  }

  // Actualizar datos del usuario (username, email, contraseña)
  // Lanza FormatException con mensaje si la contraseña es incorrecta o hay conflicto.
  static Future<void> actualizarUsuario({
    required int usuarioId,
    required String nuevoUsername,
    required String nuevoEmail,
    required String passwordActual,
    String? nuevaPassword,
  }) async {
    final body = <String, dynamic>{
      'nuevoUsername': nuevoUsername,
      'nuevoEmail': nuevoEmail,
      'passwordActual': passwordActual,
    };
    if (nuevaPassword != null && nuevaPassword.isNotEmpty) {
      body['nuevaPassword'] = nuevaPassword;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/auth/usuario/$usuarioId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      SessionManager.iniciar(
        data['userId'] as int,
        data['username'] as String,
        data['email'] as String? ?? '',
      );
      await SessionManager.guardar();
      return;
    }
    if (response.statusCode == 401) {
      throw const FormatException('Contraseña actual incorrecta');
    }
    if (response.statusCode == 409) {
      throw FormatException(response.body);
    }
    throw const FormatException('Error al actualizar los datos');
  }

  // ── Sagas ──────────────────────────────────────────────────────────────────

  // 1. Obtención de las Sagas de BD
  static Future<List<Saga>> fetchSagasCompletas() async {
    final response = await http.get(Uri.parse('$baseUrl/sagas'));
    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((e) => Saga.fromJson(e)).toList();
    }
    return [];
  }

  // 2. Guardar Saga
  static Future<Saga?> guardarSaga(Saga saga) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sagas'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(saga.toJson()),
    );
    if (response.statusCode == 200) {
      return Saga.fromJson(json.decode(response.body));
    }
    return null;
  }

  // 3. Abandonar / retomar saga
  static Future<bool> toggleAbandonadaSaga(int id, bool valor) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/sagas/$id/abandonada?valor=$valor'),
    );
    return response.statusCode == 200;
  }

  // 4. Eliminar Saga
  static Future<bool> eliminarSaga(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/sagas/$id'));
    return response.statusCode == 204;
  }

  // 4. Asignación de una Saga a un Libro
  static Future<bool> asignarSagaALibro(
    int libroId,
    String saga,
    double? numLibroSaga,
  ) async {
    final params = StringBuffer('saga=${Uri.encodeComponent(saga)}');
    if (numLibroSaga != null) params.write('&numLibroSaga=$numLibroSaga');
    final response = await http.patch(
      Uri.parse('$baseUrl/libros/$libroId/saga?$params'),
    );
    return response.statusCode == 200;
  }

  // ── Escaner ──────────────────────────────────────────────────────────────────

  /// Busca información de un libro por ISBN delegando en el backend.
  /// Devuelve un [Libro] pre-rellenado o null si no se encuentra (404).
  /// Lanza [Exception] si hay error de servidor o red.
  static Future<Libro?> buscarLibroPorISBN(String isbn) async {
    final response = await http.get(Uri.parse('$baseUrl/libros/isbn/$isbn'));

    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) throw _errorISBN(response.statusCode);

    final Map<String, dynamic> data = json.decode(response.body);
    return Libro(
      titulo: data['titulo'] as String,
      autorNombre: data['autor'] as String? ?? '',
      sagaNombre: data['saga'] as String?,
      numLibroSaga: (data['numLibroSaga'] as num?)?.toDouble(),
      estado: EstadoLibro.pendiente,
      puntuacion: 0.0,
      rutaImagen:
          data['portada'] as String? ?? 'assets/images/fondos/libro.png',
      almacen: AlmacenPropiedades(propiedades: []),
    );
  }
}
