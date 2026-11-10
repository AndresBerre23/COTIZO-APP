import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/imagenes/optimizar_imagen.dart';
import '../../../dominio/modelos.dart';
import '../busqueda_wikimedia/busqueda_wikimedia_pagina.dart';
import '../busqueda_wikimedia/imagen_wikimedia.dart';
import 'cambio_imagen_material.dart';
import 'imagen_material.dart';
import 'origen_imagen_material.dart';
import 'vista_previa_imagen_material.dart';

class SelectorImagenMaterial extends StatefulWidget {
  const SelectorImagenMaterial({
    super.key,
    required this.rutaExistente,
    required this.atribucionExistente,
    required this.leerConsulta,
    required this.alCambiar,
    required this.alProcesar,
  });

  final String? rutaExistente;
  final AtribucionImagenMaterial? atribucionExistente;
  final String Function() leerConsulta;
  final ValueChanged<CambioImagenMaterial> alCambiar;
  final ValueChanged<bool> alProcesar;

  @override
  State<SelectorImagenMaterial> createState() => _SelectorImagenMaterialState();
}

class _SelectorImagenMaterialState extends State<SelectorImagenMaterial> {
  final _selector = ImagePicker();
  Uint8List? _bytes;
  AtribucionImagenMaterial? _atribucionNueva;
  bool _quitar = false;
  bool _procesando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _recuperarImagenPerdida();
  }

  Future<void> _recuperarImagenPerdida() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final resultado = await _selector.retrieveLostData();
      if (resultado.isEmpty) return;
      if (resultado.exception != null) throw resultado.exception!;
      final archivos = resultado.files;
      if (archivos != null && archivos.isNotEmpty) {
        await _procesarArchivo(archivos.first);
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo recuperar la imagen.');
    }
  }

  Future<void> _elegir(ImageSource fuente) async {
    try {
      final archivo = await _selector.pickImage(
        source: fuente,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 90,
        requestFullMetadata: false,
      );
      if (archivo != null) await _procesarArchivo(archivo);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'No se pudo abrir la imagen elegida.');
      }
    }
  }

  Future<void> _procesarArchivo(XFile archivo) async =>
      _procesarBytes(await archivo.readAsBytes());

  Future<void> _procesarBytes(
    Uint8List originales, {
    AtribucionImagenMaterial? atribucion,
  }) async {
    if (!mounted) return;
    setState(() {
      _procesando = true;
      _error = null;
    });
    widget.alProcesar(true);
    try {
      final imagen = await optimizarImagen(originales);
      if (!mounted) return;
      setState(() {
        _bytes = imagen;
        _atribucionNueva = atribucion;
        _quitar = false;
        _procesando = false;
      });
      widget.alProcesar(false);
      widget.alCambiar(
        CambioImagenMaterial(bytes: imagen, atribucion: atribucion),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _procesando = false;
        _error = error is FormatException
            ? error.message
            : 'No se pudo procesar la imagen. Elige otra foto.';
      });
      widget.alProcesar(false);
    }
  }

  Future<void> _mostrarOpciones() async {
    final origen = await mostrarOpcionesOrigenImagen(context);
    if (!mounted || origen == null) return;
    if (origen == OrigenImagenMaterial.internet) {
      await _buscarEnInternet();
    } else {
      await _elegir(
        origen == OrigenImagenMaterial.galeria
            ? ImageSource.gallery
            : ImageSource.camera,
      );
    }
  }

  Future<void> _buscarEnInternet() async {
    final seleccion = await Navigator.of(context).push<ImagenWikimediaElegida>(
      MaterialPageRoute(
        builder: (_) =>
            BusquedaWikimediaPagina(consultaInicial: widget.leerConsulta()),
      ),
    );
    if (seleccion == null || !mounted) return;
    await _procesarBytes(seleccion.bytes, atribucion: seleccion.atribucion);
  }

  void _quitarImagen() {
    setState(() {
      _bytes = null;
      _atribucionNueva = null;
      _quitar = true;
    });
    widget.alCambiar(const CambioImagenMaterial(quitar: true));
  }

  void _verImagen() {
    final bytes = _bytes;
    mostrarVistaPreviaImagenMaterial(
      context,
      ruta: widget.rutaExistente,
      bytes: bytes,
      atribucion: bytes == null ? widget.atribucionExistente : _atribucionNueva,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tieneImagen =
        _bytes != null || (widget.rutaExistente != null && !_quitar);
    return Column(
      children: [
        Center(
          child: InkWell(
            onTap: tieneImagen ? _verImagen : null,
            borderRadius: BorderRadius.circular(12),
            child: _bytes == null
                ? ImagenMaterial(
                    ruta: _quitar ? null : widget.rutaExistente,
                    ancho: 112,
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _bytes!,
                      width: 112,
                      height: 112,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _procesando ? null : _mostrarOpciones,
          icon: const Icon(Icons.add_a_photo_outlined),
          label: Text(tieneImagen ? 'Cambiar imagen' : 'Agregar imagen'),
        ),
        if (tieneImagen)
          TextButton.icon(
            onPressed: _procesando ? null : _quitarImagen,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Quitar imagen'),
          ),
        if (_procesando)
          const Padding(
            padding: EdgeInsets.all(8),
            child: LinearProgressIndicator(),
          ),
        if (_error != null)
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    );
  }
}
