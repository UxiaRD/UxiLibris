import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  static const Color moradoPrincipal = Colors.deepPurple;
  static const Color moradoClaro = Color.fromARGB(255, 190, 177, 212);
  static const Color fondoOscuro = Color(0xFF121212);

  // TEMA CLARO
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: moradoPrincipal,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      secondary: moradoClaro,
    ),
    textTheme: GoogleFonts.montserratAlternatesTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          color: moradoPrincipal,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black),
      ),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      titleTextStyle: GoogleFonts.montserratAlternates(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: moradoPrincipal,
      ),
      backgroundColor:
          Colors.transparent, // Para visualizar el fondo incluso en la AppBar
      elevation: 0,
    ),
    drawerTheme: DrawerThemeData(backgroundColor: moradoClaro, width: 200.0),
  );

  // TEMA OSCURO
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: moradoClaro,
      onPrimary: Colors.black,
      surface: fondoOscuro,
      onSurface: Colors.white,
      secondary: moradoPrincipal,
    ),
    textTheme: GoogleFonts.montserratAlternatesTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          color: moradoClaro,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: Colors.white70),
        bodyMedium: TextStyle(color: Colors.white),
      ),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      titleTextStyle: GoogleFonts.montserratAlternates(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: moradoClaro,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(
        0xFF1E1E1E,
      ), // Un poco más claro que el fondo principal
      width: 200.0,
    ),
  );
}
