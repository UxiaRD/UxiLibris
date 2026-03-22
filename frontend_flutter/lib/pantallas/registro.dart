import 'package:flutter/material.dart';
import 'package:frontend_flutter/controladores/registroController.dart';
import 'package:frontend_flutter/utilidades/actionsAppBar.dart';
import 'package:frontend_flutter/decoraciones/fondoBase.dart';

// WIDGET que gestiona el Registro de la app

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  bool _ocultarContrasena = true;
  bool _ocultarConfContrasena = true;

  // CONTROLADORES
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
      extendBodyBehindAppBar:
          true, // Extensión del body por detrás de al appBar

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

              // CAMPO: NOMBRE DE USUARIO
              TextFormField(
                controller: _userController,
                decoration: InputDecoration(
                  labelText: "Nombre de usuario",
                  prefixIcon: Icon(Icons.person, color: colores.primary),
                ),
              ),

              const SizedBox(height: 20),

              // CAMPO: EMAIL
              TextFormField(
                controller: _emailController,
                // El atributo keyboardType es para que en el teclado aparezca la @ automáticamente
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Correo electrónico",
                  prefixIcon: Icon(Icons.email, color: colores.primary),
                ),
              ),

              const SizedBox(height: 20),

              // CAMPO: CONTRASEÑA
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

              // CAMPO: CONFIRMACIÓN CONTRASEÑA
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

              // BOTÓN DE REGISTRO
              ElevatedButton(
                onPressed: _cargando
                    ? null // Si está cargando, el botón se deshabilita
                    : () async {
                        // Llamamos directamente al controlador
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
                  backgroundColor:
                      colores.primary, // Usando tus variables de color
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
