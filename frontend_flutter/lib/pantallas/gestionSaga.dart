import 'package:flutter/material.dart';
import 'package:frontend_flutter/decoraciones/fondoBase.dart';
import 'package:frontend_flutter/modelo/saga.dart';
import 'package:frontend_flutter/servicio/ApiService.dart';
import 'package:frontend_flutter/utilidades/dialogos.dart';

class PantallaGestionSaga extends StatefulWidget {
  final Saga? saga;

  const PantallaGestionSaga({super.key, this.saga});

  @override
  State<PantallaGestionSaga> createState() => _PantallaGestionSagaState();
}

class _PantallaGestionSagaState extends State<PantallaGestionSaga> {
  late TextEditingController _nombreController;
  late TextEditingController _totalController;

  bool get _esEdicion => widget.saga != null;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.saga?.nombre ?? '',
    );
    _totalController = TextEditingController(
      text: widget.saga?.totalLibros?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre de la saga es obligatorio')),
      );
      return;
    }

    final saga = Saga(
      id: widget.saga?.id,
      nombre: nombre,
      totalLibros: int.tryParse(_totalController.text.trim()),
    );

    final resultado = await ApiService.guardarSaga(saga);
    if (!mounted) return;

    if (resultado != null) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar la saga')),
      );
    }
  }

  Future<void> _eliminar() async {
    final id = widget.saga?.id;
    if (id == null) return;

    DialogosApp.confirmarEliminacion(
      context: context,
      titulo: '¿Eliminar saga?',
      contenido:
          'Se eliminará "${widget.saga!.nombre}" de la lista de sagas. '
          'Los libros asociados no se borrarán.',
      alConfirmar: () async {
        final exito = await ApiService.eliminarSaga(id);
        if (!mounted) return;
        if (exito) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al eliminar la saga')),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar Saga' : 'Nueva Saga'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
          if (_esEdicion)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              onPressed: _eliminar,
            ),
        ],
      ),
      body: FondoBase(
        rutaImagen: 'assets/images/fondos/estanteria.png',
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la saga',
                  prefixIcon: Icon(Icons.shelves, color: colores.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _totalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Total de libros en la saga',
                  hintText: 'Déjalo vacío si no lo sabes',
                  prefixIcon: Icon(
                    Icons.format_list_numbered,
                    color: colores.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save),
                label: Text(_esEdicion ? 'Actualizar Saga' : 'Crear Saga'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: colores.primary,
                  foregroundColor: colores.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}