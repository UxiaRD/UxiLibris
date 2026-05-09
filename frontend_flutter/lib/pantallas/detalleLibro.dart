import 'package:flutter/material.dart';
import 'package:frontend_flutter/controladores/detalleLibroController.dart';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/modelo/saga.dart';
import 'package:frontend_flutter/pantallas/gestionLibro.dart';
import 'package:frontend_flutter/pantallas/widgetsDetalleLibro/badgeLibro.dart';
import 'package:frontend_flutter/pantallas/widgetsDetalleLibro/estrellasDetalle.dart';
import 'package:frontend_flutter/pantallas/widgetsDetalleLibro/fondoDetalle.dart';
import 'package:frontend_flutter/pantallas/widgetsDetalleLibro/portadaDetalle.dart';
import 'package:frontend_flutter/pantallas/widgetsDetalleLibro/propiedadesDetalle.dart';
import 'package:frontend_flutter/pantallas/widgetsDetalleLibro/tablaLecturas.dart';
import 'package:frontend_flutter/pantallas/widgetsDetalleLibro/tituloSeccion.dart';

class PantallaDetalleLibro extends StatefulWidget {
  final Libro libro;
  final Saga? saga;

  const PantallaDetalleLibro({super.key, required this.libro, this.saga});

  @override
  State<PantallaDetalleLibro> createState() => _PantallaDetalleLibroState();
}

class _PantallaDetalleLibroState extends State<PantallaDetalleLibro> {
  late Libro _libro;

  @override
  void initState() {
    super.initState();
    _libro = widget.libro;
  }

  Future<void> _irAEditar() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PantallaGestionLibro(libroExistente: _libro)),
    );
    if (mounted) setState(() {});
  }

  Future<void> _seleccionarFondo() async {
    if (_libro.id == null) return;
    final nuevaRuta = await DetalleLibroController.seleccionarFondo(_libro.id!);
    if (nuevaRuta != null && mounted) setState(() => _libro.rutaFondo = nuevaRuta);
  }

  Future<void> _quitarFondo() async {
    if (_libro.rutaFondo == null || _libro.id == null) return;
    final ok = await DetalleLibroController.quitarFondo(_libro.id!);
    if (ok && mounted) setState(() => _libro.rutaFondo = null);
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final mq = MediaQuery.of(context);
    final topPadding = mq.padding.top + kToolbarHeight + 20;
    final estadoSaga = DetalleLibroController.estadoSaga(widget.saga);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          _libro.titulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'editar') _irAEditar();
              if (value == 'fondo') _seleccionarFondo();
              if (value == 'quitarFondo') _quitarFondo();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'editar',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Editar libro'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'fondo',
                child: ListTile(
                  leading: Icon(_libro.rutaFondo != null
                      ? Icons.wallpaper
                      : Icons.add_photo_alternate_outlined),
                  title: Text(_libro.rutaFondo != null
                      ? 'Cambiar fondo'
                      : 'Añadir fondo personalizado'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (_libro.rutaFondo != null)
                const PopupMenuItem(
                  value: 'quitarFondo',
                  child: ListTile(
                    leading: Icon(Icons.hide_image_outlined, color: Colors.redAccent),
                    title: Text('Quitar fondo personalizado'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: FondoDetalle(
              rutaFondo: _libro.rutaFondo,
              rutaImagen: _libro.rutaImagen,
            ),
          ),
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: mq.size.height),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, topPadding, 20, mq.padding.bottom + 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    PortadaDetalle(rutaImagen: _libro.rutaImagen),
                    const SizedBox(height: 22),

                    Text(
                      _libro.titulo,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black54)],
                      ),
                    ),

                    if (_libro.autorNombre.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _libro.autorNombre,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                        ),
                      ),
                    ],

                    if (_libro.sagaNombre != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        _libro.numLibroSaga != null
                            ? '${_libro.sagaNombre} · Vol. ${DetalleLibroController.volumenStr(_libro.numLibroSaga!)}'
                            : _libro.sagaNombre!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                          shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    EstrellasDetalle(puntuacion: _libro.puntuacion),
                    const SizedBox(height: 14),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        BadgeLibro(
                          texto: DetalleLibroController.labelEstado(_libro.estado),
                          color: DetalleLibroController.colorEstado(_libro.estado),
                        ),
                        BadgeLibro(
                          texto: DetalleLibroController.labelFormato(_libro.formato),
                          color: colores.primary,
                        ),
                        if (_libro.favorito)
                          const BadgeLibro(texto: 'Favorito', color: Colors.amber),
                        if (estadoSaga != null)
                          BadgeLibro(
                            texto: estadoSaga,
                            color: DetalleLibroController.colorEstadoSaga(estadoSaga),
                          ),
                      ],
                    ),

                    if (_libro.almacen.propiedades.isNotEmpty) ...[
                      const SizedBox(height: 30),
                      const TituloSeccion('Propiedades adicionales'),
                      const SizedBox(height: 10),
                      PropiedadesDetalle(propiedades: _libro.almacen.propiedades),
                    ],

                    if (_libro.lecturas.isNotEmpty) ...[
                      const SizedBox(height: 30),
                      const TituloSeccion('Historial de lecturas'),
                      const SizedBox(height: 10),
                      TablaLecturas(lecturas: _libro.lecturas),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}