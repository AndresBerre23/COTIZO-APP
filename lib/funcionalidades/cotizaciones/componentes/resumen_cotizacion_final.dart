import 'package:flutter/material.dart';

import '../../../core/formato.dart';
import '../../../dominio/modelos.dart';
import '../../../widgets/surface_card.dart';

class ResumenCotizacionFinal extends StatelessWidget {
  const ResumenCotizacionFinal({
    super.key,
    required this.proyecto,
    required this.partidas,
    required this.gastosPrevistos,
  });

  final Proyecto proyecto;
  final List<ItemProyecto> partidas;
  final List<GastoPrevisto> gastosPrevistos;

  @override
  Widget build(BuildContext context) {
    final costoMateriales = partidas.fold<int>(
      0,
      (total, partida) => total + partida.costoCentavos,
    );
    final gastos = gastosPrevistos.fold<int>(
      0,
      (total, gasto) => total + gasto.montoCentavos,
    );
    final costoPrevisto = costoMateriales + gastos;
    final margenEstimado =
        proyecto.totalCotizadoCentavos -
        costoPrevisto -
        proyecto.cobroManoObraCentavos;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de la cotización',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _DatoResumen(etiqueta: 'Cliente', valor: proyecto.nombreCliente),
          _DatoResumen(etiqueta: 'Proyecto', valor: proyecto.descripcion),
          _DatoResumen(
            etiqueta: 'Precio cotizado',
            valor: dinero(proyecto.totalCotizadoCentavos),
          ),
          _DatoResumen(
            etiqueta: 'Costos previstos',
            valor: dinero(costoPrevisto),
          ),
          if (proyecto.cobroManoObraCentavos > 0)
            _DatoResumen(
              etiqueta: 'Cobro por mano de obra propia',
              valor: dinero(proyecto.cobroManoObraCentavos),
            ),
          _DatoResumen(
            etiqueta: 'Margen sobre costos',
            valor: dinero(margenEstimado),
          ),
          _DatoResumen(
            etiqueta: 'Ganancia prevista total',
            valor: dinero(proyecto.totalCotizadoCentavos - costoPrevisto),
          ),
          _DatoResumen(
            etiqueta: 'Fechas previstas',
            valor:
                '${fechaCorta(proyecto.fechaInicio)} – ${proyecto.fechaFin == null ? 'Sin definir' : fechaCorta(proyecto.fechaFin!)}',
          ),
          _DatoResumen(
            etiqueta: 'Materiales',
            valor: '${partidas.length} partidas',
          ),
          _DatoResumen(
            etiqueta: 'Gastos previstos',
            valor: gastosPrevistos.isEmpty
                ? 'Ninguno'
                : '${gastosPrevistos.length} gastos · ${dinero(gastosPrevistos.fold<int>(0, (total, gasto) => total + gasto.montoCentavos))}',
          ),
        ],
      ),
    );
  }
}

class _DatoResumen extends StatelessWidget {
  const _DatoResumen({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final estiloEtiqueta = Theme.of(context).textTheme.bodySmall;
        if (constraints.maxWidth < 380) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(etiqueta, style: estiloEtiqueta),
              Text(valor),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 128, child: Text(etiqueta, style: estiloEtiqueta)),
            Expanded(child: Text(valor)),
          ],
        );
      },
    ),
  );
}
