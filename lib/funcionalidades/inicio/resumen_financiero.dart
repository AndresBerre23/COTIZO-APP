import 'package:flutter/material.dart';
import '../../core/formato.dart';
import '../../dominio/calcular_balance_obras.dart';
import '../../dominio/modelos.dart';
import '../../widgets/surface_card.dart';

class ResumenFinanciero extends StatelessWidget {
  const ResumenFinanciero({super.key, required this.datos});
  final DatosLocales datos;

  @override
  Widget build(BuildContext context) {
    final balance = calcularBalanceObras(datos);
    final resultado = balance.resultadoCentavos;
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
            'Cotizaciones aprobadas y obras, menos sus costos y todos los gastos generales.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 32,
            runSpacing: 16,
            children: [
              _Dato('Total cotizado', dinero(balance.totalCotizadoCentavos)),
              _Dato('Costos de obras', dinero(balance.costosCentavos)),
              _Dato('Gastos generales', dinero(balance.generalesCentavos)),
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
