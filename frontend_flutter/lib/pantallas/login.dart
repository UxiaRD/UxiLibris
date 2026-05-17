import 'package:flutter/material.dart';
import 'package:frontend_flutter/controladores/loginController.dart';
import 'package:frontend_flutter/servicio/SessionManager.dart';
import 'package:frontend_flutter/utilidades/actionsAppBar.dart';
import 'package:frontend_flutter/decoraciones/fondoBase.dart';
import 'package:frontend_flutter/pantallas/menuPrincipal.dart';
import 'package:frontend_flutter/pantallas/registro.dart';

/// Pantalla de inicio de sesión. Comprueba si hay una sesión guardada en el dispositivo
/// y, si la hay, navega directamente a [MenuPrincipal] sin pedir credenciales.
class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  bool _ocultarContrasena = true;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _verificarSesionGuardada();
  }

  /// Si hay una sesión guardada en el dispositivo, salta directamente al menú.
  Future<void> _verificarSesionGuardada() async {
    final restaurado = await SessionManager.restaurar();
    if (restaurado && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MenuPrincipal()),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passController.dispose();
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
        /* El SingleChildScrollView es necesario cuando se usa TextFromField ya que se despliega el teclado
        y permite que si el contenido queda tapado el usuario pueda hacer scroll */
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            80,
            80,
            80,
            80 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── LOGO Y TÍTULO ──────────────────────────────────────────
              Icon(Icons.library_books, size: 80, color: colores.primary),

              SizedBox(height: 20),

              Text(
                "UxiLibris",
                style: Theme.of(context).textTheme.displayLarge,
              ),

              SizedBox(height: 40),

              // ── CAMPO: NOMBRE DE USUARIO ───────────────────────────────
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Usuario",
                  prefixIcon: Icon(Icons.person, color: colores.primary),
                ),
              ),

              SizedBox(height: 20),

              // ── CAMPO: CONTRASEÑA ──────────────────────────────────────
              TextFormField(
                controller: _passController,
                obscureText: _ocultarContrasena,
                // Al focalizarse, Flutter hace scroll hasta mostrar el botón
                // que queda justo debajo (≈ 55px alto + 20px margen)
                scrollPadding: const EdgeInsets.only(bottom: 100),
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  prefixIcon: Icon(Icons.password, color: colores.primary),
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

              SizedBox(height: 20),

              // ── BOTÓN DE INICIAR SESIÓN ────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 55,
                child: _cargando
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () {
                          LoginController.iniciarSesion(
                            context: context,
                            username: _usernameController.text,
                            password: _passController.text,
                            setCargando: (valor) =>
                                setState(() => _cargando = valor),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colores.primary,
                          foregroundColor: colores.onPrimary,
                        ),
                        child: const Text("Iniciar sesión"),
                      ),
              ),

              SizedBox(height: 20),

              // ── ENLACE A REGISTRO ──────────────────────────────────────
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "¿Aún no estás registrado?",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PantallaRegistro(),
                        ),
                      );
                    },
                    child: Text(
                      "¡Haz clic aquí!",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
