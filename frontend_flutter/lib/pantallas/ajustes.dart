import 'package:flutter/material.dart';
import 'package:frontend_flutter/controladores/ajustesController.dart';
import 'package:frontend_flutter/decoraciones/fondoBase.dart';
import 'package:frontend_flutter/decoraciones/themeProvider.dart';
import 'package:frontend_flutter/servicio/SessionManager.dart';
import 'package:frontend_flutter/utilidades/dialogoEditarCuenta.dart';
import 'package:provider/provider.dart';

class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({super.key});

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  Future<void> _abrirEditorCuenta() async {
    await showDialog(
      context: context,
      builder: (ctx) =>
          DialogoEditarCuenta(onGuardado: () => setState(() {})),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final esOscuro = themeProvider.themeMode == ThemeMode.dark;
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Ajustes'),
        backgroundColor: Colors.transparent,
      ),
      body: FondoBase(
        rutaImagen: 'assets/images/fondos/fondoAjustes.png',
        child: ListView(
          children: [
            // ── CUENTA ──────────────────────────────────────────────────────
            _SeccionHeader(titulo: 'Cuenta'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colores.primary,
                      child: Text(
                        (SessionManager.username ?? '?')[0].toUpperCase(),
                        style: TextStyle(
                          color: colores.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      SessionManager.username ?? '—',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(SessionManager.email ?? '—'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading:
                        Icon(Icons.edit_outlined, color: colores.primary),
                    title: const Text('Editar datos de cuenta'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _abrirEditorCuenta,
                  ),
                ],
              ),
            ),

            // ── APARIENCIA ──────────────────────────────────────────────────
            _SeccionHeader(titulo: 'Apariencia'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SwitchListTile(
                secondary: Icon(
                  esOscuro ? Icons.dark_mode : Icons.light_mode,
                  color: colores.primary,
                ),
                title: const Text('Modo oscuro'),
                value: esOscuro,
                onChanged: themeProvider.toggleTheme,
              ),
            ),

            // ── DATOS ───────────────────────────────────────────────────────
            _SeccionHeader(titulo: 'Datos'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: Icon(Icons.sync, color: colores.primary),
                title: const Text('Recargar biblioteca'),
                subtitle: const Text(
                  'Fuerza una sincronización con el servidor',
                ),
                onTap: () =>
                    AjustesController.recargarBiblioteca(context),
              ),
            ),

            // ── SESIÓN ──────────────────────────────────────────────────────
            _SeccionHeader(titulo: 'Sesión'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => AjustesController.cerrarSesion(context),
              ),
            ),

            // ── ACERCA DE ───────────────────────────────────────────────────
            _SeccionHeader(titulo: 'Acerca de'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  ListTile(
                    leading:
                        Icon(Icons.auto_stories, color: colores.primary),
                    title: const Text('UxiLibris'),
                    subtitle: const Text('Versión 1.0.0'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading:
                        Icon(Icons.person_outline, color: colores.primary),
                    title: const Text('Desarrollado por'),
                    subtitle: const Text('Uxia R.D.'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Widget auxiliar: cabecera de sección ─────────────────────────────────────

class _SeccionHeader extends StatelessWidget {
  final String titulo;
  const _SeccionHeader({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 6),
      child: Text(
        titulo.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}