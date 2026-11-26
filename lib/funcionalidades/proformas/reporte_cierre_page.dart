import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';

import '../../aplicacion/coti_cubit.dart';
import '../../core/formato.dart';
import '../../dominio/calcular_desglose_proforma.dart';
import '../../dominio/calcular_rentabilidad.dart';
import '../../dominio/modelos.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/surface_card.dart';
import 'servicio_pdf.dart';

class ReporteCierrePage extends StatefulWidget {
  const ReporteCierrePage({super.key, required this.proyectoId});

  final int proyectoId;

  @override
  State<ReporteCierrePage> createState() => _ReporteCierrePageState();
}

class _ReporteCierrePageState extends State<ReporteCierrePage> {
  bool _generando = false;

  Future<void> _exportar(
    Proyecto proyecto,
    List<ItemProyecto> items, {
    required List<GastoPrevisto> gastosPrevistos,
    required List<Gasto> gastosAdicionales,
    bool imprimir = false,
  }) async {
    if (_generando) return;
    setState(() => _generando = true);
    try {
      final datos = await ServicioPdf().generarReporteCierre(
        proyecto,
        items,
        gastosPrevistos: gastosPrevistos,
        gastosAdicionales: gastosAdicionales,
        adicionalesCobradosCentavos: totalAdicionales(
          proyecto.id,
          context.read<CotiCubit>().state.datos.adicionales,
        ),
      );
      if (imprimir) {
        await Printing.layoutPdf(
          onLayout: (_) async => datos,
          name: 'Cierre de obra ${proyecto.id}',
        );
      } else {
        await Printing.sharePdf(
          bytes: datos,
          filename: 'cierre-obra-${proyecto.id}.pdf',
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo generar el reporte. Puedes volver a intentarlo.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Reporte de cierre')),
    body: BlocBuilder<CotiCubit, EstadoCoti>(
      builder: (context, estado) {
        final coincidencias = estado.datos.proyectos.where(
          (proyecto) => proyecto.id == widget.proyectoId,
        );
        if (coincidencias.isEmpty || !coincidencias.first.estaFinalizada) {
          return const Center(
            child: EstadoVacio(
              icono: Icons.assignment_outlined,
              titulo: 'Reporte no disponible',
              mensaje: 'El reporte se habilita al finalizar la obra.',
            ),
          );
        }

        final proyecto = coincidencias.first;
        final items = estado.datos.itemsDeProyecto(proyecto.id);
        final previstos = estado.datos.gastosPrevistosDeProyecto(proyecto.id);
        final adicionales = estado.datos.gastosDeProyecto(proyecto.id);
        final desglose = calcularDesgloseProforma(proyecto, items, previstos);
        final resultado = calcularResultadoCierre(
          desglose,
          adicionales,
          adicionalesCobradosCentavos: totalAdicionales(
            proyecto.id,
            estado.datos.adicionales,
          ),
        );
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  '${proyecto.nombreCliente} · ${proyecto.descripcion}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ajuste comercial',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      if (desglose.cobroManoObraCentavos > 0) ...[
                        Text(
                          'Cobro por mano de obra propia: '
                          '${dinero(desglose.cobroManoObraCentavos)}',
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(dinero(desglose.ajusteComercialCentavos)),
                      const SizedBox(height: 20),
                      Text(
                        'Gastos adicionales registrados',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (adicionales.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text('No se registraron gastos adicionales.'),
                        )
                      else
                        for (final gasto in adicionales)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${fechaHoraCorta(gasto.fecha)} · ${gasto.categoria}${gasto.nota.isEmpty ? '' : ' · ${gasto.nota}'}',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(dinero(gasto.montoCentavos)),
                              ],
                            ),
                          ),
                      const Divider(height: 28),
                      _ImporteCierre(
                        etiqueta: 'Total de gastos adicionales',
                        centavos: adicionales.fold<int>(
                          0,
                          (total, gasto) => total + gasto.montoCentavos,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _ImporteCierre(
                        etiqueta: 'Resultado después de gastos adicionales',
                        centavos: resultado,
                        destacado: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: _generando
                          ? null
                          : () => _exportar(
                              proyecto,
                              items,
                              gastosPrevistos: previstos,
                              gastosAdicionales: adicionales,
                            ),
                      icon: const Icon(Icons.ios_share),
                      label: Text(
                        _generando
                            ? 'Preparando PDF...'
                            : 'Compartir reporte PDF',
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _generando
                          ? null
                          : () => _exportar(
                              proyecto,
                              items,
                              gastosPrevistos: previstos,
                              gastosAdicionales: adicionales,
                              imprimir: true,
                            ),
                      icon: const Icon(Icons.print_outlined),
                      label: const Text('Imprimir / guardar PDF'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'El resultado descuenta del ajuste comercial los gastos adicionales registrados. Este reporte no es una factura.',
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class _ImporteCierre extends StatelessWidget {
  const _ImporteCierre({
    required this.etiqueta,
    required this.centavos,
    this.destacado = false,
  });

  final String etiqueta;
  final int centavos;
  final bool destacado;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(
          etiqueta,
          style: destacado ? Theme.of(context).textTheme.titleMedium : null,
        ),
      ),
      const SizedBox(width: 12),
      Text(
        dinero(centavos),
        style: destacado ? Theme.of(context).textTheme.titleMedium : null,
      ),
    ],
  );
}
