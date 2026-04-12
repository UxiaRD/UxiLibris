import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Almacena datos de la sesión activa del usuario en memoria.
/// Se inicializa en el login y se limpia al cerrar sesión.
/// Usa FlutterSecureStorage para persistir la sesión entre aperturas de la app.
class SessionManager {
  static int? usuarioId;
  static String? username;
  static String? email;

  static const _storage = FlutterSecureStorage();
  static const _claveUserId = 'usuario_id';
  static const _claveUsername = 'username';
  static const _claveEmail = 'email';

  /// Inicializa la sesión en memoria.
  static void iniciar(int id, String nombre, String correo) {
    usuarioId = id;
    username = nombre;
    email = correo;
  }

  /// Guarda la sesión en el llavero del dispositivo.
  static Future<void> guardar() async {
    await _storage.write(key: _claveUserId, value: usuarioId.toString());
    await _storage.write(key: _claveUsername, value: username);
    await _storage.write(key: _claveEmail, value: email);
  }

  /// Intenta restaurar la sesión desde el llavero.
  /// Devuelve true si había una sesión guardada, false si no.
  static Future<bool> restaurar() async {
    final idStr = await _storage.read(key: _claveUserId);
    final nombre = await _storage.read(key: _claveUsername);
    final correo = await _storage.read(key: _claveEmail);
    if (idStr == null || nombre == null) return false;
    final id = int.tryParse(idStr);
    if (id == null) return false;
    iniciar(id, nombre, correo ?? '');
    return true;
  }

  /// Cierra la sesión: limpia memoria y borra los datos guardados.
  static Future<void> cerrar() async {
    usuarioId = null;
    username = null;
    email = null;
    await _storage.deleteAll();
  }
}