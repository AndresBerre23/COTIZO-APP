import 'package:flutter/material.dart';
import '../../core/formato.dart';
import '../../dominio/calcular_rentabilidad.dart';
import '../../dominio/modelos.dart';
import '../../widgets/surface_card.dart';

class ResumenFinanciero extends StatelessWidget {
  const ResumenFinanciero({super.key, required this.datos});
  final DatosLocales datos;

  @override
  Widget build(BuildContext context) {
    final obras = datos.proyectos.where((proyecto) => proyecto.esObra).toList();
    final ingresos = obras.fold<int>(
      0,
      (total, proyecto) => total + proyecto.totalCotizadoCentavos,
    );
    final generales = datos.gastos
        .where((gasto) => gasto.proyectoId == null)
        .fold<int>(0, (total, gasto) => total + gasto.montoCentavos);
    final resultado =
        obras.fold<int>(
          0,
          (total, proyecto) =>
              total + calcularRentabilidad(proyecto, datos.items, datos.gastos),
        ) -
        generales;
    final costosObras = ingresos - generales - resultado;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BALANCE ESTIMADO DE OBRAS',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              dinero(resultado),
              style: TextStyle(
                fontSize: 36,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                color: resultado < 0
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Obras iniciadas y finalizadas, menos sus costos y todos los gastos generales.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 32,
            runSpacing: 16,
            children: [
              _Dato('Total cotizado', dinero(ingresos)),
              _Dato('Costos de obras', dinero(costosObras)),
              _Dato('Gastos generales', dinero(generales)),
            ],
          ),
          const Divider(height: 28),
          Text(
            'Estimación basada en lo registrado. No representa cobros ni pagos confirmados.',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato(this.etiqueta, this.valor);
  final String etiqueta, valor;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        etiqueta,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        valor,
        style: TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w700,
          fontSize: 17,
        ),
      ),
    ],
  );
}
