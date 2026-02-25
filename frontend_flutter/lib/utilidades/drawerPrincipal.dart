import 'package:flutter/material.dart';

class DrawerPrincipal extends StatelessWidget {
  const DrawerPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          // Encabezado del Menú
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30, // Ajusta el tamaño del círculo
                  child: Icon(
                    Icons.menu_book,
                    size: 30,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                // Es necesario especificar el color blanco ya que es el mismo en ambos modos
                Text("Mi Biblioteca", style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          // Opción: Estadísticas
          ListTile(
            leading: const Icon(Icons.bar_chart_rounded),
            title: const Text("Estadísticas"),
            onTap: () {
              Navigator.pop(context); // Cerramos el menú
              // Navegación a la pantalla de estadísticas
            },
          ),

          // Opción: Lista de Deseos
          ListTile(
            leading: const Icon(Icons.favorite_border_rounded),
            title: const Text("Lista de Deseos"),
            onTap: () {
              Navigator.pop(context);
              // Navegación a la pantalla de deseos
            },
          ),
        ],
      ),
    );
  }
}
