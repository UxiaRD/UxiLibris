import 'package:flutter/material.dart';

class BarraBusqueda extends StatelessWidget {
  final TextEditingController controladorBusqueda;
  final Function(String) onChanged;

  const BarraBusqueda({
    super.key,
    required this.controladorBusqueda,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      // TextField es el campo en el que se introduce el texto de la busqueda
      child: TextField(
        controller: controladorBusqueda,
        onChanged: onChanged, // Usamos la función que viene del padre
        decoration: InputDecoration(
          hintText: "Buscar por título o autor...",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              controladorBusqueda.clear();
              onChanged(''); // Limpiamos la búsqueda
            },
          ),
          // La propiedad filled determina el color de fondo de area TextField
          filled: true,
          fillColor: Theme.of(context).cardColor.withValues(alpha: 0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
