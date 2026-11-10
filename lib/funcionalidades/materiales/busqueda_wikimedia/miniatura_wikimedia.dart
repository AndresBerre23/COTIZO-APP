import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'imagen_wikimedia.dart';
import 'servicio_wikimedia.dart';

class MiniaturaWikimedia extends StatefulWidget {
  const MiniaturaWikimedia({
    super.key,
    required this.imagen,
    required this.servicio,
    this.ajuste = BoxFit.cover,
  });

  final ImagenWikimedia imagen;
  final ServicioWikimedia servicio;
  final BoxFit ajuste;

  @override
  State<MiniaturaWikimedia> createState() => _MiniaturaWikimediaState();
}

class _MiniaturaWikimediaState extends State<MiniaturaWikimedia> {
  late Future<Uint8List> _carga;

  @override
  void initState() {
    super.initState();
    _carga = widget.servicio.descargarMiniatura(widget.imagen.miniaturaUrl);
  }

  @override
  void didUpdateWidget(covariant MiniaturaWikimedia anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.imagen.miniaturaUrl != widget.imagen.miniaturaUrl) {
      _carga = widget.servicio.descargarMiniatura(widget.imagen.miniaturaUrl);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List>(
    future: _carga,
    builder: (context, estado) {
      if (estado.hasError) {
        return Center(
          child: IconButton(
            tooltip: 'No se pudo cargar. Toca para reintentar.',
            onPressed: () => setState(
              () => _carga = widget.servicio.descargarMiniatura(
                widget.imagen.miniaturaUrl,
              ),
            ),
            icon: const Icon(Icons.refresh, size: 36),
          ),
        );
      }
      if (!estado.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      return Image.memory(estado.data!, fit: widget.ajuste);
    },
  );
}
