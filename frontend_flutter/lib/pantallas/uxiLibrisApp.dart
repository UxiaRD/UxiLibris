import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend_flutter/decoraciones/appThemes.dart';
import 'package:frontend_flutter/pantallas/login.dart';
import 'package:frontend_flutter/decoraciones/themeProvider.dart';
import 'package:provider/provider.dart';

final RouteObserver<PageRoute<dynamic>> routeObserver =
    RouteObserver<PageRoute<dynamic>>();

class UxiLibrisApp extends StatelessWidget {
  const UxiLibrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchador del Provider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "UxiLibris",

      navigatorObservers: [routeObserver],

      // Localización en español (fechas en formato dd/mm/aaaa)
      locale: const Locale('es', 'ES'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
      ],

      // Definición de los temas
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeProvider.themeMode, //Control global del los temas

      home: PantallaLogin(),
    );
  }
}