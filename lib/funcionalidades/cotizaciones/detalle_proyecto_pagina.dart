import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/cotizo_cubit.dart';
import '../../core/formato.dart';
import '../../core/theme/app_theme.dart';
import '../../dominio/modelos.dart';
import '../proformas/reporte_cierre_page.dart';
import '../proformas/proforma_documento_page.dart';
import '../../widgets/confirmar.dart';
import '../../widgets/estado_vacio.dart';
import '../gastos/formulario_gasto.dart';
import 'componentes/acciones_obra.dart';
import 'componentes/confirmacion_retraso.dart';
import 'componentes/detalle_listas_proyecto.dart';
import 'componentes/resumen_rentabilidad.dart';
import 'editor_proyecto_pagina.dart';

class DetalleProyectoPagina extends StatelessWidget {
  const DetalleProyectoPagina({
    super.key,
    required this.proyectoId,
    this.confirmarRetraso = false,
  });
  final int proyectoId;
  final bool confirmarRetraso;

  Future<void> _registrarGasto(BuildContext context) async {
    final cubit = context.read<CotizoCubit>();
    final gasto = await mostrarFormularioGasto(
      context,
      proyectos: cubit.state.datos.proyectos,
      proyectoId: proyectoId,
    );
    if (gasto == null || !context.mounted) return;
    final guardado = await cubit.guardarGasto(gasto);
    if (guardado && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gasto registrado en el proyecto')),
      );
    }
  }

  Future<void> _cambiarEstado(
    BuildContext context,
    Proyecto proyecto,
    EstadoProyecto? estado,
    List<ItemProyecto> partidas,
  ) async {
    if (estado == null || estado == proyecto.estado) return;
    final guardado = await context.read<CotizoCubit>().guardarProyecto(
      proyecto.conEstado(estado),
      partidas,
    );
    if (!context.mounted || !guardado) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Estado actualizado: ${estado.etiqueta}')),
    );
  }

  Future<void> _iniciar(BuildContext context, DateTime fecha) async {
    final guardado = await context.read<CotizoCubit>().iniciarObra(
      proyectoId,
      fecha,
    );
    if (guardado && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Obra iniciada')));
    }
  }

  Future<void> _finalizar(BuildContext context, DateTime fecha) async {
    final guardado = await context.read<CotizoCubit>().finalizarObra(
      proyectoId,
      fecha,
    );
    if (guardado && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Obra finalizada')));
    }
  }

  Future<void> _eliminar(BuildContext context) async {
    final confirmado = await confirmarEliminacion(
      context,
      'Se eliminarán esta cotización, sus materiales asociados y sus gastos. '
      'El catálogo de materiales se conserva. Esta acción no se puede deshacer.',
    );
    if (!confirmado || !context.mounted) return;
    final eliminado = await context.read<CotizoCubit>().eliminarProyecto(
      proyectoId,
    );
    if (eliminado && context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Detalle del proyecto')),
    body: BlocBuilder<CotizoCubit, EstadoCotizo>(
      builder: (context, estado) {
        final coincidencias = estado.datos.proyectos.where(
          (proyecto) => proyecto.id == proyectoId,
        );
        if (coincidencias.isEmpty) {
          return const Center(
            child: EstadoVacio(
              icono: Icons.request_quote_outlined,
              titulo: 'Cotización no disponible',
              mensaje: 'Vuelve a la lista para consultar tus otros proyectos.',
            ),
          );
        }
        final proyecto = coincidencias.first;
        final partidas = estado.datos.itemsDeProyecto(proyectoId);
        final gastos = estado.datos.gastosDeProyecto(proyectoId);
        final gastosPrevistos = estado.datos.gastosPrevistosDeProyecto(
          proyectoId,
        );
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'COT-${proyecto.id.toString().padLeft(3, '0')}',
                  style: const TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 8),
                Text(
                  proyecto.descripcion,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  proyecto.nombreCliente,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(label: Text(proyecto.etapa)),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 20,
                  runSpacing: 8,
                  children: [
                    Text(
                      'Inicio previsto: ${fechaCorta(proyecto.fechaInicio)}',
                    ),
                    Text(
                      proyecto.fechaFin == null
                          ? 'Fin previsto sin definir'
                          : 'Fin previsto: ${fechaCorta(proyecto.fechaFin!)}',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: estado.guardando
                          ? null
                          : () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ProformaDocumentoPage(
                                  proyectoId: proyecto.id,
                                ),
                              ),
                            ),
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('Ver proforma'),
                    ),
                    if (proyecto.estaFinalizada)
                      OutlinedButton.icon(
                        onPressed: estado.guardando
                            ? null
                            : () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => ReporteCierrePage(
                                    proyectoId: proyecto.id,
                                  ),
                                ),
                              ),
                        icon: const Icon(Icons.assignment_turned_in_outlined),
                        label: const Text('Reporte de cierre'),
                      ),
                    if (!proyecto.estaFinalizada)
                      OutlinedButton.icon(
                        onPressed: estado.guardando
                            ? null
                            : () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      EditorProyectoPagina(proyecto: proyecto),
                                ),
                              ),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Editar'),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                if (!proyecto.esObra)
                  DropdownButtonFormField<EstadoProyecto>(
                    key: ValueKey(
                      '${proyecto.estado.name}:${estado.guardando}',
                    ),
                    value: proyecto.estado,
                    decoration: const InputDecoration(
                      labelText: 'Estado de la cotización',
                      helperText:
                          'Actualízalo según el acuerdo con tu cliente.',
                    ),
                    items: EstadoProyecto.values
                        .where((opcion) => opcion != EstadoProyecto.finalizado)
                        .map(
                          (opcion) => DropdownMenuItem(
                            value: opcion,
                            child: Text(opcion.etiqueta),
                          ),
                        )
                        .toList(),
                    onChanged: estado.guardando
                        ? null
                        : (valor) => _cambiarEstado(
                            context,
                            proyecto,
                            valor,
                            partidas,
                          ),
                  ),
                if (!proyecto.esObra) const SizedBox(height: 20),
                AccionesObra(
                  proyecto: proyecto,
                  guardando: estado.guardando,
                  alIniciar: (fecha) => _iniciar(context, fecha),
                  alFinalizar: (fecha) => _finalizar(context, fecha),
                ),
                if (confirmarRetraso)
                  ConfirmacionRetraso(
                    proyecto: proyecto,
                    alFinalizar: (fecha) => _finalizar(context, fecha),
                  ),
                const SizedBox(height: 24),
                ResumenRentabilidad(
                  proyecto: proyecto,
                  partidas: partidas,
                  gastos: gastos,
                ),
                const SizedBox(height: 20),
                MaterialesProyectoDetalle(partidas: partidas),
                const SizedBox(height: 20),
                GastosPrevistosProyectoDetalle(gastos: gastosPrevistos),
                const SizedBox(height: 20),
                GastosProyectoDetalle(
                  gastos: gastos,
                  guardando: estado.guardando,
                  alRegistrar: () => _registrarGasto(context),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: estado.guardando
                        ? null
                        : () => _eliminar(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    icon: const Icon(Icons.delete_outline),
                    label: Text(
                      proyecto.esObra ? 'Eliminar obra' : 'Eliminar cotización',
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
