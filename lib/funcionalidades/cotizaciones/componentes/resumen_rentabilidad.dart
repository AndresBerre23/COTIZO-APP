import 'package:flutter/material.dart';

import '../../../core/formato.dart';
import '../../../dominio/calcular_rentabilidad.dart';
import '../../../dominio/modelos.dart';
import '../../../widgets/surface_card.dart';

class ResumenRentabilidad extends StatelessWidget {
  const ResumenRentabilidad({
    super.key,
    required this.proyecto,
    required this.partidas,
    required this.gastos,
  });

  final Proyecto proyecto;
  final List<ItemProyecto> partidas;
  final List<Gasto> gastos;

  @override
  Widget build(BuildContext context) {
    final materiales = partidas.fold(
      0,
      (total, item) => total + item.costoCentavos,
    );
    final gastado = gastos.fold(
      0,
      (total, gasto) => total + gasto.montoCentavos,
    );
    final resultado = calcularRentabilidad(proyecto, partidas, gastos);
    final margen = proyecto.totalCotizadoCentavos == 0
        ? 0.0
        : resultado / proyecto.totalCotizadoCentavos * 100;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'RENTABILIDAD DEL PROYECTO',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              dinero(resultado),
              style: TextStyle(
                fontSize: 32,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                color: resultado < 0
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Text('Margen: ${margen.toStringAsFixed(1)}%'),
          const Divider(height: 32),
          _fila('Total cotizado', proyecto.totalCotizadoCentavos),
          _fila('Materiales', -materiales),
          _fila('Gastos del proyecto', -gastado),
          if (proyecto.cobroManoObraCentavos > 0) ...[
            _fila(
              'Cobro por mano de obra propia',
              proyecto.cobroManoObraCentavos,
            ),
            _fila(
              'Margen sobre costos',
              resultado - proyecto.cobroManoObraCentavos,
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Calculada con los costos y gastos registrados. '
            'Los gastos generales no se descuentan aquí.',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fila(String titulo, int monto) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 20,
      runSpacing: 4,
      children: [
        Text(titulo),
        Text(dinero(monto), style: TextStyle(fontFamily: 'monospace')),
      ],
    ),
  );
}
