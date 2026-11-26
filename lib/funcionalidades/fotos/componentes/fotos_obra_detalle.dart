import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../aplicacion/coti_cubit.dart';
import '../../../dominio/modelos.dart';
import '../../../widgets/ayuda/temas_ayuda.dart';
import '../../cotizaciones/componentes/seccion_cotizacion.dart';
import '../servicios/acciones_fotos.dart';
import 'cuadricula_fotos.dart';

// Fotos del avance y del resultado de una obra.
class FotosObraDetalle extends StatefulWidget {
  const FotosObraDetalle({
    super.key,
    required this.proyecto,
    required this.fotos,
  });

  final Proyecto proyecto;
  final List<FotoObra> fotos;

  @override
  State<FotosObraDetalle> createState() => _FotosObraDetalleState();
}

class _FotosObraDetalleState extends State<FotosObraDetalle> {
  bool _procesando = false;

  Future<void> _agregar(ImageSource origen) async {
    final cubit = context.read<CotiCubit>();
    final mensajero = ScaffoldMessenger.of(context);
    try {
      final originales = await elegirFotos(origen);
      if (originales.isEmpty) return;
      setState(() => _procesando = true);
      if (await cubit.agregarFotos(widget.proyecto.id, originales)) {
        mensajero.showSnackBar(
          SnackBar(
            content: Text(
              originales.length == 1
                  ? 'Foto guardada.'
                  : '${originales.length} fotos guardadas.',
            ),
          ),
        );
      }
    } catch (_) {
      mensajero.showSnackBar(
        const SnackBar(content: Text('No se pudieron cargar las fotos.')),
      );
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  @override
  Widget build(BuildContext context) => SeccionCotizacion(
    titulo: 'Fotos de la obra',
    ayuda: TemaAyuda.fotos,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.fotos.isEmpty)
          Text(
            'Guarda fotos del avance y del resultado para mostrar tu trabajo.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          )
        else
          CuadriculaFotos(proyectoId: widget.proyecto.id, fotos: widget.fotos),
        if (_procesando) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
          const SizedBox(height: 4),
          const Text('Optimizando fotos...'),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _procesando
                  ? null
                  : () => _agregar(ImageSource.camera),
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Tomar foto'),
            ),
            OutlinedButton.icon(
              onPressed: _procesando
                  ? null
                  : () => _agregar(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Desde galería'),
            ),
            if (widget.fotos.isNotEmpty)
              TextButton.icon(
                onPressed: () => compartirFotos(widget.fotos, widget.proyecto),
                icon: const Icon(Icons.share_outlined),
                label: const Text('Compartir todas'),
              ),
          ],
        ),
      ],
    ),
  );
}
