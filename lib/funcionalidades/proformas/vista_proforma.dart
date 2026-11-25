import 'package:flutter/material.dart';
import '../../core/formato.dart';
import '../../dominio/calcular_partidas_cliente.dart';
import '../../dominio/modelos.dart';
import '../../widgets/surface_card.dart';
import '../../dominio/opciones_iva.dart';
import 'componentes/importe_proforma.dart';
import 'componentes/secciones_proforma_pdf.dart';

// Vista previa de la proforma tal como la recibe el cliente.
class VistaProforma extends StatelessWidget {
  const VistaProforma({
    super.key,
    required this.proyecto,
    required this.items,
    this.gastosPrevistos = const [],
    this.nombreEmisor = '',
    this.cliente,
  });
  final Proyecto proyecto;
  final List<ItemProyecto> items;
  final List<GastoPrevisto> gastosPrevistos;
  final String nombreEmisor;
  final Cliente? cliente;
  @override
  Widget build(BuildContext context) {
    final partidas = calcularPartidasCliente(proyecto, items, gastosPrevistos);
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nombreEmisor.isEmpty ? 'COTI' : nombreEmisor.toUpperCase(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'PROFORMA · ${codigoDocumento(proyecto.id)}',
            style: TextStyle(fontFamily: 'monospace'),
          ),
          const Divider(height: 32),
          Text(
            proyecto.nombreCliente,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          for (final dato in detallesCliente(cliente))
            Text(
              dato,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
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
              Text('Válida hasta: ${fechaCorta(proyecto.validaHasta)}'),
            ],
          ),
          const Divider(height: 32),
          for (final partida in partidas)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partida.descripcion,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 20,
                    runSpacing: 6,
                    children: [
                      Text(
                        '${cantidadCorta(partida.cantidad)} ${partida.unidad} × ${dinero(partida.unitarioCentavos)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        dinero(partida.subtotalCentavos),
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
          const Divider(height: 24),
          ImporteProforma('Subtotal', proyecto.totalCotizadoCentavos),
          if (proyecto.ivaPuntos != null)
            ImporteProforma(
              etiquetaIva(proyecto.ivaPuntos),
              proyecto.ivaCentavos,
            ),
          ImporteProforma(
            'TOTAL (USD)',
            proyecto.totalConIvaCentavos,
            destacado: true,
          ),
          if (proyecto.formaPago.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Forma de pago: ${proyecto.formaPago}'),
          ],
          if (proyecto.condiciones.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Condiciones: ${proyecto.condiciones}'),
          ],
          const SizedBox(height: 16),
          Text(
            'Cotización de referencia. No constituye una factura ni un comprobante de pago.',
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
