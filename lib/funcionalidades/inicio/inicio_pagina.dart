import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../aplicacion/coti_cubit.dart';
import '../../core/formato.dart';
import '../../dominio/calcular_rentabilidad.dart';
import '../../dominio/modelos.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/pagina_base.dart';
import '../../widgets/surface_card.dart';
import 'resumen_financiero.dart';
import '../movimientos/componentes/tarjeta_balance_mes.dart';
import '../cotizaciones/editor_proyecto_pagina.dart';
import '../cotizaciones/detalle_proyecto_pagina.dart';
import '../gastos/formulario_gasto.dart';
import '../../widgets/ayuda/temas_ayuda.dart';

class InicioPagina extends StatefulWidget {
  const InicioPagina({super.key, this.cambiarSeccion});
  final ValueChanged<int>? cambiarSeccion;

  @override
  State<InicioPagina> createState() => _InicioPaginaState();
}

class _InicioPaginaState extends State<InicioPagina>
    with WidgetsBindingObserver {
  DateTime _ahora = DateTime.now();
  Timer? _cambioDia;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _programarCambioDia();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() => _ahora = DateTime.now());
      _programarCambioDia();
    }
  }

  void _programarCambioDia() {
    _cambioDia?.cancel();
    final ahora = DateTime.now();
    final siguienteDia = DateTime(ahora.year, ahora.month, ahora.day + 1);
    _cambioDia = Timer(siguienteDia.difference(ahora), () {
      if (!mounted) return;
      setState(() => _ahora = DateTime.now());
      _programarCambioDia();
    });
  }

  @override
  void dispose() {
    _cambioDia?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _registrarGasto(BuildContext context, DatosLocales datos) async {
    final gasto = await mostrarFormularioGasto(
      context,
      proyectos: datos.proyectos,
    );
    if (gasto == null || !context.mounted) return;
    final guardado = await context.read<CotiCubit>().guardarGasto(gasto);
    if (guardado && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gasto guardado')));
    }
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<CotiCubit, EstadoCoti>(
    builder: (context, estado) {
      final datos = estado.datos;
      final activos = datos.proyectos
          .where((proyecto) => proyecto.estaEnCurso)
          .toList();
      return PaginaBase(
        titulo: 'Inicio',
        ayuda: TemaAyuda.inicio,
        children: [
          Text(
            'Tus proyectos, con cuentas claras.',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Cotiza con tus precios y conoce cuánto queda después de cada gasto.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          const TarjetaBalanceMes(),
          const SizedBox(height: 20),
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
                icon: Icon(Icons.add),
                label: Text('Crear cotización'),
              ),
              OutlinedButton.icon(
                onPressed: estado.guardando
                    ? null
                    : () => _registrarGasto(context, datos),
                icon: Icon(Icons.receipt_long_outlined),
                label: Text('Registrar gasto'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Proyectos activos · ${activos.length}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (activos.isEmpty)
            EstadoVacio(
              icono: Icons.construction_outlined,
              titulo: 'El próximo proyecto empieza aquí',
              mensaje:
                  'Añade tus materiales y crea una cotización. Todo queda guardado en este dispositivo.',
              accion: TextButton(
                onPressed: () => widget.cambiarSeccion?.call(2),
                child: Text('Preparar mis materiales'),
              ),
            ),
          ...activos.map((proyecto) {
            final retrasada = proyecto.estaRetrasada(_ahora);
            final rentabilidad = calcularRentabilidad(
              proyecto,
              datos.items,
              datos.gastos,
              adicionales: datos.adicionales,
            );
            final costo = proyecto.totalCotizadoCentavos - rentabilidad;
            final proporcion = proyecto.totalCotizadoCentavos > 0
                ? (costo / proyecto.totalCotizadoCentavos).clamp(0.0, 1.0)
                : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Semantics(
                button: true,
                label: 'Abrir detalle de ${proyecto.descripcion}',
                child: SurfaceCard(
                  padding: EdgeInsets.zero,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => DetalleProyectoPagina(
                          proyectoId: proyecto.id,
                          confirmarRetraso: retrasada,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (retrasada) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Obra en retraso · ${proyecto.diasDeRetraso(_ahora)} '
                                    '${proyecto.diasDeRetraso(_ahora) == 1 ? 'día' : 'días'}',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                          Text(
                            proyecto.descripcion,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            proyecto.nombreCliente,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Chip(label: Text(proyecto.etapa)),
                              Text(
                                'Cotizado: ${dinero(proyecto.totalCotizadoCentavos)}',
                              ),
                              Text(
                                'Disponible: ${dinero(rentabilidad)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: rentabilidad < 0
                                      ? Theme.of(context).colorScheme.error
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: proporcion,
                            color: rentabilidad < 0
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.secondary,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Costos registrados: ${dinero(costo)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ver detalle',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      );
    },
  );
}
