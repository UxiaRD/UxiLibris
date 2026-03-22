import 'package:flutter/material.dart';
import 'package:frontend_flutter/modelo/propiedad.dart';

class DialogosConfiguracion {
  /// Muestra un diálogo para crear una nueva propiedad dinámica.
  /// Devuelve la [Propiedad] creada o null si se cancela.
  static Future<Propiedad?> mostrarDialogoNuevaPropiedad(
    BuildContext context,
  ) async {
    final TextEditingController nombreController = TextEditingController();

    return showDialog<Propiedad>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Nueva Propiedad"),
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
                // Retornamos la nueva propiedad con tipo texto por defecto
                Navigator.pop(
                  context,
                  Propiedad(
                    nombre: nombreController.text,
                    tipo: TipoDato.texto,
                    valor: "",
                  ),
                );
              }
            },
            child: const Text("AÑADIR"),
          ),
        ],
      ),
    );
  }
}
