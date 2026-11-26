import 'package:flutter/material.dart';
import 'package:coti/core/enfoque.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/coti_cubit.dart';
import '../../dominio/modelos.dart';
import '../../widgets/confirmar.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/pagina_base.dart';
import 'componentes/controles_materiales.dart';
import 'componentes/filtros_materiales.dart';
import 'formulario_material.dart';
import 'material_tarjeta.dart';
import '../../widgets/ayuda/temas_ayuda.dart';

class MaterialesPagina extends StatefulWidget {
  const MaterialesPagina({super.key});

  @override
  State<MaterialesPagina> createState() => _MaterialesPaginaState();
}

class _MaterialesPaginaState extends State<MaterialesPagina> {
  String _busqueda = '';
  String? _unidad;
  FiltroImagenMaterial _filtroImagen = FiltroImagenMaterial.todos;
  OrdenMateriales _orden = OrdenMateriales.recientes;

  Future<void> _editar([MaterialObra? existente]) async {
    final edicion = await mostrarFormularioMaterial(
      context,
      material: existente,
    );
    if (edicion == null || !mounted) return;
    final guardado = await context.read<CotiCubit>().guardarMaterial(edicion);
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
    final eliminado = await context.read<CotiCubit>().eliminarMaterial(
      material.id,
    );
    if (eliminado && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Material eliminado.')));
    }
  }

  Future<void> _elegirUnidad(List<MaterialObra> materiales) async {
    final unidades =
        materiales.map((material) => material.unidadMedida).toSet().toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final unidadActual = unidades.contains(_unidad) ? _unidad : null;
    final seleccion = await mostrarFiltroUnidadMaterial(
      context,
      unidades: unidades,
      unidadActual: unidadActual,
    );
    if (seleccion != null && mounted) {
      setState(() => _unidad = seleccion.unidad);
    }
  }

  List<MaterialObra> _filtrar(List<MaterialObra> materiales) {
    final consulta = _busqueda.trim().toLowerCase();
    final resultado = materiales.where((material) {
      if (_unidad != null && material.unidadMedida != _unidad) return false;
      final tieneImagen = material.imagenRuta?.isNotEmpty ?? false;
      if (_filtroImagen == FiltroImagenMaterial.conImagen && !tieneImagen) {
        return false;
      }
      if (_filtroImagen == FiltroImagenMaterial.sinImagen && tieneImagen) {
        return false;
      }
      final texto = '${material.nombre} ${material.unidadMedida}'.toLowerCase();
      return consulta.isEmpty || texto.contains(consulta);
    }).toList();
    switch (_orden) {
      case OrdenMateriales.recientes:
        resultado.sort((a, b) => b.id.compareTo(a.id));
      case OrdenMateriales.nombre:
        resultado.sort(
          (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
        );
      case OrdenMateriales.unidad:
        resultado.sort(
          (a, b) => a.unidadMedida.toLowerCase().compareTo(
            b.unidadMedida.toLowerCase(),
          ),
        );
      case OrdenMateriales.mayorCosto:
        resultado.sort(
          (a, b) => b.costoBaseCentavos.compareTo(a.costoBaseCentavos),
        );
      case OrdenMateriales.menorCosto:
        resultado.sort(
          (a, b) => a.costoBaseCentavos.compareTo(b.costoBaseCentavos),
        );
    }
    return resultado;
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<CotiCubit, EstadoCoti>(
    builder: (context, estado) {
      final todos = estado.datos.materiales;
      final materiales = _filtrar(todos);
      final conImagen = todos
          .where((material) => material.imagenRuta?.isNotEmpty ?? false)
          .length;
      final sinImagen = todos.length - conImagen;
      final ancho = MediaQuery.sizeOf(context).width;
      final mostrarAccionMovil = ancho < 840 && todos.isNotEmpty;
      return Scaffold(
        body: PaginaBase(
          titulo: 'Materiales',
          ayuda: TemaAyuda.materiales,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: const Text(
                    'Guarda materiales y sus costos por unidad para reutilizarlos al cotizar.',
                  ),
                ),
                if (ancho >= 840 && todos.isNotEmpty)
                  FilledButton.icon(
                    onPressed: estado.guardando ? null : () => _editar(),
                    icon: const Icon(Icons.add),
                    label: const Text('Nuevo material'),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              onTapOutside: cerrarFocoAlTocarFuera,
              onChanged: (valor) => setState(() => _busqueda = valor),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: 'Buscar material o unidad',
                suffixIcon: _busqueda.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpiar búsqueda',
                        onPressed: () => setState(() => _busqueda = ''),
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            ControlesMateriales(
              total: todos.length,
              conImagen: conImagen,
              sinImagen: sinImagen,
              resultados: materiales.length,
              filtroImagen: _filtroImagen,
              unidad: _unidad,
              orden: _orden,
              alCambiarImagen: (valor) => setState(() => _filtroImagen = valor),
              alElegirUnidad: () => _elegirUnidad(todos),
              alOrdenar: (valor) => setState(() => _orden = valor),
            ),
            const SizedBox(height: 16),
            if (materiales.isEmpty)
              _estadoVacio(todos, estado.guardando)
            else
              for (final material in materiales)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MaterialTarjeta(
                    material: material,
                    editar: estado.guardando ? null : () => _editar(material),
                    eliminar: estado.guardando
                        ? null
                        : () => _eliminar(material),
                  ),
                ),
            if (mostrarAccionMovil) const SizedBox(height: 76),
          ],
        ),
        floatingActionButton: mostrarAccionMovil
            ? FloatingActionButton.extended(
                heroTag: 'nuevo-material',
                onPressed: estado.guardando ? null : () => _editar(),
                icon: const Icon(Icons.add),
                label: const Text('Nuevo material'),
              )
            : null,
      );
    },
  );

  Widget _estadoVacio(List<MaterialObra> todos, bool guardando) => EstadoVacio(
    icono: Icons.inventory_2_outlined,
    titulo: todos.isEmpty
        ? 'Prepara tu primera cotización'
        : 'Sin coincidencias',
    mensaje: todos.isEmpty
        ? 'Añade un material con su unidad y costo. Podrás ajustar el precio en cada proyecto.'
        : 'Prueba con otro nombre o cambia los filtros.',
    accion: todos.isEmpty
        ? OutlinedButton.icon(
            onPressed: guardando ? null : () => _editar(),
            icon: const Icon(Icons.add),
            label: const Text('Añadir material'),
          )
        : null,
  );
}
