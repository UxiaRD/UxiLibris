import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:frontend_flutter/controladores/escanerController.dart';
import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/pantallas/gestionLibro.dart';

class PantallaEscanerISBN extends StatefulWidget {
  final EstadoLibro? estadoInicial;

  const PantallaEscanerISBN({super.key, this.estadoInicial});

  @override
  State<PantallaEscanerISBN> createState() => _PantallaEscanerISBNState();
}

class _PantallaEscanerISBNState extends State<PantallaEscanerISBN>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  bool _procesando = false;
  late AnimationController _animController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animController);
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _procesarBarcode(String isbn) async {
    if (_procesando) return;
    setState(() => _procesando = true);
    await _controller.stop();

    try {
      final libro = await EscanerController.buscarPorISBN(isbn);
      if (!mounted) return;

      if (libro != null) {
        final duplicado = Libreria.todosLosLibros.any(
          (l) => l.titulo.toLowerCase() == libro.titulo.toLowerCase(),
        );
        if (duplicado && mounted) {
          final continuar = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Libro ya registrado'),
              content: Text(
                '"${libro.titulo}" ya está en tu biblioteca. ¿Deseas añadir otro ejemplar igualmente?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Añadir igualmente'),
                ),
              ],
            ),
          );
          if (continuar != true) {
            await _reiniciarEscaner();
            return;
          }
        }
        if (!mounted) return;
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PantallaGestionLibro(
              libroPrerellenado: widget.estadoInicial != null
                  ? libro.withEstado(widget.estadoInicial!)
                  : libro,
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se encontró información para ISBN: $isbn'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Añadir manualmente',
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PantallaGestionLibro()),
              ),
            ),
          ),
        );
        await _reiniciarEscaner();
      }
    } on FormatException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), duration: const Duration(seconds: 3)),
      );
      await _reiniciarEscaner();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al buscar el libro: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      await _reiniciarEscaner();
    }
  }

  /// Espera 3 s antes de reactivar la cámara para evitar redetectar
  /// el mismo código de barras en bucle tras un error o ISBN no encontrado.
  Future<void> _reiniciarEscaner() async {
    await Future.delayed(const Duration(seconds: 3));
    await _controller.start();
    if (mounted) setState(() => _procesando = false);
  }

  void _mostrarDialogoISBNManual() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Introducir ISBN'),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'ISBN (10 o 13 dígitos)',
            hintText: '9780000000000',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final isbn = textController.text.trim();
              if (isbn.isNotEmpty) {
                Navigator.pop(ctx);
                _procesarBarcode(isbn);
              }
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Escanear ISBN'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Vista de cámara
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
                final raw = barcode.rawValue;
                if (raw != null && !_procesando) {
                  _procesarBarcode(raw);
                  break;
                }
              }
            },
          ),

          // Overlay oscuro con ventana de escaneo
          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, _) => CustomPaint(
              painter: _ScanOverlayPainter(
                scanProgress: _scanAnimation.value,
                color: colores.primary,
              ),
              child: const SizedBox.expand(),
            ),
          ),

          // Instrucciones / cargando
          Positioned(
            bottom: 120,
            left: 24,
            right: 24,
            child: _procesando
                ? Column(
                    children: [
                      CircularProgressIndicator(color: colores.primary),
                      const SizedBox(height: 12),
                      const Text(
                        'Buscando información del libro...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : const Text(
                    'Apunta al código de barras ISBN\ndel libro para escanearlo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      shadows: [Shadow(color: Colors.black, blurRadius: 6)],
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),

          // Botón de ISBN manual
          if (!_procesando)
            Positioned(
              bottom: 48,
              left: 24,
              right: 24,
              child: OutlinedButton.icon(
                icon: const Icon(
                  Icons.keyboard_alt_outlined,
                  color: Colors.white,
                ),
                label: const Text(
                  'Introducir ISBN manualmente',
                  style: TextStyle(color: Colors.white),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _mostrarDialogoISBNManual,
              ),
            ),
        ],
      ),
    );
  }
}

/// Dibuja el overlay oscuro con el rectángulo de escaneo y la línea animada.
class _ScanOverlayPainter extends CustomPainter {
  final double scanProgress;
  final Color color;

  const _ScanOverlayPainter({required this.scanProgress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const radius = Radius.circular(12);
    final frameW = size.width * 0.75;
    final frameH = frameW * 0.45; // proporción apaisada para código de barras
    final left = (size.width - frameW) / 2;
    final top = (size.height - frameH) / 2;
    final frameRect = Rect.fromLTWH(left, top, frameW, frameH);

    // Capa oscura con hueco transparente
    canvas.drawPath(
      Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addRRect(RRect.fromRectAndRadius(frameRect, radius))
        ..fillType = PathFillType.evenOdd,
      Paint()..color = Colors.black.withOpacity(0.65),
    );

    // Borde del marco
    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, radius),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Esquinas destacadas
    const double c = 22;
    final cp = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    _drawCorner(canvas, cp, Offset(left, top), c, 1, 1);
    _drawCorner(canvas, cp, Offset(left + frameW, top), c, -1, 1);
    _drawCorner(canvas, cp, Offset(left, top + frameH), c, 1, -1);
    _drawCorner(canvas, cp, Offset(left + frameW, top + frameH), c, -1, -1);

    // Línea de escaneo animada
    final scanY = top + scanProgress * frameH;
    canvas.drawLine(
      Offset(left + 8, scanY),
      Offset(left + frameW - 8, scanY),
      Paint()
        ..shader = LinearGradient(
          colors: [
            color.withOpacity(0),
            color.withOpacity(0.9),
            color.withOpacity(0),
          ],
        ).createShader(Rect.fromLTWH(left, scanY, frameW, 2))
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawCorner(
    Canvas c,
    Paint p,
    Offset origin,
    double len,
    double dx,
    double dy,
  ) {
    c.drawLine(origin, origin + Offset(len * dx, 0), p);
    c.drawLine(origin, origin + Offset(0, len * dy), p);
  }

  @override
  bool shouldRepaint(_ScanOverlayPainter old) =>
      old.scanProgress != scanProgress;
}
