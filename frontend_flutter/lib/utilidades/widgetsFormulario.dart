import 'package:flutter/material.dart';
import 'package:frontend_flutter/modelo/propiedad.dart';
import '../modelo/libro.dart';

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
      value: valorActual,
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

  // Método para los campos que se añaden dinámicamente
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

  /// Genera un selector de fecha con estilo consistente
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

  static Widget buildSearchField({
    required TextEditingController controller,
    required List<String> opciones,
    required String label,
    required IconData icono,
    required ColorScheme colores,
  }) {
    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: FocusNode(),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty)
          return const Iterable<String>.empty();
        return opciones.where(
          (String option) => option.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          ),
        );
      },
      onSelected: (String selection) => controller.text = selection,
      fieldViewBuilder:
          (context, fieldController, focusNode, onFieldSubmitted) {
            return buildTextField(fieldController, label, icono, colores);
          },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 300,
              color: colores.surface,
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
