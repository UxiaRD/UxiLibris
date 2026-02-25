import 'package:flutter/material.dart';
import 'package:frontend_flutter/decoraciones/appThemes.dart';
import 'package:frontend_flutter/pantallas/login.dart';
import 'package:frontend_flutter/decoraciones/themeProvider.dart';
import 'package:provider/provider.dart';

class UxiLibrisApp extends StatelessWidget {
  const UxiLibrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchador del Provider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "UxiLibris",

      // Definición de los temas
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeProvider.themeMode, //Control global del los temas

      home: PantallaLogin(),
    );
  }
}
