import 'package:flutter/material.dart';

import '../../core/formato.dart';
import '../../dominio/modelos.dart';
import '../../widgets/surface_card.dart';

class TarjetaDocumento extends StatelessWidget {
  const TarjetaDocumento({
    super.key,
    required this.proyecto,
    required this.esReporte,
    required this.fecha,
    required this.alAbrir,
  });

  final Proyecto proyecto;
  final bool esReporte;
  final DateTime fecha;
  final VoidCallback alAbrir;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: SurfaceCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: alAbrir,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      proyecto.nombreCliente,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(esReporte ? 'Cierre' : proyecto.etapa),
                  ),
                ],
              ),
              Text(proyecto.descripcion),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  Text('COT-${proyecto.id.toString().padLeft(3, '0')}'),
                  Text(
                    '${esReporte ? 'Finalizada' : 'Inicio previsto'}: ${fechaCorta(fecha)}',
                  ),
                  Text(dinero(proyecto.totalCotizadoCentavos)),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: alAbrir,
                  icon: Icon(
                    esReporte
                        ? Icons.assignment_turned_in_outlined
                        : Icons.picture_as_pdf_outlined,
                  ),
                  label: Text(esReporte ? 'Ver reporte' : 'Ver proforma'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
