import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../aplicacion/coti_cubit.dart';
import '../../../core/formato.dart';
import '../../../dominio/calcular_consumos_obra.dart';
import '../../../dominio/modelos.dart';
import '../../../widgets/confirmar.dart';
import '../../cotizaciones/componentes/seccion_cotizacion.dart';
import '../formulario_consumo.dart';
import '../../../widgets/ayuda/temas_ayuda.dart';

// Material cotizado frente al realmente usado en la obra (P-030).
class ConsumosObraDetalle extends StatelessWidget {
  const ConsumosObraDetalle({
    super.key,
    required this.proyecto,
    required this.datos,
    required this.guardando,
  });

  final Proyecto proyecto;
  final DatosLocales datos;
  final bool guardando;

  Future<void> _editar(BuildContext context, [Gasto? consumo]) async {
    final cubit = context.read<CotiCubit>();
    final editado = await mostrarFormularioConsumo(
      context,
      proyectoId: proyecto.id,
      materiales: cubit.state.datos.materiales,
      consumo: consumo,
    );
    if (editado != null) await cubit.guardarGasto(editado);
  }

  Future<void> _eliminar(BuildContext context, Gasto consumo) async {
    final cubit = context.read<CotiCubit>();
    if (await confirmarEliminacion(
      context,
      '¿Eliminar el consumo de ${consumo.nombreMaterial}?',
    )) {
      await cubit.eliminarGasto(consumo.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final consumos = datos
        .gastosDeProyecto(proyecto.id)
        .where((gasto) => gasto.esConsumo)
        .toList();
    final comparativo = calcularComparativoMateriales(
      proyecto.id,
      datos.items,
      consumos,
    );
    final colores = Theme.of(context).colorScheme;
    return SeccionCotizacion(
      titulo: 'Consumo real de materiales',
      ayuda: TemaAyuda.consumos,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            consumos.isEmpty
                ? 'Registra lo que realmente usas para comparar con lo cotizado.'
                : 'La rentabilidad ya usa estos consumos en lugar del material cotizado.',
            style: TextStyle(color: colores.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          if (consumos.isNotEmpty)
            for (final fila in comparativo)
              _FilaComparativo(fila: fila, colores: colores),
          for (final consumo in consumos)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(consumo.nombreMaterial ?? consumo.categoria),
              subtitle: Text(
                '${cantidadCorta(consumo.cantidad!)} × '
                '${dinero(consumo.costoUnitarioCentavos!)} · ${fechaCorta(consumo.fecha)}',
              ),
              onTap: guardando ? null : () => _editar(context, consumo),
              trailing: IconButton(
                tooltip: 'Eliminar consumo',
                onPressed: guardando ? null : () => _eliminar(context, consumo),
                icon: const Icon(Icons.delete_outline),
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: guardando || !proyecto.admiteGastos
                ? null
                : () => _editar(context),
            icon: const Icon(Icons.add),
            label: const Text('Registrar consumo'),
          ),
        ],
      ),
    );
  }
}

class _FilaComparativo extends StatelessWidget {
  const _FilaComparativo({required this.fila, required this.colores});

  final ComparativoMaterial fila;
  final ColorScheme colores;

  @override
  Widget build(BuildContext context) {
    final diferencia = fila.diferenciaCentavos;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fila.nombre,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              Text(
                'Cotizado: ${cantidadCorta(fila.cantidadCotizada)} ${fila.unidad} · '
                '${dinero(fila.costoCotizadoCentavos)}',
              ),
              Text(
                'Usado: ${cantidadCorta(fila.cantidadConsumida)} · '
                '${dinero(fila.costoConsumidoCentavos)}',
              ),
              Text(
                diferencia == 0
                    ? 'Sin diferencia'
                    : '${diferencia > 0 ? 'Sobrecosto' : 'Ahorro'}: ${dinero(diferencia.abs())}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: diferencia > 0 ? colores.error : colores.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
