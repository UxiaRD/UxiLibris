import 'package:flutter/material.dart';

class BarraBusqueda extends StatefulWidget {
  final TextEditingController controladorBusqueda;
  final Function(String) onChanged;
  final String hintText;

  const BarraBusqueda({
    super.key,
    required this.controladorBusqueda,
    required this.onChanged,
    this.hintText = 'Buscar...',
  });

  @override
  State<BarraBusqueda> createState() => _BarraBusquedaState();
}

class _BarraBusquedaState extends State<BarraBusqueda> {
  bool _tieneTexto = false;

  @override
  void initState() {
    super.initState();
    widget.controladorBusqueda.addListener(_actualizarEstado);
  }

  void _actualizarEstado() {
    final tieneTexto = widget.controladorBusqueda.text.isNotEmpty;
    if (tieneTexto != _tieneTexto) setState(() => _tieneTexto = tieneTexto);
  }

  @override
  void dispose() {
    widget.controladorBusqueda.removeListener(_actualizarEstado);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: TextField(
        controller: widget.controladorBusqueda,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _tieneTexto
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    widget.controladorBusqueda.clear();
                    widget.onChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.45),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}