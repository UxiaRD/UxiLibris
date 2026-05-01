import 'package:flutter/material.dart';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/pantallas/gestionLibro.dart';
import 'package:frontend_flutter/servicio/ApiService.dart';

class PantallaBusquedaLibros extends StatefulWidget {
  final EstadoLibro? estadoInicial;

  const PantallaBusquedaLibros({super.key, this.estadoInicial});

  @override
  State<PantallaBusquedaLibros> createState() => _PantallaBusquedaLibrosState();
}

class _PantallaBusquedaLibrosState extends State<PantallaBusquedaLibros> {
  final TextEditingController _queryController = TextEditingController();
  List<Libro> _resultados = [];
  bool _buscando = false;
  bool _buscadoAlguna = false;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _buscando = true;
      _buscadoAlguna = true;
    });
    try {
      final resultados = await ApiService.buscarLibrosPorTexto(query);
      if (mounted) setState(() => _resultados = resultados);
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _buscando = false);
    }
  }

  Future<void> _seleccionar(Libro libro) async {
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
      if (continuar != true) return;
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
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Buscar libro'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            color: colores.surface,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
              left: 16,
              right: 16,
              bottom: 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _buscar(),
                    decoration: InputDecoration(
                      hintText: 'Título o autor...',
                      prefixIcon: Icon(Icons.search, color: colores.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: _buscando ? null : _buscar,
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),

          // Resultados
          Expanded(
            child: _buscando
                ? const Center(child: CircularProgressIndicator())
                : !_buscadoAlguna
                    ? _EstadoVacio(
                        icono: Icons.search,
                        mensaje: 'Introduce un título o autor\npara buscar',
                        colores: colores,
                      )
                    : _resultados.isEmpty
                        ? _EstadoVacio(
                            icono: Icons.search_off,
                            mensaje: 'No se encontraron resultados',
                            colores: colores,
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            itemCount: _resultados.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final libro = _resultados[index];
                              return _CardResultado(
                                libro: libro,
                                onTap: () => _seleccionar(libro),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  final IconData icono;
  final String mensaje;
  final ColorScheme colores;

  const _EstadoVacio({
    required this.icono,
    required this.mensaje,
    required this.colores,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 72, color: colores.outlineVariant),
          const SizedBox(height: 12),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: TextStyle(color: colores.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _CardResultado extends StatelessWidget {
  final Libro libro;
  final VoidCallback onTap;

  const _CardResultado({required this.libro, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Portada
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: libro.rutaImagen.startsWith('http')
                    ? Image.network(
                        libro.rutaImagen,
                        width: 56,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            _portadaVacia(colores),
                      )
                    : Image.asset(
                        'assets/images/fondos/libro.png',
                        width: 56,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 14),

              // Título + autor + saga
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      libro.titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (libro.autorNombre.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        libro.autorNombre,
                        style: TextStyle(
                          color: colores.onSurfaceVariant,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (libro.sagaNombre != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        libro.sagaNombre!,
                        style: TextStyle(
                          color: colores.primary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              Icon(Icons.chevron_right, color: colores.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _portadaVacia(ColorScheme colores) {
    return Container(
      width: 56,
      height: 80,
      color: colores.surfaceContainerHighest,
      child: Icon(Icons.book, color: colores.onSurfaceVariant, size: 28),
    );
  }
}