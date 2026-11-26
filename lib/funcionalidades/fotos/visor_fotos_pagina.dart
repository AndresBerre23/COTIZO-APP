import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/coti_cubit.dart';
import '../../core/formato.dart';
import '../../datos/almacen_fotos_obra.dart';
import '../../dominio/modelos.dart';
import '../../widgets/confirmar.dart';
import 'servicios/acciones_fotos.dart';

// Fotos de una obra a pantalla completa, con zoom, nota y compartir.
class VisorFotosPagina extends StatefulWidget {
  const VisorFotosPagina({
    super.key,
    required this.proyectoId,
    this.inicial = 0,
  });

  final int proyectoId;
  final int inicial;

  @override
  State<VisorFotosPagina> createState() => _VisorFotosPaginaState();
}

class _VisorFotosPaginaState extends State<VisorFotosPagina> {
  late final _paginas = PageController(initialPage: widget.inicial);
  late int _actual = widget.inicial;

  @override
  void dispose() {
    _paginas.dispose();
    super.dispose();
  }

  Future<void> _editarNota(FotoObra foto) async {
    final cubit = context.read<CotiCubit>();
    final controlador = TextEditingController(text: foto.nota);
    final nota = await showDialog<String>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Nota de la foto'),
        content: TextField(
          controller: controlador,
          autofocus: true,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Ej.: Acabado final del baño',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexto),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(contexto, controlador.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    controlador.dispose();
    if (nota != null) await cubit.guardarNotaFoto(foto, nota);
  }

  Future<void> _eliminar(FotoObra foto, int total) async {
    final cubit = context.read<CotiCubit>();
    final navegador = Navigator.of(context);
    if (!await confirmarEliminacion(context, '¿Eliminar esta foto?')) return;
    if (await cubit.eliminarFoto(foto) && total == 1) navegador.pop();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<CotiCubit, EstadoCoti>(
    builder: (context, estado) {
      final fotos = estado.datos.fotosDeProyecto(widget.proyectoId);
      final proyecto = estado.datos.proyectos
          .where((p) => p.id == widget.proyectoId)
          .firstOrNull;
      if (fotos.isEmpty) {
        return const Scaffold(body: Center(child: Text('Sin fotos')));
      }
      final indice = _actual.clamp(0, fotos.length - 1);
      final foto = fotos[indice];
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text('${indice + 1} de ${fotos.length}'),
          actions: [
            IconButton(
              tooltip: 'Compartir foto',
              onPressed: () => compartirFotos([foto], proyecto),
              icon: const Icon(Icons.share_outlined),
            ),
            IconButton(
              tooltip: 'Editar nota',
              onPressed: () => _editarNota(foto),
              icon: const Icon(Icons.edit_note),
            ),
            IconButton(
              tooltip: 'Eliminar foto',
              onPressed: estado.guardando
                  ? null
                  : () => _eliminar(foto, fotos.length),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _paginas,
                itemCount: fotos.length,
                onPageChanged: (i) => setState(() => _actual = i),
                itemBuilder: (context, i) => InteractiveViewer(
                  maxScale: 5,
                  child: FutureBuilder<File>(
                    future: const AlmacenFotosObra().obtenerArchivo(
                      fotos[i].ruta,
                    ),
                    builder: (context, archivo) => archivo.hasData
                        ? Image.file(archivo.data!, fit: BoxFit.contain)
                        : const SizedBox.expand(),
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fechaHoraCorta(foto.fecha),
                      style: const TextStyle(color: Colors.white70),
                    ),
                    if (foto.nota.isNotEmpty)
                      Text(
                        foto.nota,
                        style: const TextStyle(color: Colors.white),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
