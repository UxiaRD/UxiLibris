import 'package:flutter/material.dart';
import 'package:frontend_flutter/servicio/ApiService.dart';
import 'package:frontend_flutter/servicio/SessionManager.dart';

class DialogoEditarCuenta extends StatefulWidget {
  final VoidCallback onGuardado;
  const DialogoEditarCuenta({super.key, required this.onGuardado});

  @override
  State<DialogoEditarCuenta> createState() => _DialogoEditarCuentaState();
}

class _DialogoEditarCuentaState extends State<DialogoEditarCuenta> {
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
        nuevaPassword:
            _nuevaPassCtrl.text.isEmpty ? null : _nuevaPassCtrl.text,
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
    } catch (_) {
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
              // Usuario
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

              // Nueva contraseña (opcional)
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
                  prefixIcon:
                      Icon(Icons.lock_outline, color: colores.primary),
                  suffixIcon: IconButton(
                    icon: Icon(_verNuevaPass
                        ? Icons.visibility_off
                        : Icons.visibility),
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
                  prefixIcon:
                      Icon(Icons.lock_outline, color: colores.primary),
                  suffixIcon: IconButton(
                    icon: Icon(_verConfirmar
                        ? Icons.visibility_off
                        : Icons.visibility),
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
                        _verActual ? Icons.visibility_off : Icons.visibility),
                    onPressed: () =>
                        setState(() => _verActual = !_verActual),
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