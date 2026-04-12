import 'package:flutter/material.dart';
import 'package:frontend_flutter/decoraciones/themeProvider.dart';
import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/pantallas/login.dart';
import 'package:frontend_flutter/servicio/ApiService.dart';
import 'package:frontend_flutter/servicio/SessionManager.dart';
import 'package:provider/provider.dart';

class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({super.key});

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  // ── Cerrar sesión ─────────────────────────────────────────────────────────

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    await SessionManager.cerrar();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const PantallaLogin()),
      (route) => false,
    );
  }

  // ── Recargar biblioteca ───────────────────────────────────────────────��───

  Future<void> _recargarBiblioteca() async {
    Libreria.todosLosLibros = [];
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Biblioteca recargada desde el servidor')),
    );
  }

  // ── Editar cuenta ─────────────────────────────────────────────────────────

  Future<void> _abrirEditorCuenta() async {
    await showDialog(
      context: context,
      builder: (ctx) => _DialogoEditarCuenta(onGuardado: () => setState(() {})),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final esOscuro = themeProvider.themeMode == ThemeMode.dark;
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          // ── CUENTA ────────────────────────────────────────────────────────
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
                  leading: Icon(Icons.edit_outlined, color: colores.primary),
                  title: const Text('Editar datos de cuenta'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _abrirEditorCuenta,
                ),
              ],
            ),
          ),

          // ── APARIENCIA ────────────────────────────────────────────────────
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

          // ── DATOS ─────────────────────────────────────────────────────────
          _SeccionHeader(titulo: 'Datos'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: Icon(Icons.sync, color: colores.primary),
              title: const Text('Recargar biblioteca'),
              subtitle: const Text('Fuerza una sincronización con el servidor'),
              onTap: _recargarBiblioteca,
            ),
          ),

          // ── SESIÓN ────────────────────────────────────────────────────────
          _SeccionHeader(titulo: 'Sesión'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: _cerrarSesion,
            ),
          ),

          // ── ACERCA DE ─────────────────────────────────────────────────────
          _SeccionHeader(titulo: 'Acerca de'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.auto_stories, color: colores.primary),
                  title: const Text('UxiLibris'),
                  subtitle: const Text('Versión 1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.person_outline, color: colores.primary),
                  title: const Text('Desarrollado por'),
                  subtitle: const Text('Uxia R.D.'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Widget auxiliar: cabecera de sección ──────────────────────────────────────

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

// ── Diálogo: editar datos de cuenta ──────────────────────────────────────────

class _DialogoEditarCuenta extends StatefulWidget {
  final VoidCallback onGuardado;
  const _DialogoEditarCuenta({required this.onGuardado});

  @override
  State<_DialogoEditarCuenta> createState() => _DialogoEditarCuentaState();
}

class _DialogoEditarCuentaState extends State<_DialogoEditarCuenta> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _usernameCtrl;
  late final TextEditingController _emailCtrl;
  final TextEditingController _nuevaPassCtrl = TextEditingController();
  final TextEditingController _confirmarPassCtrl = TextEditingController();
  final TextEditingController _passActualCtrl = TextEditingController();

  bool _verNuevaPass = false;
  bool _verConfirmar = false;
  bool _verActual = false;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController(text: SessionManager.username ?? '');
    _emailCtrl = TextEditingController(text: SessionManager.email ?? '');
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _nuevaPassCtrl.dispose();
    _confirmarPassCtrl.dispose();
    _passActualCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    try {
      await ApiService.actualizarUsuario(
        usuarioId: SessionManager.usuarioId!,
        nuevoUsername: _usernameCtrl.text.trim(),
        nuevoEmail: _emailCtrl.text.trim(),
        passwordActual: _passActualCtrl.text,
        nuevaPassword: _nuevaPassCtrl.text.isEmpty ? null : _nuevaPassCtrl.text,
      );

      if (!mounted) return;
      Navigator.pop(context);
      widget.onGuardado();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos actualizados correctamente')),
      );
    } on FormatException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de conexión'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Editar cuenta'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Username
              TextFormField(
                controller: _usernameCtrl,
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  prefixIcon: Icon(Icons.person, color: colores.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'El usuario es obligatorio'
                    : null,
              ),
              const SizedBox(height: 14),

              // Email
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: colores.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'El correo es obligatorio'
                    : null,
              ),
              const SizedBox(height: 20),

              // Sección nueva contraseña (opcional)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Nueva contraseña (opcional)',
                  style: TextStyle(
                    fontSize: 12,
                    color: colores.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nuevaPassCtrl,
                obscureText: !_verNuevaPass,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                  prefixIcon: Icon(Icons.lock_outline, color: colores.primary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _verNuevaPass ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _verNuevaPass = !_verNuevaPass),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (v) {
                  if (v != null && v.isNotEmpty && v.length < 6) {
                    return 'Mínimo 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirmarPassCtrl,
                obscureText: !_verConfirmar,
                decoration: InputDecoration(
                  labelText: 'Confirmar nueva contraseña',
                  prefixIcon: Icon(Icons.lock_outline, color: colores.primary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _verConfirmar ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _verConfirmar = !_verConfirmar),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (v) {
                  if (_nuevaPassCtrl.text.isNotEmpty &&
                      v != _nuevaPassCtrl.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 8),

              // Contraseña actual (siempre requerida)
              TextFormField(
                controller: _passActualCtrl,
                obscureText: !_verActual,
                decoration: InputDecoration(
                  labelText: 'Contraseña actual',
                  helperText: 'Necesaria para confirmar los cambios',
                  prefixIcon: Icon(Icons.key, color: colores.primary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _verActual ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _verActual = !_verActual),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Introduce tu contraseña actual'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: _guardando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
