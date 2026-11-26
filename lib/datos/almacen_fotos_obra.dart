import 'dart:typed_data';

import '../core/imagenes/optimizar_imagen.dart';
import '../dominio/modelos.dart';
import 'almacen_imagen_local.dart';

// Optimiza y guarda las fotos de obra con su miniatura.
class AlmacenFotosObra extends AlmacenImagenLocal {
  const AlmacenFotosObra() : super('fotos_obra');

  Future<FotoObra> guardarFoto(int proyectoId, Uint8List original) async {
    final optimizada = await optimizarFotoObra(original);
    final ruta = await guardar(optimizada.foto);
    try {
      final miniatura = await guardar(optimizada.miniatura);
      return FotoObra(
        proyectoId: proyectoId,
        ruta: ruta,
        miniatura: miniatura,
        fecha: DateTime.now(),
      );
    } catch (_) {
      await eliminar(ruta);
      rethrow;
    }
  }

  Future<void> eliminarArchivos(FotoObra foto) async {
    try {
      await eliminar(foto.ruta);
      await eliminar(foto.miniatura);
    } catch (_) {}
  }
}
