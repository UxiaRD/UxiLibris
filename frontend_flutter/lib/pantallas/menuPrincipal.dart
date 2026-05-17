import 'package:flutter/material.dart';
import 'package:frontend_flutter/pantallas/uxiLibrisApp.dart';
import 'package:frontend_flutter/utilidades/actionsAppBar.dart';
import 'package:frontend_flutter/pantallas/coleccionLibros.dart';
import 'package:frontend_flutter/utilidades/drawerPrincipal.dart';

/// Pantalla raíz de la aplicación (después del login).
/// Gestiona las cuatro pestañas de la colección (Todos, Leyendo, Pendientes, Leídos)
/// y aloja el [DrawerPrincipal] para navegar al resto de secciones.
class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({super.key});

  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> with RouteAware {
  int _indiceActual = 0;

  final List<Widget> _paginas = [
    const PantallaColeccion(filtro: "todos"),
    const PantallaColeccion(filtro: "leyendo"),
    const PantallaColeccion(filtro: "pendiente"),
    const PantallaColeccion(filtro: "leido"),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) routeObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Se llama cuando una nueva ruta se pone encima de esta
  @override
  void didPushNext() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colores = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: Text("UxiLibris"),
        centerTitle: true,
        actions: ActionsAppBar.obtenerAcciones(context),
      ),

      drawer: DrawerPrincipal(pantallaActual: PantallaDrawer.libros),

      body: _paginas[_indiceActual],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        onTap: (index) {
          FocusManager.instance.primaryFocus?.unfocus();
          setState(() => _indiceActual = index);
        },
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