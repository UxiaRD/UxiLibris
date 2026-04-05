import 'package:flutter/material.dart';
import 'package:frontend_flutter/pantallas/coleccionSagas.dart';

enum PantallaDrawer { libros, sagas, estadisticas, deseos }

class DrawerPrincipal extends StatelessWidget {
  final PantallaDrawer pantallaActual;

  const DrawerPrincipal({super.key, required this.pantallaActual});

  void _navegar(BuildContext context, PantallaDrawer destino) {
    Navigator.pop(context); // cierra el drawer
    if (destino == pantallaActual) return;

    switch (destino) {
      case PantallaDrawer.libros:
        Navigator.pop(context); // vuelve a la colección de libros
      case PantallaDrawer.sagas:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PantallaColeccionSagas()),
        );
      case PantallaDrawer.estadisticas:
        // TODO: navegar a PantallaEstadisticas
        break;
      case PantallaDrawer.deseos:
        // TODO: navegar a PantallaDeseos
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(color: colorScheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Icon(
                    Icons.menu_book,
                    size: 30,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text("Mi Biblioteca", style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.library_books),
            title: const Text('Colección de libros'),
            selected: pantallaActual == PantallaDrawer.libros,
            onTap: () => _navegar(context, PantallaDrawer.libros),
          ),
          ListTile(
            leading: const Icon(Icons.shelves),
            title: const Text('Sagas'),
            selected: pantallaActual == PantallaDrawer.sagas,
            onTap: () => _navegar(context, PantallaDrawer.sagas),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart_rounded),
            title: const Text('Estadísticas'),
            selected: pantallaActual == PantallaDrawer.estadisticas,
            onTap: () => _navegar(context, PantallaDrawer.estadisticas),
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border_rounded),
            title: const Text('Lista de Deseos'),
            selected: pantallaActual == PantallaDrawer.deseos,
            onTap: () => _navegar(context, PantallaDrawer.deseos),
          ),
        ],
      ),
    );
  }
}