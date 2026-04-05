/// Almacena datos de la sesión activa del usuario en memoria.
/// Se inicializa en el login y se limpia al cerrar sesión.
class SessionManager {
  static int? usuarioId;
  static String? username;

  static void iniciar(int id, String nombre) {
    usuarioId = id;
    username = nombre;
  }

  static void cerrar() {
    usuarioId = null;
    username = null;
  }
}