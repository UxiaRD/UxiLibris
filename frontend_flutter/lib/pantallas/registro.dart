import 'package:flutter/material.dart';
import 'package:frontend_flutter/utilidades/actionsAppBar.dart';
import 'package:frontend_flutter/decoraciones/fondoBase.dart';
import 'package:frontend_flutter/pantallas/login.dart';

// WIDGET que gestiona el Registro de la app

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  bool _ocultarContrasena = true;

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
                decoration: InputDecoration(
                  labelText: "Nombre de usuario",
                  prefixIcon: Icon(Icons.person, color: colores.primary),
                ),
              ),

              const SizedBox(height: 20),

              // CAMPO: EMAIL
              TextFormField(
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

              const SizedBox(height: 40),

              // BOTÓN DE REGISTRO
              ElevatedButton(
                onPressed: () {
                  // Aquí irá la lógica con Python más adelante

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PantallaLogin()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                ),
                child: const Text("Registrarse"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
