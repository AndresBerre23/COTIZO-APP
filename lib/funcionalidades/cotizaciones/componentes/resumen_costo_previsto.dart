import 'package:flutter/material.dart';

import '../../../core/formato.dart';
import '../../../dominio/calcular_presupuesto_proyecto.dart';
import '../../../widgets/surface_card.dart';

// Costo previsto que se muestra en el paso de gastos previstos.
class ResumenCostoPrevisto extends StatelessWidget {
  const ResumenCostoPrevisto({super.key, required this.presupuesto});

  final PresupuestoProyecto presupuesto;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Costo previsto de la cotización'),
        const SizedBox(height: 8),
        Text('Materiales: ${dinero(presupuesto.costoMaterialesCentavos)}'),
        Text(
          'Gastos previstos: ${dinero(presupuesto.costoPrevistoCentavos - presupuesto.costoMaterialesCentavos)}',
        ),
        const Divider(height: 20),
        Text(
          'Total previsto: ${dinero(presupuesto.costoPrevistoCentavos)}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}
