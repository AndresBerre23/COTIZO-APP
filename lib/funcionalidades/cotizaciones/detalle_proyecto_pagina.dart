import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/cotizo_cubit.dart';
import '../../core/formato.dart';
import '../../core/theme/app_theme.dart';
import '../../dominio/modelos.dart';
import '../../screens/proforma_screen.dart';
import '../../widgets/confirmar.dart';
import '../../widgets/estado_vacio.dart';
import '../gastos/formulario_gasto.dart';
import 'componentes/resumen_rentabilidad.dart';
import 'componentes/seccion_cotizacion.dart';
import 'editor_proyecto_pagina.dart';

class DetalleProyectoPagina extends StatelessWidget {
  const DetalleProyectoPagina({super.key, required this.proyectoId});
  final int proyectoId;

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
      Proyecto(
        id: proyecto.id,
        nombreCliente: proyecto.nombreCliente,
        descripcion: proyecto.descripcion,
        fechaInicio: proyecto.fechaInicio,
        fechaFin: proyecto.fechaFin,
        estado: estado,
        totalCotizadoCentavos: proyecto.totalCotizadoCentavos,
      ),
      partidas,
    );
    if (!context.mounted || !guardado) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Estado actualizado: ${estado.etiqueta}')),
    );
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
                const SizedBox(height: 12),
                Wrap(
                  spacing: 20,
                  runSpacing: 8,
                  children: [
                    Text('Inicio: ${fechaCorta(proyecto.fechaInicio)}'),
                    Text(
                      proyecto.fechaFin == null
                          ? 'Sin fecha de entrega'
                          : 'Entrega: ${fechaCorta(proyecto.fechaFin!)}',
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
                                builder: (_) => Scaffold(
                                  appBar: AppBar(title: const Text('Proforma')),
                                  body: ProformaPage(proyectoId: proyecto.id),
                                ),
                              ),
                            ),
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('Ver proforma'),
                    ),
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
                DropdownButtonFormField<EstadoProyecto>(
                  key: ValueKey('${proyecto.estado.name}:${estado.guardando}'),
                  value: proyecto.estado,
                  decoration: const InputDecoration(
                    labelText: 'Estado del proyecto',
                    helperText: 'Actualízalo según el acuerdo con tu cliente.',
                  ),
                  items: EstadoProyecto.values
                      .map(
                        (opcion) => DropdownMenuItem(
                          value: opcion,
                          child: Text(opcion.etiqueta),
                        ),
                      )
                      .toList(),
                  onChanged: estado.guardando
                      ? null
                      : (valor) =>
                            _cambiarEstado(context, proyecto, valor, partidas),
                ),
                const SizedBox(height: 24),
                ResumenRentabilidad(
                  proyecto: proyecto,
                  partidas: partidas,
                  gastos: gastos,
                ),
                const SizedBox(height: 20),
                SeccionCotizacion(
                  titulo: 'Materiales del proyecto',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (partidas.isEmpty)
                        const Text('No se han añadido materiales.'),
                      for (final partida in partidas)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                partida.nombreMaterial,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${partida.cantidad} ${partida.unidadMedida} × '
                                '${dinero(partida.costoUnitarioAplicadoCentavos)}',
                              ),
                              Text(
                                dinero(partida.subtotalCentavos),
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  color: AppColors.cobalt,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SeccionCotizacion(
                  titulo: 'Gastos registrados',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                        onPressed: estado.guardando
                            ? null
                            : () => _registrarGasto(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Registrar gasto'),
                      ),
                      const SizedBox(height: 12),
                      if (gastos.isEmpty)
                        const Text(
                          'Aún no hay gastos en este proyecto. '
                          'Añade el primero para actualizar la rentabilidad.',
                        ),
                      for (final gasto in gastos)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${gasto.categoria} · ${fechaCorta(gasto.fecha)}',
                              ),
                              if (gasto.nota.isNotEmpty) Text(gasto.nota),
                              Text(
                                dinero(gasto.montoCentavos),
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
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
                    label: const Text('Eliminar cotización'),
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
