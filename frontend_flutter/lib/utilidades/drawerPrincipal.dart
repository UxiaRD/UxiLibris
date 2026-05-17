import 'package:flutter/material.dart';
import 'package:frontend_flutter/pantallas/coleccionSagas.dart';
import 'package:frontend_flutter/pantallas/estadisticas.dart';
import 'package:frontend_flutter/pantallas/listaDeseos.dart';

enum PantallaDrawer { libros, sagas, estadisticas, deseos }

/// Menú lateral de navegación principal de la aplicación.
/// Gestiona las transiciones entre Libros, Sagas, Estadísticas y Lista de Deseos
/// manteniendo siempre una pila de navegación limpia: [MenuPrincipal, <sección>].
class DrawerPrincipal extends StatelessWidget {
  final PantallaDrawer pantallaActual;

  const DrawerPrincipal({super.key, required this.pantallaActual});

  /// Navega a la sección indicada con una pila limpia para evitar acumulación de rutas.
  void _navegar(BuildContext context, PantallaDrawer destino) {
    // Misma sección: solo cerrar el drawer
    if (destino == pantallaActual) {
      Navigator.pop(context);
      return;
    }

    switch (destino) {
      // Libros es la raíz: desapila todo (incluido el drawer) hasta ella
      case PantallaDrawer.libros:
        Navigator.popUntil(context, (route) => route.isFirst);
      // El resto reemplaza la sección actual mantiendo la raíz limpia:
      // [Libros, <sección>] sin importar desde dónde se navegue
      case PantallaDrawer.sagas:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const PantallaColeccionSagas()),
          (route) => route.isFirst,
        );
      case PantallaDrawer.estadisticas:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const PantallaEstadisticas()),
          (route) => route.isFirst,
        );
      case PantallaDrawer.deseos:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const PantallaListaDeseos()),
          (route) => route.isFirst,
        );
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