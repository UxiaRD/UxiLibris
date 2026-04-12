import 'package:flutter/material.dart';
import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/pantallas/login.dart';
import 'package:frontend_flutter/servicio/SessionManager.dart';


class AjustesController {
  /// Muestra diálogo de confirmación y cierra la sesión si el usuario acepta.
  static Future<void> cerrarSesion(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmar != true || !context.mounted) return;

    Libreria.todosLosLibros = [];
    await SessionManager.cerrar();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const PantallaLogin()),
      (route) => false,
    );
  }

  /// Limpia la caché local y fuerza una recarga desde el servidor.
  static void recargarBiblioteca(BuildContext context) {
    Libreria.todosLosLibros = [];
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Biblioteca recargada desde el servidor')),
    );
  }
}