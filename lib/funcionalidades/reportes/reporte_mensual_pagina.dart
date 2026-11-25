import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';

import '../../aplicacion/cotizo_cubit.dart';
import '../../aplicacion/preferencias_cubit.dart';
import '../../core/formato.dart';
import '../../dominio/calcular_resumen_mes.dart';
import '../../widgets/surface_card.dart';
import 'componentes/desglose_categorias.dart';
import 'servicios/servicio_pdf_reporte.dart';

// Resumen de un mes con ingresos y gastos por categoría (P-014).
class ReporteMensualPagina extends StatefulWidget {
  const ReporteMensualPagina({super.key});

  @override
  State<ReporteMensualPagina> createState() => _ReporteMensualPaginaState();
}

class _ReporteMensualPaginaState extends State<ReporteMensualPagina> {
  late DateTime _mes;
  bool _exportando = false;

  @override
  void initState() {
    super.initState();
    final hoy = DateTime.now();
    _mes = DateTime(hoy.year, hoy.month);
  }

  bool get _esMesActual {
    final hoy = DateTime.now();
    return _mes.year == hoy.year && _mes.month == hoy.month;
  }

  static String _capitalizar(String texto) =>
      '${texto[0].toUpperCase()}${texto.substring(1)}';

  void _moverMes(int delta) =>
      setState(() => _mes = DateTime(_mes.year, _mes.month + delta));

  Future<void> _exportar(ResumenMes resumen) async {
    if (_exportando) return;
    final nombre = context.read<PreferenciasCubit>().state.nombreCompleto;
    setState(() => _exportando = true);
    try {
      final datos = await ServicioPdfReporte().generar(
        resumen,
        nombreEmisor: nombre.isEmpty ? null : nombre,
      );
      final mes = resumen.mes.month.toString().padLeft(2, '0');
      await Printing.sharePdf(
        bytes: datos,
        filename: 'reporte-${resumen.mes.year}-$mes.pdf',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo exportar el reporte.')),
        );
      }
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Reporte mensual')),
    body: BlocBuilder<CotizoCubit, EstadoCotizo>(
      builder: (context, estado) {
        final resumen = calcularResumenMes(estado.datos, _mes);
        final colores = Theme.of(context).colorScheme;
        final amplio = MediaQuery.sizeOf(context).width >= 840;
        final ingresos = DesgloseCategorias(
          titulo: 'Ingresos por categoría',
          totales: resumen.ingresosPorCategoria,
          color: colores.secondary,
          mensajeVacio: 'No hay ingresos en este mes.',
        );
        final gastos = DesgloseCategorias(
          titulo: 'Gastos por categoría',
          totales: resumen.gastosPorCategoria,
          color: colores.error,
          mensajeVacio: 'No hay gastos en este mes.',
        );
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Mes anterior',
                      onPressed: () => _moverMes(-1),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: Text(
                        _capitalizar(mesLargo(_mes)),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Mes siguiente',
                      onPressed: _esMesActual ? null : () => _moverMes(1),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SurfaceCard(
                  child: Wrap(
                    spacing: 32,
                    runSpacing: 16,
                    children: [
                      _Total(
                        'Ingresos',
                        resumen.ingresosCentavos,
                        colores.secondary,
                      ),
                      _Total('Gastos', resumen.gastosCentavos, colores.error),
                      _Total(
                        'Balance',
                        resumen.balanceCentavos,
                        resumen.balanceCentavos < 0
                            ? colores.error
                            : colores.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (amplio)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: ingresos),
                      const SizedBox(width: 16),
                      Expanded(child: gastos),
                    ],
                  )
                else ...[
                  ingresos,
                  const SizedBox(height: 16),
                  gastos,
                ],
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    onPressed: _exportando || resumen.vacio
                        ? null
                        : () => _exportar(resumen),
                    icon: const Icon(Icons.ios_share),
                    label: Text(
                      _exportando ? 'Preparando PDF...' : 'Compartir PDF',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class _Total extends StatelessWidget {
  const _Total(this.etiqueta, this.centavos, this.color);

  final String etiqueta;
  final int centavos;
  final Color color;

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
        dinero(centavos),
        style: TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: color,
        ),
      ),
    ],
  );
}
