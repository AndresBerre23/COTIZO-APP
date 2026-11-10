import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';

import '../../aplicacion/cotizo_cubit.dart';
import '../../dominio/modelos.dart';
import '../../widgets/estado_vacio.dart';
import 'servicio_pdf.dart';
import 'vista_proforma.dart';

class ProformaDocumentoPage extends StatefulWidget {
  const ProformaDocumentoPage({super.key, required this.proyectoId});

  final int proyectoId;

  @override
  State<ProformaDocumentoPage> createState() => _ProformaDocumentoPageState();
}

class _ProformaDocumentoPageState extends State<ProformaDocumentoPage> {
  bool _generando = false;

  Future<void> _exportar(
    Proyecto proyecto,
    List<ItemProyecto> items,
    List<GastoPrevisto> gastosPrevistos, {
    bool imprimir = false,
  }) async {
    if (_generando) return;
    setState(() => _generando = true);
    try {
      final datos = await ServicioPdf().generar(
        proyecto,
        items,
        gastosPrevistos: gastosPrevistos,
      );
      if (imprimir) {
        await Printing.layoutPdf(
          onLayout: (_) async => datos,
          name: 'Cotización ${proyecto.id}',
        );
      } else {
        await Printing.sharePdf(
          bytes: datos,
          filename: 'cotizacion-${proyecto.id}.pdf',
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo exportar el PDF. Puedes volver a intentarlo.',
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
    appBar: AppBar(title: const Text('Proforma')),
    body: BlocBuilder<CotizoCubit, EstadoCotizo>(
      builder: (context, estado) {
        final coincidencias = estado.datos.proyectos.where(
          (proyecto) => proyecto.id == widget.proyectoId,
        );
        if (coincidencias.isEmpty) {
          return const Center(
            child: EstadoVacio(
              icono: Icons.description_outlined,
              titulo: 'Proforma no disponible',
              mensaje: 'Vuelve a Documentos para elegir otra cotización.',
            ),
          );
        }
        final proyecto = coincidencias.first;
        final items = estado.datos.itemsDeProyecto(proyecto.id);
        final gastosPrevistos = estado.datos.gastosPrevistosDeProyecto(
          proyecto.id,
        );
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                VistaProforma(
                  proyecto: proyecto,
                  items: items,
                  gastosPrevistos: gastosPrevistos,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: _generando
                          ? null
                          : () => _exportar(proyecto, items, gastosPrevistos),
                      icon: const Icon(Icons.ios_share),
                      label: Text(
                        _generando ? 'Preparando PDF...' : 'Compartir PDF',
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _generando
                          ? null
                          : () => _exportar(
                              proyecto,
                              items,
                              gastosPrevistos,
                              imprimir: true,
                            ),
                      icon: const Icon(Icons.print_outlined),
                      label: const Text('Imprimir / guardar PDF'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
