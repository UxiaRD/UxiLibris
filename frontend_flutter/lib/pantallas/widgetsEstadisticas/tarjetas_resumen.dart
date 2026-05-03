import 'package:flutter/material.dart';

class TarjetasResumen extends StatelessWidget {
  final int anio;
  final int lecturasAnio;
  final int totalLeidos;
  final String mediaPuntuacion;
  final String autorFavorito;
  final ColorScheme colores;

  const TarjetasResumen({
    super.key,
    required this.anio,
    required this.lecturasAnio,
    required this.totalLeidos,
    required this.mediaPuntuacion,
    required this.autorFavorito,
    required this.colores,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _TarjetaEstadistica(
          titulo: 'Leídos en $anio',
          valor: '$lecturasAnio',
          icono: Icons.calendar_today_outlined,
          colores: colores,
        ),
        _TarjetaEstadistica(
          titulo: 'Total leídos',
          valor: '$totalLeidos',
          icono: Icons.check_circle_outline,
          colores: colores,
        ),
        _TarjetaEstadistica(
          titulo: 'Nota media',
          valor: mediaPuntuacion,
          icono: Icons.star_outline_rounded,
          colores: colores,
        ),
        _TarjetaEstadistica(
          titulo: 'Autor favorito',
          valor: autorFavorito,
          icono: Icons.person_outline,
          colores: colores,
          valorPequeno: true,
        ),
      ],
    );
  }
}

class _TarjetaEstadistica extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final ColorScheme colores;
  final bool valorPequeno;

  const _TarjetaEstadistica({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.colores,
    this.valorPequeno = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: colores.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colores.primary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icono, size: 16, color: colores.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    titulo,
                    style: TextStyle(fontSize: 11, color: colores.outline),
                  ),
                ),
              ],
            ),
            Text(
              valor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: valorPequeno ? 13 : 22,
                fontWeight: FontWeight.bold,
                color: colores.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}