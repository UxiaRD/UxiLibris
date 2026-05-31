import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend_flutter/modelo/propiedad.dart';
import '../modelo/libro.dart';
import 'package:frontend_flutter/utilidades/searchField.dart';

// Color distintivo para libros digitales (usado en selector y badge)
const Color _colorDigital = Color(0xFF7B2FBE);

/// Colección de métodos estáticos que construyen los widgets reutilizables del formulario de libro.
class WidgetsFormulario {
  /// Campo de texto estándar del formulario, con soporte para teclado numérico y mensaje de error.
  static Widget buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    ColorScheme colores, {
    bool esNumerico = false,
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: esNumerico
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        prefixIcon: Icon(icon, color: colores.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Selector desplegable para el estado de lectura (pendiente, leyendo, leído, deseo).
  static Widget buildDropdownEstado(
    EstadoLibro valorActual,
    ColorScheme colores,
    Function(EstadoLibro?) onChanged,
  ) {
    return DropdownButtonFormField<EstadoLibro>(
      initialValue: valorActual,
      decoration: InputDecoration(
        labelText: "Estado de lectura",
        prefixIcon: Icon(Icons.import_contacts, color: colores.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: EstadoLibro.values
          .map(
            (estado) => DropdownMenuItem(
              value: estado,
              child: Text(_labelEstado(estado)),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  static String _labelEstado(EstadoLibro estado) => switch (estado) {
    EstadoLibro.pendiente => 'PENDIENTE',
    EstadoLibro.leyendo   => 'LEYENDO',
    EstadoLibro.leido     => 'LEÍDO',
    EstadoLibro.deseo     => 'QUIERO LEERLO',
  };

  /// Slider de puntuación de 0 a 5 en pasos de 0.5. Solo activo si el estado es 'leído'.
  static Widget buildSelectorPuntuacion(
    double puntuacion,
    bool esLeido,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Puntuación: $puntuacion",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: esLeido ? Colors.black : Colors.grey,
          ),
        ),
        Slider(
          value: puntuacion,
          min: 0,
          max: 5,
          divisions: 10, // 10 divisiones → incrementos de 0.5 entre 0 y 5
          label: puntuacion.toString(),
          activeColor: Colors.amber,
          onChanged: esLeido ? onChanged : null,
        ),
      ],
    );
  }

  /// Campo de texto para una propiedad personalizada con botones de editar y eliminar.
  static Widget buildCampoDinamico(
    Propiedad prop,
    ColorScheme colores, {
    VoidCallback? onEditar,
    VoidCallback? onEliminar,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              initialValue: prop.valor?.toString(),
              decoration: InputDecoration(
                labelText: prop.nombre,
                prefixIcon: Icon(Icons.add_comment_outlined, color: colores.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (nuevoValor) => prop.valor = nuevoValor,
            ),
          ),
          if (onEditar != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar nombre',
              onPressed: onEditar,
            ),
          if (onEliminar != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: colores.error,
              tooltip: 'Eliminar campo',
              onPressed: onEliminar,
            ),
        ],
      ),
    );
  }

  /// Selector de fecha con diálogo de calendario nativo de Flutter.
  static Widget buildDatePicker(
    BuildContext context,
    String label,
    DateTime? fecha,
    Function(DateTime) onSelected,
  ) {
    final colores = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () async {
          DateTime? picked = await showDialog<DateTime>(
            context: context,
            builder: (context) => DatePickerDialog(
              initialDate: fecha ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            ),
          );
          if (picked != null) onSelected(picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(Icons.calendar_today, color: colores.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            fecha == null
                ? "Seleccionar fecha"
                : "${fecha.day}/${fecha.month}/${fecha.year}",
            style: TextStyle(
              color: fecha == null
                  ? colores.onSurfaceVariant
                  : colores.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  /// Campo de texto con autocompletado de sugerencias (autores o sagas existentes).
  static Widget buildSearchField({
    required TextEditingController controller,
    required List<String> opciones,
    required String label,
    required IconData icono,
    required ColorScheme colores,
    Function(String)? onSelected,
  }) {
    return SearchField(
      controller: controller,
      opciones: opciones,
      label: label,
      icono: icono,
      colores: colores,
      onSelected: onSelected,
    );
  }

  /// Widget de portada con botón de cámara para seleccionar imagen desde la galería.
  static Widget buildSelectorImagen({
    required File? imagenArchivo,
    required String? rutaImagenInicial,
    required VoidCallback alPulsar,
    required Color primaryColor,
  }) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 150,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: _renderizarImagen(imagenArchivo, rutaImagenInicial),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: CircleAvatar(
              backgroundColor: primaryColor,
              child: IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                onPressed: alPulsar,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Botón segmentado para elegir entre formato físico y digital.
  static Widget buildSelectorFormato(
    FormatoLibro valorActual,
    ColorScheme colores,
    ValueChanged<FormatoLibro> onChanged,
  ) {
    return SegmentedButton<FormatoLibro>(
      segments: const [
        ButtonSegment(
          value: FormatoLibro.fisico,
          label: Text('Físico'),
          icon: Icon(Icons.menu_book_rounded),
        ),
        ButtonSegment(
          value: FormatoLibro.digital,
          label: Text('Digital'),
          icon: Icon(Icons.tablet_android_rounded),
        ),
      ],
      selected: {valorActual},
      onSelectionChanged: (sel) => onChanged(sel.first),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return valorActual == FormatoLibro.digital
                ? _colorDigital.withValues(alpha: 0.15)
                : colores.primaryContainer;
          }
          return null;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return valorActual == FormatoLibro.digital
                ? _colorDigital
                : colores.onPrimaryContainer;
          }
          return null;
        }),
      ),
    );
  }

  static Widget _renderizarImagen(File? archivo, String? rutaInicial) {
    // 1. Prioridad: imagen recién seleccionada por el usuario
    if (archivo != null) {
      return Image.file(
        archivo,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            Image.asset("assets/images/fondos/libro.png", fit: BoxFit.cover),
      );
    }
    // 2. URL remota (ej: portada de Google Books)
    if (rutaInicial != null && rutaInicial.startsWith("http")) {
      return Image.network(
        rutaInicial,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            Image.asset("assets/images/fondos/libro.png", fit: BoxFit.cover),
      );
    }
    // 3. Imagen local guardada en el dispositivo
    if (rutaInicial != null && !rutaInicial.contains("assets/")) {
      return Image.file(
        File(rutaInicial),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            Image.asset("assets/images/fondos/libro.png", fit: BoxFit.cover),
      );
    }
    // 4. Imagen por defecto de la aplicación
    return Image.asset("assets/images/fondos/libro.png", fit: BoxFit.cover);
  }
}