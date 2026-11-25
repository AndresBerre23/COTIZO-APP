import 'package:flutter/material.dart';

import '../../../dominio/calcular_desglose_proforma.dart';
import '../../../dominio/modelos.dart';
import '../../../widgets/surface_card.dart';
import 'importe_proforma.dart';

// Costos y margen de la cotización; solo se ven en la app, nunca en el PDF.
class DesgloseInternoProforma extends StatelessWidget {
  const DesgloseInternoProforma({
    super.key,
    required this.proyecto,
    required this.items,
    required this.gastosPrevistos,
  });

  final Proyecto proyecto;
  final List<ItemProyecto> items;
  final List<GastoPrevisto> gastosPrevistos;

  @override
  Widget build(BuildContext context) {
    final desglose = calcularDesgloseProforma(proyecto, items, gastosPrevistos);
    final colores = Theme.of(context).colorScheme;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline, size: 20, color: colores.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Desglose interno',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Solo lo ves tú. El cliente recibe los precios finales.',
            style: TextStyle(color: colores.onSurfaceVariant, fontSize: 13),
          ),
          const Divider(height: 24),
          ImporteProforma(
            'Materiales a costo',
            desglose.totalMaterialesCentavos,
          ),
          if (desglose.cobroManoObraCentavos > 0)
            ImporteProforma(
              'Mano de obra propia',
              desglose.cobroManoObraCentavos,
            ),
          for (final gasto in gastosPrevistos)
            ImporteProforma(
              gasto.descripcion.isEmpty
                  ? gasto.categoria
                  : '${gasto.categoria} · ${gasto.descripcion}',
              gasto.montoCentavos,
            ),
          ImporteProforma('Margen comercial', desglose.ajusteComercialCentavos),
        ],
      ),
    );
  }
}
