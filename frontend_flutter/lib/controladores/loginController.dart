import 'package:flutter/material.dart';
import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/pantallas/menuPrincipal.dart';
import 'package:frontend_flutter/servicio/ApiService.dart';

/// Controlador estático que gestiona el flujo de inicio de sesión.
class LoginController {
  /// Valida que los campos no estén vacíos, llama al backend y navega
  /// a [MenuPrincipal] si las credenciales son correctas.
  /// Muestra un SnackBar con el error correspondiente en caso de fallo.
  static Future<void> iniciarSesion({
    required BuildContext context,
    required String username,
    required String password,
    required Function(bool) setCargando,
  }) async {
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa todos los campos")),
      );
      return;
    }

    setCargando(true);

    try {
      bool exito = await ApiService.login(username.trim(), password.trim());
      setCargando(false);

      if (exito && context.mounted) {
        Libreria.todosLosLibros = [];
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MenuPrincipal()),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Credenciales incorrectas")),
        );
      }
    } catch (e) {
      setCargando(false);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error de conexión: $e")));
      }
    }
  }
}
