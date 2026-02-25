import 'package:flutter/material.dart';
import 'ajustes.dart';
import '../../pantallas/login.dart';

class ActionsAppBar {
  static List<Widget> obtenerAcciones(
    BuildContext context, {
    bool mostrarCerrarSesion = false, // Por defecto no se muestra
    VoidCallback?
    alEliminar, // Si se pasa una función, aparece el botón eliminar
  }) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return [
      // BOTÓN ELIMINAR (Solo si se pasa la función alEliminar)
      if (alEliminar != null)
        IconButton(
          icon: const Icon(Icons.delete_forever, color: Colors.red),
          onPressed: alEliminar,
        ),

      // BOTÓN AJUSTES
      IconButton(
        icon: Icon(Icons.settings),
        tooltip: "Ajustes",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PantallaAjustes()),
          );
        },
      ),

      // BOTÓN ACERCA DE
      IconButton(
        icon: const Icon(Icons.info_outline),
        tooltip: "Acerca de",
        onPressed: () {
          showAboutDialog(
            context: context,
            applicationName: "UxiLibris",
            applicationVersion: "1.0.0",
            applicationIcon: Icon(Icons.auto_stories, color: primaryColor),
          );
        },
      ),

      // BOTÓN CERRAR SESIÓN
      if (mostrarCerrarSesion)
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: "Cerrar Sesión",
          onPressed: () {
            // pushAndRemoveUntil permite regresar al login eliminando todo el historial de navegación
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const PantallaLogin()),
              (route) =>
                  false, // Esta línea hace que el usuario no pueda volver atrás
            );
          },
        ),

      const SizedBox(width: 8),
    ];
  }
}
