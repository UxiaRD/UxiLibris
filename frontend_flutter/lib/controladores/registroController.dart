import 'package:flutter/material.dart';
import 'package:frontend_flutter/servicio/ApiService.dart';

/// Controlador estático que gestiona el flujo de registro de nuevos usuarios.
class RegistroController {
  /// Valida los campos del formulario, llama al backend y navega de vuelta al login si hay éxito.
  static Future<void> registrarUsuario({
    required BuildContext context,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required Function(bool) setCargando,
  }) async {
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _mostrarError(context, "Todos los campos son obligatorios");
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _mostrarError(context, "El formato del email no es válido");
      return;
    }

    final tieneMayuscula = password.contains(RegExp(r'[A-Z]'));
    if (password.length < 8 || !tieneMayuscula) {
      _mostrarError(
        context,
        "La contraseña debe tener 8 caracteres y una mayúscula",
      );
      return;
    }

    if (password != confirmPassword) {
      _mostrarError(context, "Las contraseñas no coinciden");
      return;
    }

    setCargando(true);

    try {
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
