import 'package:flutter/material.dart';
import 'package:frontend_flutter/controladores/registroController.dart';
import 'package:frontend_flutter/utilidades/actionsAppBar.dart';
import 'package:frontend_flutter/decoraciones/fondoBase.dart';

/// Formulario de registro de nuevos usuarios con validación de formato de email
/// y requisitos de contraseña (mínimo 8 caracteres y una mayúscula).
class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  bool _ocultarContrasena = true;
  bool _ocultarConfContrasena = true;

  final TextEditingController _userController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _passConfirmController = TextEditingController();

  bool _cargando = false;

  @override
  void dispose() {
    _userController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _passConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colores = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(actions: ActionsAppBar.obtenerAcciones(context)),

      body: FondoBase(
        rutaImagen: 'assets/images/fondos/fondo.png',

        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),

          child: Column(
            children: [
              Icon(Icons.person_add, size: 80, color: colores.primary),
              const SizedBox(height: 10),
              Text(
                "Crear Cuenta",
                style: Theme.of(context).textTheme.displayLarge,
              ),

              const SizedBox(height: 40),

              // ── CAMPO: NOMBRE DE USUARIO ───────────────────────────────
              TextFormField(
                controller: _userController,
                decoration: InputDecoration(
                  labelText: "Nombre de usuario",
                  prefixIcon: Icon(Icons.person, color: colores.primary),
                ),
              ),

              const SizedBox(height: 20),

              // ── CAMPO: EMAIL ───────────────────────────────────────────
              TextFormField(
                controller: _emailController,
                // muestra la @ automáticamente en el teclado móvil
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Correo electrónico",
                  prefixIcon: Icon(Icons.email, color: colores.primary),
                ),
              ),

              const SizedBox(height: 20),

              // ── CAMPO: CONTRASEÑA ──────────────────────────────────────
              TextFormField(
                controller: _passController,
                obscureText: _ocultarContrasena,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  prefixIcon: Icon(Icons.lock, color: colores.primary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _ocultarContrasena
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () => setState(
                      () => _ocultarContrasena = !_ocultarContrasena,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── CAMPO: CONFIRMAR CONTRASEÑA ────────────────────────────
              TextFormField(
                controller: _passConfirmController,
                obscureText: _ocultarConfContrasena,
                decoration: InputDecoration(
                  labelText: "Confirmación de Contraseña",
                  prefixIcon: Icon(Icons.lock, color: colores.primary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _ocultarConfContrasena
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () => setState(
                      () => _ocultarConfContrasena = !_ocultarConfContrasena,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ── BOTÓN DE REGISTRO ──────────────────────────────────────
              ElevatedButton(
                onPressed: _cargando
                    ? null
                    : () async {
                        await RegistroController.registrarUsuario(
                          context: context,
                          username: _userController.text,
                          email: _emailController.text,
                          password: _passController.text,
                          confirmPassword: _passConfirmController.text,
                          setCargando: (valor) {
                            if (mounted) setState(() => _cargando = valor);
                          },
                        );
                      },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: colores.primary,
                  foregroundColor: colores.onPrimary,
                ),
                child: _cargando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Registrarse"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
