import 'package:flutter/material.dart';
import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/pantallas/uxiLibrisApp.dart';
import 'package:frontend_flutter/decoraciones/themeProvider.dart';
import 'package:provider/provider.dart';

void main() async {
  // 1. Línea obligatoria para poder usar rootBundle (cargar el JSON) antes del runApp
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Cargamos los libros desde el JSON a la lista estática de la clase Libreria
  // Así, cuando la app arranque, los datos ya estarán en memoria.
  await Libreria.conDatosBackend();

  runApp(
    // Necesario para que el cambio de tema se aplique a toda la App
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const UxiLibrisApp(),
    ),
  );
}
