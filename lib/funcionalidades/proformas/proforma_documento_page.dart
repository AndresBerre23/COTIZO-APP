import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';

import '../../aplicacion/cotizo_cubit.dart';
import '../../aplicacion/preferencias_cubit.dart';
import '../../datos/almacen_imagen_local.dart';
import '../../dominio/modelos.dart';
import '../perfil/mi_perfil_pagina.dart';
import '../../widgets/estado_vacio.dart';
import 'componentes/desglose_interno_proforma.dart';
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

  Future<bool> _solicitarNombre() async {
    final decision = await showDialog<_DecisionNombre>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Completa tu proforma'),
        content: const Text(
          'Agrega tu nombre para incluirlo junto al del cliente. '
          'También podrás hacerlo más adelante desde Mi perfil.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _DecisionNombre.masTarde),
            child: const Text('Preguntarme más tarde'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _DecisionNombre.omitir),
            child: const Text('Continuar sin nombre permanentemente'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _DecisionNombre.agregar),
            child: const Text('Agregar nombre'),
          ),
        ],
      ),
    );
    if (!mounted) return false;
    if (decision == _DecisionNombre.agregar) {
      final guardado = await Navigator.of(
        context,
      ).push<bool>(MaterialPageRoute(builder: (_) => const MiPerfilPagina()));
      if (!mounted) return false;
      final tieneNombre = context.read<PreferenciasCubit>().state.tieneNombre;
      if (guardado == false && !tieneNombre) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingresa tu nombre para crear el PDF.')),
        );
      }
      return guardado == true && tieneNombre;
    }
    if (decision == _DecisionNombre.omitir) {
      try {
        await context.read<PreferenciasCubit>().omitirAvisoNombre();
        return true;
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo guardar esta decisión.')),
          );
        }
      }
    }
    return false;
  }

  Future<void> _exportar(
    Proyecto proyecto,
    List<ItemProyecto> items,
    List<GastoPrevisto> gastosPrevistos, {
    bool imprimir = false,
  }) async {
    if (_generando) return;
    final preferencias = context.read<PreferenciasCubit>().state;
    if (preferencias.nombreEmisor.isEmpty && !preferencias.omitirAvisoNombre) {
      if (!await _solicitarNombre()) return;
    }
    if (!mounted) return;
    final ajustes = context.read<PreferenciasCubit>().state;
    final cliente = context.read<CotizoCubit>().state.datos.clientePorId(
      proyecto.clienteId,
    );
    setState(() => _generando = true);
    try {
      final datos = await ServicioPdf().generar(
        proyecto,
        items,
        gastosPrevistos: gastosPrevistos,
        nombreEmisor: ajustes.nombreEmisor.isEmpty
            ? null
            : ajustes.nombreEmisor,
        negocio: ajustes.negocio,
        cliente: cliente,
        logoEmisor: await _leerLogo(ajustes.negocio.logoRuta),
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

  // Un logo ausente o dañado no impide crear el PDF.
  Future<Uint8List?> _leerLogo(String? ruta) async {
    if (ruta == null) return null;
    try {
      final archivo = await const AlmacenLogoNegocio().obtenerArchivo(ruta);
      return await archivo.exists() ? await archivo.readAsBytes() : null;
    } catch (_) {
      return null;
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
                  nombreEmisor: context
                      .watch<PreferenciasCubit>()
                      .state
                      .nombreEmisor,
                  cliente: estado.datos.clientePorId(proyecto.clienteId),
                ),
                const SizedBox(height: 16),
                DesgloseInternoProforma(
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

enum _DecisionNombre { agregar, omitir, masTarde }
