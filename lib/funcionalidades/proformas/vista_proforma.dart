import 'package:flutter/material.dart';
import '../../core/formato.dart';
import '../../core/theme/app_theme.dart';
import '../../dominio/calcular_desglose_proforma.dart';
import '../../dominio/modelos.dart';
import '../../widgets/surface_card.dart';

class VistaProforma extends StatelessWidget {
  const VistaProforma({
    super.key,
    required this.proyecto,
    required this.items,
    this.gastosPrevistos = const [],
  });
  final Proyecto proyecto;
  final List<ItemProyecto> items;
  final List<GastoPrevisto> gastosPrevistos;
  @override
  Widget build(BuildContext context) {
    final desglose = calcularDesgloseProforma(proyecto, items, gastosPrevistos);
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OBRAPRO',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.cobalt,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'PROFORMA · COT-${proyecto.id.toString().padLeft(4, '0')}',
            style: const TextStyle(fontFamily: 'monospace'),
          ),
          const Divider(height: 32),
          Text(
            proyecto.nombreCliente,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(proyecto.descripcion),
          const SizedBox(height: 12),
          Wrap(
            spacing: 20,
            runSpacing: 6,
            children: [
              Text('Inicio: ${fechaCorta(proyecto.fechaInicio)}'),
              if (proyecto.fechaFin != null)
                Text('Fin: ${fechaCorta(proyecto.fechaFin!)}'),
              Text(proyecto.estado.etiqueta),
            ],
          ),
          const Divider(height: 32),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nombreMaterial,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 20,
                    runSpacing: 6,
                    children: [
                      Text(
                        '${item.cantidad} ${item.unidadMedida} × ${dinero(item.costoUnitarioAplicadoCentavos)}',
                        style: const TextStyle(color: AppColors.muted),
                      ),
                      Text(
                        dinero(item.subtotalCentavos),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _Importe('Materiales', desglose.totalMaterialesCentavos),
          if (desglose.cobroManoObraCentavos > 0)
            _Importe('Mano de obra propia', desglose.cobroManoObraCentavos),
          for (final gasto in gastosPrevistos)
            _Importe(
              gasto.descripcion.isEmpty
                  ? gasto.categoria
                  : '${gasto.categoria} · ${gasto.descripcion}',
              gasto.montoCentavos,
            ),
          if (desglose.ajusteComercialCentavos != 0)
            _Importe('Ajuste comercial', desglose.ajusteComercialCentavos),
          const Divider(height: 24),
          _Importe(
            'TOTAL COTIZADO (USD)',
            proyecto.totalCotizadoCentavos,
            destacado: true,
          ),
          const SizedBox(height: 16),
          const Text(
            'Cotización de referencia. No constituye una factura ni un comprobante de pago.',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _Importe extends StatelessWidget {
  const _Importe(this.etiqueta, this.centavos, {this.destacado = false});
  final String etiqueta;
  final int centavos;
  final bool destacado;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Wrap(
      spacing: 20,
      runSpacing: 8,
      alignment: WrapAlignment.spaceBetween,
      children: [
        Text(
          etiqueta,
          style: TextStyle(
            fontWeight: destacado ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          dinero(centavos),
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w700,
            fontSize: destacado ? 22 : 15,
            color: AppColors.cobalt,
          ),
        ),
      ],
    ),
  );
}
