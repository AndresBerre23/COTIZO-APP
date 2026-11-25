import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../aplicacion/cotizo_cubit.dart';
import '../../../core/formato.dart';
import '../../../dominio/calcular_resumen_mes.dart';
import '../../../widgets/surface_card.dart';
import '../../reportes/reporte_mensual_pagina.dart';
import 'barra_comparativa.dart';

// Balance real del mes en curso: cobrado menos gastado (P-013).
class TarjetaBalanceMes extends StatelessWidget {
  const TarjetaBalanceMes({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<CotizoCubit, EstadoCotizo>(
    buildWhen: (anterior, actual) => anterior.datos != actual.datos,
    builder: (context, estado) {
      final resumen = calcularResumenMes(estado.datos, DateTime.now());
      final colores = Theme.of(context).colorScheme;
      final balance = resumen.balanceCentavos;
      final maximo = [
        resumen.ingresosCentavos,
        resumen.gastosCentavos,
      ].reduce((a, b) => a > b ? a : b);
      return SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BALANCE REAL DE ${mesLargo(resumen.mes).toUpperCase()}',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
                color: colores.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                dinero(balance),
                style: TextStyle(
                  fontSize: 36,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                  color: balance < 0 ? colores.error : colores.secondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            BarraComparativa(
              etiqueta: 'Cobrado',
              centavos: resumen.ingresosCentavos,
              maximo: maximo,
              color: colores.secondary,
            ),
            const SizedBox(height: 10),
            BarraComparativa(
              etiqueta: 'Gastado',
              centavos: resumen.gastosCentavos,
              maximo: maximo,
              color: colores.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Ingresos menos gastos registrados este mes. Los materiales '
              'cotizados solo cuentan cuando los registras como gasto.',
              style: TextStyle(fontSize: 12, color: colores.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ReporteMensualPagina(),
                  ),
                ),
                icon: const Icon(Icons.bar_chart),
                label: const Text('Ver reporte mensual'),
              ),
            ),
          ],
        ),
      );
    },
  );
}
