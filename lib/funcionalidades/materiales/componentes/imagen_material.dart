import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../datos/almacen_imagenes_materiales.dart';

class ImagenMaterial extends StatefulWidget {
  const ImagenMaterial({super.key, required this.ruta, this.ancho = 64});

  final String? ruta;
  final double ancho;

  @override
  State<ImagenMaterial> createState() => _ImagenMaterialState();
}

class _ImagenMaterialState extends State<ImagenMaterial> {
  late Future<File?> _archivo;

  @override
  void initState() {
    super.initState();
    _archivo = _obtenerArchivo(widget.ruta);
  }

  @override
  void didUpdateWidget(covariant ImagenMaterial anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.ruta != widget.ruta) {
      _archivo = _obtenerArchivo(widget.ruta);
    }
  }

  Future<File?> _obtenerArchivo(String? ruta) async {
    if (ruta == null) return null;
    try {
      return await AlmacenImagenesMateriales().obtenerArchivo(ruta);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: _archivo,
      builder: (context, estado) {
        if (!estado.hasData) return _marcador();
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            estado.data!,
            width: widget.ancho,
            height: widget.ancho,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _marcador(),
          ),
        );
      },
    );
  }

  Widget _marcador() => SizedBox(
    width: widget.ancho,
    height: widget.ancho,
    child: const CircleAvatar(
      backgroundColor: AppColors.softBlue,
      child: Icon(Icons.inventory_2_outlined, color: AppColors.cobalt),
    ),
  );
}
