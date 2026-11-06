import 'package:flutter/material.dart';
import '../../core/formato.dart';
import '../../core/theme/app_theme.dart';
import '../../dominio/calcular_rentabilidad.dart';
import '../../dominio/modelos.dart';
import '../../widgets/surface_card.dart';

class ResumenFinanciero extends StatelessWidget {
  const ResumenFinanciero({super.key, required this.datos});
  final DatosLocales datos;

  @override
  Widget build(BuildContext context) {
    final confirmados = datos.proyectos
        .where(
          (proyecto) =>
              proyecto.estado == EstadoProyecto.aprobado ||
              proyecto.estado == EstadoProyecto.finalizado,
        )
        .toList();
    final ingresos = confirmados.fold<int>(
      0,
      (total, proyecto) => total + proyecto.totalCotizadoCentavos,
    );
    final generales = datos.gastos
        .where((gasto) => gasto.proyectoId == null)
        .fold<int>(0, (total, gasto) => total + gasto.montoCentavos);
    final resultado =
        confirmados.fold<int>(
          0,
          (total, proyecto) =>
              total + calcularRentabilidad(proyecto, datos.items, datos.gastos),
        ) -
        generales;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BALANCE ESTIMADO',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
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
                color: resultado < 0 ? AppColors.error : AppColors.cobalt,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Proyectos aprobados y finalizados, menos sus costos y todos los gastos generales.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 32,
            runSpacing: 16,
            children: [
              _Dato('Total cotizado', dinero(ingresos)),
              _Dato('Costos y gastos', dinero(ingresos - resultado)),
              _Dato('Gastos generales', dinero(generales)),
            ],
          ),
          const Divider(height: 28),
          const Text(
            'Estimación basada en lo registrado. No representa cobros ni pagos confirmados.',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
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
        style: const TextStyle(fontSize: 12, color: AppColors.muted),
      ),
      const SizedBox(height: 4),
      Text(
        valor,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w700,
          fontSize: 17,
        ),
      ),
    ],
  );
}
