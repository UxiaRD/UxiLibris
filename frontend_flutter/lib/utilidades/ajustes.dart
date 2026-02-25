import 'package:flutter/material.dart';
import 'package:frontend_flutter/decoraciones/themeProvider.dart';
import 'package:provider/provider.dart';

// WIDGET de Ajustes -> En un futuro se implementarán mas funcionalidades

class PantallaAjustes extends StatelessWidget {
  const PantallaAjustes({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final esOscuro = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Ajustes")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              esOscuro ? "Modo oscuro activado" : "Modo claro activado",
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Switch(
              value: esOscuro,
              onChanged: (valor) {
                // LLAMADA AL PROVIDER: Esto cambia el tema en TODA la app
                themeProvider.toggleTheme(valor);
              },
            ),
          ],
        ),
      ),
    );
  }
}
