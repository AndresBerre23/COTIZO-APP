import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/cotizo_cubit.dart';
import '../../core/theme/app_theme.dart';
import '../../dominio/modelos.dart';
import '../../widgets/confirmar.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/pagina_base.dart';
import '../../widgets/surface_card.dart';
import 'formulario_material.dart';
import 'material_tarjeta.dart';

class MaterialsPage extends StatefulWidget {
  const MaterialsPage({super.key});

  @override
  State<MaterialsPage> createState() => _MaterialsPageState();
}

class _MaterialsPageState extends State<MaterialsPage> {
  String _busqueda = '';

  Future<void> _editar([MaterialObra? existente]) async {
    final edicion = await mostrarFormularioMaterial(
      context,
      material: existente,
    );
    if (edicion == null || !mounted) return;
    final guardado = await context.read<CotizoCubit>().guardarMaterial(edicion);
    if (guardado && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Material guardado en este dispositivo.')),
      );
    }
  }

  Future<void> _eliminar(MaterialObra material) async {
    final confirmado = await confirmarEliminacion(
      context,
      '¿Eliminar "${material.nombre}"? Los materiales usados en cotizaciones deben conservarse.',
    );
    if (!confirmado || !mounted) return;
    final eliminado = await context.read<CotizoCubit>().eliminarMaterial(
      material.id,
    );
    if (eliminado && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Material eliminado.')));
    }
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<CotizoCubit, EstadoCotizo>(
    builder: (context, estado) {
      final materiales = estado.datos.materiales
          .where(
            (material) => '${material.nombre} ${material.unidadMedida}'
                .toLowerCase()
                .contains(_busqueda.toLowerCase()),
          )
          .toList();
      return PaginaBase(
        titulo: 'Materiales',
        accion: FilledButton.icon(
          onPressed: estado.guardando ? null : () => _editar(),
          icon: const Icon(Icons.add),
          label: const Text('Nuevo material'),
        ),
        children: [
          const SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu catálogo, tus precios',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cobalt,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Guarda materiales y sus costos por unidad para reutilizarlos al cotizar. Todo funciona sin conexión.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (valor) => setState(() => _busqueda = valor.trim()),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Buscar material o unidad',
            ),
          ),
          const SizedBox(height: 16),
          if (materiales.isEmpty)
            EstadoVacio(
              icono: Icons.inventory_2_outlined,
              titulo: _busqueda.isEmpty
                  ? 'Prepara tu primera cotización'
                  : 'Sin coincidencias',
              mensaje: _busqueda.isEmpty
                  ? 'Añade un material con su unidad y costo. Podrás ajustar el precio en cada proyecto.'
                  : 'Prueba con otro nombre o unidad de medida.',
              accion: _busqueda.isEmpty
                  ? OutlinedButton(
                      onPressed: estado.guardando ? null : () => _editar(),
                      child: const Text('Añadir material'),
                    )
                  : null,
            )
          else ...[
            Text(
              '${materiales.length} materiales',
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            ...materiales.map(
              (material) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MaterialTarjeta(
                  material: material,
                  editar: estado.guardando ? null : () => _editar(material),
                  eliminar: estado.guardando ? null : () => _eliminar(material),
                ),
              ),
            ),
          ],
        ],
      );
    },
  );
}
