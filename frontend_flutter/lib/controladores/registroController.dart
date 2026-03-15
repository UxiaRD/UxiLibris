import 'package:flutter/material.dart';
import 'package:frontend_flutter/servicio/ApiService.dart';

class RegistroController {
  static Future<void> registrarUsuario({
    required BuildContext context,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required Function(bool) setCargando,
  }) async {
    // 1. Validaciones de formato
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _mostrarError(context, "Todos los campos son obligatorios");
      return;
    }

    // Validación de Email (debe contener @ y .)
    if (!email.contains('@') || !email.contains('.')) {
      _mostrarError(context, "El formato del email no es válido");
      return;
    }

    // Validación de Contraseña (mínimo 8 caracteres y una mayúscula)
    bool tieneMayuscula = password.contains(RegExp(r'[A-Z]'));
    if (password.length < 8 || !tieneMayuscula) {
      _mostrarError(
        context,
        "La contraseña debe tener 8 caracteres y una mayúscula",
      );
      return;
    }

    // Validación de coincidencia
    if (password != confirmPassword) {
      _mostrarError(context, "Las contraseñas no coinciden");
      return;
    }

    setCargando(true);

    try {
      // Llamada al backend (Spring Boot comprobará si el usuario existe en MySQL)
      bool exito = await ApiService.registrarUsuario(
        username.trim(),
        email.trim(),
        password.trim(),
      );

      setCargando(false);

      if (exito && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Registro exitoso! Redirigiendo..."),
            backgroundColor: Colors.green,
          ),
        );
        // Esperamos un segundo para que vea el mensaje y volvemos al login
        await Future.delayed(const Duration(seconds: 1));
        if (context.mounted) Navigator.of(context).pop();
      } else if (context.mounted) {
        _mostrarError(context, "El usuario o email ya existen en UxiLibris");
      }
    } catch (e) {
      setCargando(false);
      if (context.mounted) {
        _mostrarError(context, "Error de conexión con el servidor");
      }
    }
  }

  static void _mostrarError(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }
}
