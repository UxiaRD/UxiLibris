import 'package:flutter/material.dart';
// WidgetsFormulario NO se importa aquí para evitar importación circular:
// widgetsFormulario.dart → searchField.dart → widgetsFormulario.dart
// Esa circularidad causaba el NoSuchMethodError en runtime.

/// Widget con estado propio que gestiona correctamente el FocusNode.
///
/// No uses este widget directamente desde las pantallas.
/// Llámalo siempre a través de WidgetsFormulario.buildSearchField(...).
class SearchField extends StatefulWidget {
  final TextEditingController controller;
  final List<String> opciones;
  final String label;
  final IconData icono;
  final ColorScheme colores;

  /// Callback opcional que se ejecuta cuando el usuario ELIGE una opción
  /// de la lista desplegable (no al escribir, solo al seleccionar).
  /// Útil para disparar lógica adicional, como sugerir el volumen de saga.
  final Function(String)? onSelected;

  const SearchField({
    super.key,
    required this.controller,
    required this.opciones,
    required this.label,
    required this.icono,
    required this.colores,
    this.onSelected,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  // El FocusNode se crea UNA sola vez y se libera cuando el widget muere.
  // Esto evita el memory leak que había cuando se creaba FocusNode()
  // dentro de un método estático (se creaba uno nuevo en cada rebuild).
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose(); // liberación obligatoria
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _focusNode, // siempre el mismo objeto, nunca uno nuevo
      optionsBuilder: (TextEditingValue value) {
        if (value.text.isEmpty) return const Iterable<String>.empty();
        return widget.opciones.where(
          (option) => option.toLowerCase().contains(value.text.toLowerCase()),
        );
      },
      onSelected: (String selection) {
        widget.controller.text = selection;
        // Si el padre pasó un callback, lo ejecutamos con la opción elegida
        widget.onSelected?.call(selection);
      },
      // fieldViewBuilder recibe el controller y focusNode INTERNOS del
      // RawAutocomplete. HAY que usarlos (no los del widget padre) porque
      // RawAutocomplete los necesita para coordinar el teclado y la lista
      // de sugerencias. Ignorarlos causaba el NoSuchMethodError.
      fieldViewBuilder:
          (context, fieldController, fieldFocusNode, onFieldSubmitted) {
            return TextFormField(
              controller: fieldController, // ← interno del RawAutocomplete
              focusNode: fieldFocusNode, // ← interno del RawAutocomplete
              decoration: InputDecoration(
                labelText: widget.label,
                prefixIcon: Icon(widget.icono, color: widget.colores.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 300,
              color: widget.colores.surface,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(options.elementAt(index)),
                  onTap: () => onSelected(options.elementAt(index)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
