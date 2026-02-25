import 'package:flutter/material.dart';
import '../../modelo/libro.dart';

class FormularioLibro extends StatefulWidget {
  final Libro? libroParaEditar; // Si es null, estamos creando. Si no, editando.
  final Function(Libro) alGuardar; // Acción que haremos al pulsar el botón

  const FormularioLibro({
    super.key,
    this.libroParaEditar,
    required this.alGuardar,
  });

  @override
  State<FormularioLibro> createState() => _FormularioLibroState();
}

class _FormularioLibroState extends State<FormularioLibro> {
  late TextEditingController _tituloController;
  late TextEditingController _autorController;
  late EstadoLibro _estadoSeleccionado;
  late double _puntuacionActual;

  @override
  void initState() {
    super.initState();
    // Si se edita, usamos los valores del libro. Si no, valores por defecto.
    _tituloController = TextEditingController(
      text: widget.libroParaEditar?.titulo ?? "",
    );
    _autorController = TextEditingController(
      text: widget.libroParaEditar?.autor ?? "",
    );
    _estadoSeleccionado =
        widget.libroParaEditar?.estado ?? EstadoLibro.pendiente;
    _puntuacionActual = widget.libroParaEditar?.puntuacion ?? 0.0;
  }

  bool get _esLeido => _estadoSeleccionado == EstadoLibro.leido;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Simulación de selección de imagen
        Center(
          child: GestureDetector(
            onTap: () => print("Abrir selector de imágenes"),
            child: Container(
              height: 180,
              width: 120,
              decoration: BoxDecoration(
                color: colores.primaryContainer,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: colores.primary, width: 2),
              ),
              child: Icon(
                Icons.add_a_photo,
                size: 40,
                color: colores.secondary,
              ),
            ),
          ),
        ),

        const SizedBox(height: 30),

        // CAMPO TÍTULO
        TextFormField(
          controller: _tituloController,
          decoration: InputDecoration(
            labelText: "Título",
            prefixIcon: Icon(Icons.title, color: colores.primary),
          ),
        ),
        const SizedBox(height: 20),

        // CAMPO AUTOR
        TextFormField(
          controller: _autorController,
          decoration: InputDecoration(
            labelText: "Autor",
            prefixIcon: Icon(Icons.person, color: colores.primary),
          ),
        ),
        const SizedBox(height: 20),

        // DESPLEGABLE ESTADO
        DropdownButtonFormField<EstadoLibro>(
          initialValue: _estadoSeleccionado,
          items: EstadoLibro.values
              .map(
                (estado) => DropdownMenuItem(
                  value: estado,
                  child: Text(estado.name.toUpperCase()),
                ),
              )
              .toList(),
          onChanged: (val) => setState(() {
            _estadoSeleccionado = val!;
            if (!_esLeido) _puntuacionActual = 0.0;
          }),
        ),

        const SizedBox(height: 30),

        // SELECTOR DE PUNTUACIÓN (Estrellas)
        Text(
          "Puntuación:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _esLeido
                ? Colors.black
                : Colors.grey, // Cambia color si está desactivado
          ),
        ),
        Slider(
          value: _puntuacionActual,
          min: 0,
          max: 5,
          divisions: 5,
          label: _puntuacionActual.round().toString(),
          activeColor: Colors.amber,
          onChanged: _esLeido
              ? (double value) {
                  setState(() {
                    _puntuacionActual = value;
                  });
                }
              : null, // Al poner null, el Slider se deshabilita automáticamente
        ),

        // Visualización de estrellas en tiempo real
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (index) => Icon(
              index < _puntuacionActual ? Icons.star : Icons.star_border,
              color: _esLeido
                  ? Colors.amber
                  : Colors.grey.shade300, // Estrellas apagadas
            ),
          ),
        ),

        const SizedBox(height: 40),

        // BOTÓN DE ACCIÓN
        ElevatedButton(
          onPressed: () {
            // Creamos o actualizamos el objeto
            final libroResultante = Libro(
              titulo: _tituloController.text,
              autor: _autorController.text,
              rutaImagen:
                  widget.libroParaEditar?.rutaImagen ??
                  "assets/images/fondos/libro.png",
              puntuacion: _puntuacionActual,
              estado: _estadoSeleccionado,
            );

            // Ejecutamos la función que nos pasaron por parámetro
            widget.alGuardar(libroResultante);
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 55),
          ),

          child: Text(
            widget.libroParaEditar == null ? "Añadir Libro" : "Guardar Cambios",
          ),
        ),
      ],
    );
  }
}
