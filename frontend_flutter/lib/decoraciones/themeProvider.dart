import 'package:flutter/material.dart';

// CLASE que gestiona el modo claro / modo oscuro

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  // El interruptor llama a esta función
  void toggleTheme(bool isDarkMode) {
    switch (isDarkMode) {
      case true:
        _themeMode = ThemeMode.dark;
        break;
      case false:
        _themeMode = ThemeMode.light;
    }
    notifyListeners(); // Esto redibuja toda la app
  }
}