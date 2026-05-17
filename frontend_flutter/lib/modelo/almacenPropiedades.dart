import 'package:frontend_flutter/modelo/propiedad.dart';

class AlmacenPropiedades {
  List<Propiedad> propiedades;

  AlmacenPropiedades({required this.propiedades});

  dynamic obtenerValor(String nombrePropiedad) {
    return propiedades
        .firstWhere(
          (p) => p.nombre == nombrePropiedad,
          orElse: () => Propiedad(nombre: '', tipo: TipoDato.texto),
        )
        .valor;
  }

  factory AlmacenPropiedades.fromJson(List<dynamic> jsonLista) {
    return AlmacenPropiedades(
      propiedades: jsonLista.map((p) => Propiedad.fromJson(p)).toList(),
    );
  }
}
