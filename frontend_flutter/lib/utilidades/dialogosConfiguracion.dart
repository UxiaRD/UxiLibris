import 'package:flutter/material.dart';
import 'package:frontend_flutter/modelo/propiedad.dart';

class DialogosConfiguracion {
  /// Muestra un diálogo para crear o editar una propiedad dinámica.
  /// Si se pasa [propiedadExistente], el diálogo se abre en modo edición
  /// con el nombre prerellenado y conserva el valor al guardar.
  /// Devuelve la [Propiedad] resultante o null si se cancela.
  static Future<Propiedad?> mostrarDialogoPropiedad(
    BuildContext context, {
    Propiedad? propiedadExistente,
  }) async {
    final bool esEdicion = propiedadExistente != null;
    final TextEditingController nombreController = TextEditingController(
      text: propiedadExistente?.nombre ?? '',
    );

    return showDialog<Propiedad>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(esEdicion ? "Editar campo" : "Nueva Propiedad"),
        content: TextField(
          controller: nombreController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "Nombre del campo",
            hintText: "Ej: Traductor, Editorial, Formato...",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nombreController.text.isNotEmpty) {
                Navigator.pop(
                  context,
                  esEdicion
                      ? propiedadExistente.copyWith(nombre: nombreController.text)
                      : Propiedad(
                          nombre: nombreController.text,
                          tipo: TipoDato.texto,
                          valor: "",
                        ),
                );
              }
            },
            child: Text(esEdicion ? "GUARDAR" : "AÑADIR"),
          ),
        ],
      ),
    );
  }
}
