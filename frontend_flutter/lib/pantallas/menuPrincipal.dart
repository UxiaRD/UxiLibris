import 'package:flutter/material.dart';
import 'package:frontend_flutter/utilidades/actionsAppBar.dart';
import 'package:frontend_flutter/pantallas/coleccionLibros.dart';
import 'package:frontend_flutter/utilidades/drawerPrincipal.dart';

// WIDGET base para las pestañas de la Colección de Libros

class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({super.key});

  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  int _indiceActual = 0;

  final List<Widget> _paginas = [
    const PantallaColeccion(filtro: "todos"),
    const PantallaColeccion(filtro: "leyendo"),
    const PantallaColeccion(filtro: "pendiente"),
    const PantallaColeccion(filtro: "leido"),
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme colores = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar:
          true, // Extensión del body por detrás de al appBar

      appBar: AppBar(
        title: Text("UxiLibris"),
        centerTitle: true,
        actions: ActionsAppBar.obtenerAcciones(
          context,
          mostrarCerrarSesion: true,
        ),
      ),

      drawer: DrawerPrincipal(),

      // Llamada a la lista con el índice para el BottomNavigationBar
      body: _paginas[_indiceActual],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        onTap: (index) => setState(() => _indiceActual = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colores.primary,
        unselectedItemColor: colores.outline,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.all_inclusive),
            label: 'Todos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.import_contacts),
            label: 'Leyendo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hourglass_empty),
            label: 'Pendientes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Leídos',
          ),
        ],
      ),
    );
  }
}
