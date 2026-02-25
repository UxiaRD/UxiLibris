import 'package:flutter/material.dart';
import 'package:frontend_flutter/utilidades/actionsAppBar.dart';
import 'package:frontend_flutter/decoraciones/fondoBase.dart';
import 'package:frontend_flutter/pantallas/menuPrincipal.dart';
import 'package:frontend_flutter/pantallas/registro.dart';

// WIDGET que gestiona la pantalla de Inicio de Sesión de la App

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  bool _ocultarContrasena = true;

  @override
  Widget build(BuildContext context) {
    // Se extrae el esquema de colores para que sea más facil de llamar
    final ColorScheme colores = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar:
          true, // Extensión del body por detrás de al appBar

      appBar: AppBar(actions: ActionsAppBar.obtenerAcciones(context)),

      body: FondoBase(
        rutaImagen: 'assets/images/fondos/fondo.png',
        /* El SingleChildScrollView es necesario cuando se usa TextFromField ya que se despliega el teclado
        y permite que si el contenido queda tapado el usuario pueda hacer scroll */
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(80.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // El icono usa el morado principal del tema
              Icon(Icons.library_books, size: 80, color: colores.primary),

              SizedBox(height: 20),

              // El texto usa el estilo 'displayLarge' (TITULOS) que se define en AppThemes
              Text(
                "UxiLibris",
                style: Theme.of(context).textTheme.displayLarge,
              ),

              SizedBox(height: 40),

              // CAMPO: USUARIO
              // El TextFormField se usa para introducir texto en un formulario
              TextFormField(
                // No es necesario incluir el style ya que lo toma el textTheme
                decoration: InputDecoration(
                  labelText: "Usuario",
                  prefixIcon: Icon(Icons.person, color: colores.primary),
                ),
              ),

              SizedBox(height: 20),

              // CAMPO: CONTRASEÑA
              TextFormField(
                // Propiedad que oculta el texto escrito
                obscureText: _ocultarContrasena,
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

              // BOTÓN DE INICIAR SESIÓN
              // En este caso se añade el botón dentro de un SizedBox para darle el tamaño requerido
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MenuPrincipal()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    // onPrimary es el color de texto que se define para ir SOBRE el morado
                    backgroundColor: colores.primary,
                    foregroundColor: colores.onPrimary,
                  ),
                  child: const Text("Iniciar sesión"),
                ),
              ),

              SizedBox(height: 20),

              // Texto para el Registro de Usuario
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
