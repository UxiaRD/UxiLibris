import 'package:flutter/material.dart';
import '../pantallas/ajustes.dart';

class ActionsAppBar {
  static List<Widget> obtenerAcciones(
    BuildContext context, {
    VoidCallback?
    alEliminar, // Si se pasa una función, aparece el botón eliminar
  }) {
    return [
      // BOTÓN ELIMINAR (Solo si se pasa la función alEliminar)
      if (alEliminar != null)
        IconButton(
          icon: const Icon(Icons.delete_forever, color: Colors.red),
          onPressed: alEliminar,
        ),

      // BOTÓN AJUSTES
      IconButton(
        icon: const Icon(Icons.settings),
        tooltip: "Ajustes",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PantallaAjustes()),
          );
        },
      ),

      const SizedBox(width: 8),
    ];
  }
}
