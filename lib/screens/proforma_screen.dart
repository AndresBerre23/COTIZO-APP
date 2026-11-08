import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import '../aplicacion/cotizo_cubit.dart';
import '../dominio/modelos.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/pagina_base.dart';
import '../funcionalidades/proformas/vista_proforma.dart';
import '../funcionalidades/proformas/servicio_pdf.dart';

class ProformaPage extends StatefulWidget {
  const ProformaPage({super.key, this.proyectoId});
  final int? proyectoId;
  @override
  State<ProformaPage> createState() => _ProformaPageState();
}

class _ProformaPageState extends State<ProformaPage> {
  int? _seleccion;
  bool _generando = false;
  @override
  void initState() {
    super.initState();
    _seleccion = widget.proyectoId;
  }

  Future<void> _exportar(
    Proyecto proyecto,
    List<ItemProyecto> items, {
    required List<GastoPrevisto> gastosPrevistos,
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
  Widget build(BuildContext context) => BlocBuilder<CotizoCubit, EstadoCotizo>(
    builder: (context, estado) {
      final proyectos = estado.datos.proyectos;
      if (proyectos.isEmpty) {
        return const PaginaBase(
          titulo: 'Proforma',
          children: [
            EstadoVacio(
              icono: Icons.description_outlined,
              titulo: 'Tu próxima propuesta, lista para compartir',
              mensaje:
                  'Primero crea una cotización. Aquí podrás revisar su proforma y generar el PDF.',
            ),
          ],
        );
      }
      final proyecto = proyectos.firstWhere(
        (proyecto) => proyecto.id == _seleccion,
        orElse: () => proyectos.first,
      );
      final items = estado.datos.itemsDeProyecto(proyecto.id);
      final gastosPrevistos = estado.datos.gastosPrevistosDeProyecto(
        proyecto.id,
      );
      return PaginaBase(
        titulo: 'Proforma',
        children: [
          DropdownButtonFormField<int>(
            key: ValueKey(proyecto.id),
            value: proyecto.id,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Selecciona una cotización',
            ),
            items: proyectos
                .map(
                  (proyecto) => DropdownMenuItem(
                    value: proyecto.id,
                    child: Text(
                      '${proyecto.nombreCliente} · ${proyecto.descripcion}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: _generando
                ? null
                : (valor) => setState(() => _seleccion = valor),
          ),
          const SizedBox(height: 20),
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
                    : () => _exportar(
                        proyecto,
                        items,
                        gastosPrevistos: gastosPrevistos,
                      ),
                icon: const Icon(Icons.ios_share),
                label: Text(_generando ? 'Preparando PDF...' : 'Compartir PDF'),
              ),
              OutlinedButton.icon(
                onPressed: _generando
                    ? null
                    : () => _exportar(
                        proyecto,
                        items,
                        gastosPrevistos: gastosPrevistos,
                        imprimir: true,
                      ),
                icon: const Icon(Icons.print_outlined),
                label: const Text('Imprimir / guardar PDF'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'El documento incluye la cotización. Los microgastos y la rentabilidad son información interna.',
          ),
        ],
      );
    },
  );
}
