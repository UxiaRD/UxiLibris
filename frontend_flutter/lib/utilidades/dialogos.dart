import 'package:flutter/material.dart';

class DialogosApp {
  /// Muestra un cuadro de diálogo para confirmar una eliminación.
  static void confirmarEliminacion({
    required BuildContext context,
    required String titulo,
    required String contenido,
    required VoidCallback alConfirmar,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(titulo),
        content: Text(contenido),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              alConfirmar();
            },
            child: const Text("ELIMINAR"),
          ),
        ],
      ),
    );
  }
}
