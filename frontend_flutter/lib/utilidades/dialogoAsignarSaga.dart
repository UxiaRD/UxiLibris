import 'package:flutter/material.dart';
import 'package:frontend_flutter/modelo/libro.dart';
import 'package:frontend_flutter/modelo/libreria.dart';
import 'package:frontend_flutter/servicio/ApiService.dart';

/// Muestra un diálogo para seleccionar un libro existente de la colección
/// y asignarlo a [nombreSaga]. Devuelve true si se realizó algún cambio.
class DialogoAsignarSaga {
  static Future<bool> mostrar({
    required BuildContext context,
    required String nombreSaga,
  }) async {
    final candidatos = Libreria.todosLosLibros
        .where((l) => l.sagaNombre != nombreSaga)
        .toList()
      ..sort((a, b) => a.titulo.compareTo(b.titulo));

    if (candidatos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Todos los libros de tu colección ya están en esta saga'),
        ),
      );
      return false;
    }

    return await showDialog<bool>(
          context: context,
          builder: (_) => _DialogoContenido(
            candidatos: candidatos,
            nombreSaga: nombreSaga,
          ),
        ) ??
        false;
  }
}

class _DialogoContenido extends StatefulWidget {
  final List<Libro> candidatos;
  final String nombreSaga;

  const _DialogoContenido({
    required this.candidatos,
    required this.nombreSaga,
  });

  @override
  State<_DialogoContenido> createState() => _DialogoContenidoState();
}

class _DialogoContenidoState extends State<_DialogoContenido> {
  Libro? _seleccionado;
  final TextEditingController _volumenController = TextEditingController();
  bool _guardando = false;

  @override
  void dispose() {
    _volumenController.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    if (_seleccionado == null) return;
    final id = _seleccionado!.id;
    if (id == null) return;

    setState(() => _guardando = true);

    final volumen = double.tryParse(_volumenController.text.trim());
    final exito =
        await ApiService.asignarSagaALibro(id, widget.nombreSaga, volumen);

    if (!mounted) return;
    setState(() => _guardando = false);

    if (exito) {
      // Actualizamos el modelo local para que la UI lo refleje sin recargar
      _seleccionado!.sagaNombre = widget.nombreSaga;
      _seleccionado!.numLibroSaga = volumen;
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al asignar el libro a la saga')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    // Limitamos la altura del diálogo al 75% de la pantalla para evitar overflow
    final maxAltura = MediaQuery.of(context).size.height * 0.75;

    return AlertDialog(
      title: const Text('Añadir libro a la saga'),
      // insetPadding reduce el margen horizontal para dar más espacio en móvil
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      content: SizedBox(
        width: double.maxFinite,
        height: maxAltura,
        child: Column(
          children: [
            // Lista ocupa todo el espacio disponible menos el campo de volumen
            Expanded(
              child: ListView.builder(
                itemCount: widget.candidatos.length,
                itemBuilder: (_, index) {
                  final libro = widget.candidatos[index];
                  final seleccionado = _seleccionado == libro;
                  return ListTile(
                    leading: Icon(
                      seleccionado
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: seleccionado ? colores.primary : null,
                    ),
                    title: Text(libro.titulo),
                    subtitle: Text(
                      libro.autorNombre,
                      style: TextStyle(color: colores.onSurfaceVariant),
                    ),
                    selected: seleccionado,
                    onTap: () => setState(() => _seleccionado = libro),
                    contentPadding: EdgeInsets.zero,
                  );
                },
              ),
            ),
            // Campo de volumen fijo en la parte inferior, visible cuando hay selección
            if (_seleccionado != null) ...[
              const Divider(),
              TextFormField(
                controller: _volumenController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Volumen en la saga (opcional)',
                  prefixIcon: Icon(Icons.format_list_numbered,
                      color: colores.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _seleccionado == null || _guardando ? null : _confirmar,
          child: _guardando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Añadir'),
        ),
      ],
    );
  }
}