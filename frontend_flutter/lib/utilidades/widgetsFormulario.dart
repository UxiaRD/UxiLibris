import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend_flutter/modelo/propiedad.dart';
import '../modelo/libro.dart';
import 'package:frontend_flutter/utilidades/searchField.dart';

class WidgetsFormulario {
  // MÉTODO PARA CAMPOS DE TEXTO
  static Widget buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    ColorScheme colores, {
    bool esNumerico = false,
    String? errorText, // Añadido para mostrar avisos de duplicados
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

  // MÉTODO PARA EL DESPLEGABLE DE ESTADO
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
              child: Text(estado.name.toUpperCase()),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  // MÉTODO PARA EL SELECTOR DE PUNTUACIÓN
  static Widget buildSelectorPuntuacion(
    double puntuacion,
    bool esLeido,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Puntuación: $puntuacion", // Mostramos el valor actual (ej: 3.5)
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: esLeido ? Colors.black : Colors.grey,
          ),
        ),
        Slider(
          value: puntuacion,
          min: 0,
          max: 5,
          divisions: 10, // <--- Esto permite los pasos de 0.5
          label: puntuacion.toString(),
          activeColor: Colors.amber,
          onChanged: esLeido ? onChanged : null,
        ),
      ],
    );
  }

  // MÉTODO PARA AÑADIR LOS CAMPOS DINÁMICAMENTE
  static Widget buildCampoDinamico(Propiedad prop, ColorScheme colores) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        initialValue: prop.valor?.toString(),
        decoration: InputDecoration(
          labelText: prop.nombre,
          prefixIcon: Icon(Icons.add_comment_outlined, color: colores.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        // Actualiza el valor directamente en el objeto propiedad
        onChanged: (nuevoValor) => prop.valor = nuevoValor,
      ),
    );
  }

  // MÉTODO PARA EL SELECTOR DE FECHA
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
          // Abre el calendario nativo de Flutter
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

  // MÉTODO PARA CAMPO DE TEXTO CON AUTOCOMPLETADO
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

  // MÉTODO PARA LA BUSQUEDA DE IMAGEN
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

  static Widget _renderizarImagen(File? archivo, String? rutaInicial) {
    // 1. Prioridad: Imagen recién seleccionada por el usuario
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
