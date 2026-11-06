import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../aplicacion/cotizo_cubit.dart';
import '../core/formato.dart';
import '../core/theme/app_theme.dart';
import '../dominio/calcular_rentabilidad.dart';
import '../dominio/modelos.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/pagina_base.dart';
import '../widgets/surface_card.dart';
import '../funcionalidades/inicio/resumen_financiero.dart';
import '../funcionalidades/cotizaciones/editor_proyecto_pagina.dart';
import '../funcionalidades/gastos/formulario_gasto.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, this.cambiarSeccion});
  final ValueChanged<int>? cambiarSeccion;

  Future<void> _registrarGasto(BuildContext context, DatosLocales datos) async {
    final gasto = await mostrarFormularioGasto(
      context,
      proyectos: datos.proyectos,
    );
    if (gasto == null || !context.mounted) return;
    final guardado = await context.read<CotizoCubit>().guardarGasto(gasto);
    if (guardado && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gasto guardado')));
    }
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<CotizoCubit, EstadoCotizo>(
    builder: (context, estado) {
      final datos = estado.datos;
      final activos = datos.proyectos
          .where((proyecto) => proyecto.estado != EstadoProyecto.finalizado)
          .toList();
      return PaginaBase(
        titulo: 'Inicio',
        children: [
          const Text(
            'Tus proyectos, con cuentas claras.',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cotiza con tus precios y conoce cuánto queda después de cada gasto.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          ResumenFinanciero(datos: datos),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: estado.guardando
                    ? null
                    : () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const EditorProyectoPagina(),
                        ),
                      ),
                icon: const Icon(Icons.add),
                label: const Text('Crear cotización'),
              ),
              OutlinedButton.icon(
                onPressed: estado.guardando
                    ? null
                    : () => _registrarGasto(context, datos),
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Registrar gasto'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Proyectos activos · ${activos.length}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (activos.isEmpty)
            EstadoVacio(
              icono: Icons.construction_outlined,
              titulo: 'El próximo proyecto empieza aquí',
              mensaje:
                  'Añade tus materiales y crea una cotización. Todo queda guardado en este dispositivo.',
              accion: TextButton(
                onPressed: () => cambiarSeccion?.call(2),
                child: const Text('Preparar mis materiales'),
              ),
            ),
          ...activos.map((proyecto) {
            final rentabilidad = calcularRentabilidad(
              proyecto,
              datos.items,
              datos.gastos,
            );
            final costo = proyecto.totalCotizadoCentavos - rentabilidad;
            final proporcion = proyecto.totalCotizadoCentavos > 0
                ? (costo / proyecto.totalCotizadoCentavos).clamp(0.0, 1.0)
                : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proyecto.descripcion,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      proyecto.nombreCliente,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Chip(label: Text(proyecto.estado.etiqueta)),
                        Text(
                          'Cotizado: ${dinero(proyecto.totalCotizadoCentavos)}',
                        ),
                        Text(
                          'Disponible: ${dinero(rentabilidad)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: rentabilidad < 0
                                ? AppColors.error
                                : AppColors.cobalt,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: proporcion,
                      color: rentabilidad < 0
                          ? AppColors.error
                          : AppColors.blue,
                      backgroundColor: AppColors.softBlue,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Costos registrados: ${dinero(costo)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      );
    },
  );
}
