import 'package:flutter/material.dart';
import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/pantallas/menuPrincipal.dart';
import 'package:frontend_flutter/servicio/ApiService.dart';

class LoginController {
  // Lógica de inicio de sesión movida fuera de la vista
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
      // Conexión con el backend de Java
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
        ).showSnackBar(const SnackBar(content: Text("Error de conexión:")));
        print("Error durante el login: $e");
      }
    }
  }
}
