import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/coti_cubit.dart';
import '../../core/enfoque.dart';
import '../../core/formato.dart';
import '../../dominio/modelos.dart';
import '../../widgets/ayuda/boton_ayuda.dart';
import '../../widgets/ayuda/temas_ayuda.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/surface_card.dart';
import 'componentes/cuadricula_fotos.dart';
import 'servicios/acciones_fotos.dart';
import 'visor_fotos_pagina.dart';

// Todas las fotos de obra agrupadas por proyecto, con búsqueda y mes.
class GaleriaFotos extends StatefulWidget {
  const GaleriaFotos({super.key});

  @override
  State<GaleriaFotos> createState() => _GaleriaFotosState();
}

class _GaleriaFotosState extends State<GaleriaFotos> {
  String _busqueda = '';
  DateTime? _mes;

  bool _coincide(FotoObra foto, Proyecto proyecto) {
    if (_mes != null &&
        (foto.fecha.year != _mes!.year || foto.fecha.month != _mes!.month)) {
      return false;
    }
    final consulta = _busqueda.trim().toLowerCase();
    if (consulta.isEmpty) return true;
    return '${proyecto.nombreCliente} ${proyecto.descripcion} '
            '${codigosBusqueda(proyecto.id)} ${foto.nota}'
        .toLowerCase()
        .contains(consulta);
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<CotiCubit, EstadoCoti>(
    builder: (context, estado) {
      final datos = estado.datos;
      final meses = {
        for (final foto in datos.fotos)
          DateTime(foto.fecha.year, foto.fecha.month),
      }.toList()..sort((a, b) => b.compareTo(a));
      final grupos =
          [
            for (final proyecto in datos.proyectos)
              (
                proyecto: proyecto,
                fotos: datos
                    .fotosDeProyecto(proyecto.id)
                    .where((foto) => _coincide(foto, proyecto))
                    .toList(),
              ),
          ].where((grupo) => grupo.fotos.isNotEmpty).toList()..sort(
            (a, b) => b.fotos.first.fecha.compareTo(a.fotos.first.fecha),
          );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onTapOutside: cerrarFocoAlTocarFuera,
                  onChanged: (texto) => setState(() => _busqueda = texto),
                  decoration: const InputDecoration(
                    labelText: 'Buscar cliente, obra, código o nota',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const BotonAyuda(tema: TemaAyuda.galeriaFotos),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final mes in [null, ...meses])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(mes == null ? 'Todas' : mesLargo(mes)),
                      selected: _mes == mes,
                      onSelected: (_) => setState(() => _mes = mes),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (grupos.isEmpty)
            EstadoVacio(
              icono: Icons.photo_library_outlined,
              titulo: datos.fotos.isEmpty
                  ? 'Aún no hay fotos de obras'
                  : 'No hay coincidencias',
              mensaje: datos.fotos.isEmpty
                  ? 'Agrégalas desde el detalle de una obra iniciada.'
                  : 'Prueba con otro texto o con otro mes.',
            ),
          for (final grupo in grupos)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _GrupoFotos(proyecto: grupo.proyecto, fotos: grupo.fotos),
            ),
        ],
      );
    },
  );
}

class _GrupoFotos extends StatelessWidget {
  const _GrupoFotos({required this.proyecto, required this.fotos});

  final Proyecto proyecto;
  final List<FotoObra> fotos;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    proyecto.descripcion,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${codigoDocumento(proyecto.id)} · ${proyecto.nombreCliente} · '
                    '${fotos.length} fotos · ${fechaCorta(fotos.first.fecha)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Compartir fotos de esta obra',
              onPressed: () => compartirFotos(fotos, proyecto),
              icon: const Icon(Icons.share_outlined),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CuadriculaFotos(proyectoId: proyecto.id, fotos: fotos, maximo: 8),
        if (fotos.length > 8)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => VisorFotosPagina(proyectoId: proyecto.id),
                ),
              ),
              child: Text('Ver las ${fotos.length} fotos'),
            ),
          ),
      ],
    ),
  );
}
