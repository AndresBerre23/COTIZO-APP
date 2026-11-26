import 'package:flutter/material.dart';

import '../../../dominio/modelos.dart';
import '../../cotizaciones/componentes/cobros_proyecto_detalle.dart';
import '../../fotos/componentes/fotos_obra_detalle.dart';
import 'adicionales_detalle.dart';
import 'consumos_obra_detalle.dart';
import 'versiones_proforma_detalle.dart';

// Cobros, adicionales, consumos y versiones del detalle de un proyecto.
class SeccionesObraDetalle extends StatelessWidget {
  const SeccionesObraDetalle({
    super.key,
    required this.proyecto,
    required this.datos,
    required this.guardando,
  });

  final Proyecto proyecto;
  final DatosLocales datos;
  final bool guardando;

  @override
  Widget build(BuildContext context) {
    final adicionales = datos.adicionalesDeProyecto(proyecto.id);
    final versiones = datos.versionesDeProyecto(proyecto.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CobrosProyectoDetalle(
          proyecto: proyecto,
          ingresos: datos.ingresosDeProyecto(proyecto.id),
          adicionales: adicionales,
          devoluciones: datos
              .gastosDeProyecto(proyecto.id)
              .where((gasto) => gasto.esDevolucion)
              .toList(),
          guardando: guardando,
        ),
        const SizedBox(height: 20),
        AdicionalesDetalle(
          proyecto: proyecto,
          adicionales: adicionales,
          guardando: guardando,
        ),
        if (proyecto.esObra) ...[
          const SizedBox(height: 20),
          FotosObraDetalle(
            proyecto: proyecto,
            fotos: datos.fotosDeProyecto(proyecto.id),
          ),
        ],
        if (proyecto.admiteGastos) ...[
          const SizedBox(height: 20),
          ConsumosObraDetalle(
            proyecto: proyecto,
            datos: datos,
            guardando: guardando,
          ),
        ],
        if (versiones.isNotEmpty) ...[
          const SizedBox(height: 20),
          VersionesProformaDetalle(versiones: versiones),
        ],
      ],
    );
  }
}
