import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../datos/almacen_fotos_obra.dart';
import '../datos/almacen_imagenes_materiales.dart';
import '../dominio/modelos.dart';
import '../dominio/repositorio_local.dart';
import 'edicion_material.dart';

class EstadoCoti {
  const EstadoCoti({
    this.datos = const DatosLocales(),
    this.cargando = false,
    this.guardando = false,
    this.falloCarga = false,
    this.error,
  });
  final DatosLocales datos;
  final bool cargando, guardando, falloCarga;
  final String? error;
}

class CotiCubit extends Cubit<EstadoCoti> {
  CotiCubit(
    this._repositorio, {
    AlmacenImagenesMateriales? almacenImagenes,
    AlmacenFotosObra almacenFotos = const AlmacenFotosObra(),
  }) : _almacenImagenes = almacenImagenes ?? AlmacenImagenesMateriales(),
       _almacenFotos = almacenFotos,
       super(const EstadoCoti(cargando: true));
  final RepositorioLocal _repositorio;
  final AlmacenImagenesMateriales _almacenImagenes;
  final AlmacenFotosObra _almacenFotos;

  Future<void> cargar() async {
    emit(EstadoCoti(datos: state.datos, cargando: true));
    try {
      final datos = await _repositorio.obtenerDatos();
      if (!isClosed) emit(EstadoCoti(datos: datos));
    } catch (_) {
      if (!isClosed) {
        emit(
          EstadoCoti(
            datos: state.datos,
            falloCarga: true,
            error: 'No se pudieron leer los datos locales. Intenta nuevamente.',
          ),
        );
      }
    }
  }

  Future<bool> _guardar(Future<void> Function() operacion) async {
    if (state.guardando || state.cargando || state.falloCarga) return false;
    emit(EstadoCoti(datos: state.datos, guardando: true));
    try {
      await operacion();
    } catch (error) {
      final mensaje = error is FormatException
          ? error.message
          : error is ArgumentError
          ? '${error.message}'
          : error is StateError
          ? error.message
          : 'No se pudo guardar el cambio. Tus datos anteriores se conservan.';
      if (!isClosed) emit(EstadoCoti(datos: state.datos, error: mensaje));
      return false;
    }
    try {
      final datos = await _repositorio.obtenerDatos();
      if (!isClosed) emit(EstadoCoti(datos: datos));
    } catch (_) {
      if (!isClosed) {
        emit(
          EstadoCoti(
            datos: state.datos,
            falloCarga: true,
            error:
                'El cambio se guardó. Vuelve a cargar los datos para actualizar la vista.',
          ),
        );
      }
    }
    return true;
  }

  Future<bool> guardarProyecto(
    Proyecto proyecto,
    List<ItemProyecto> items, {
    List<GastoPrevisto>? gastosPrevistos,
    Cliente? cliente,
  }) => _guardar(() async {
    await _repositorio.guardarProyecto(
      proyecto,
      items,
      gastosPrevistos: gastosPrevistos,
      cliente: cliente,
    );
  });
  Future<bool> guardarCliente(Cliente cliente) =>
      _guardar(() => _repositorio.guardarCliente(cliente));
  Future<bool> eliminarCliente(int id) =>
      _guardar(() => _repositorio.eliminarCliente(id));
  Future<bool> iniciarObra(int proyectoId, DateTime fechaInicioReal) =>
      _guardar(() => _repositorio.iniciarObra(proyectoId, fechaInicioReal));
  Future<bool> finalizarObra(int proyectoId, DateTime fechaFinReal) =>
      _guardar(() => _repositorio.finalizarObra(proyectoId, fechaFinReal));
  Future<bool> guardarMaterial(EdicionMaterial edicion) => _guardar(() async {
    final original = edicion.material;
    final anterior = original.id == 0 ? null : _materialPorId(original.id);
    String? rutaNueva;
    var imagenGuardada = false;
    var material = original;
    try {
      final Uint8List? bytes = edicion.imagenNueva;
      if (bytes != null) {
        rutaNueva = await _almacenImagenes.guardar(bytes);
        imagenGuardada = true;
        material = original.conImagen(
          rutaNueva,
          atribucion: edicion.atribucionNueva,
        );
      } else if (edicion.quitarImagen) {
        material = original.conImagen(null);
      }
      await _repositorio.guardarMaterial(material);
    } catch (_) {
      if (imagenGuardada) await _almacenImagenes.eliminar(rutaNueva);
      rethrow;
    }
    if (anterior?.imagenRuta != material.imagenRuta) {
      try {
        await _almacenImagenes.eliminar(anterior?.imagenRuta);
      } catch (_) {}
    }
  });
  Future<bool> guardarGasto(Gasto gasto) => _guardar(() async {
    await _repositorio.guardarGasto(gasto);
  });
  Future<bool> guardarIngreso(Ingreso ingreso) =>
      _guardar(() => _repositorio.guardarIngreso(ingreso));
  Future<bool> eliminarIngreso(int id) =>
      _guardar(() => _repositorio.eliminarIngreso(id));
  Future<bool> guardarAdicional(Adicional adicional) =>
      _guardar(() => _repositorio.guardarAdicional(adicional));
  Future<bool> eliminarAdicional(int id) =>
      _guardar(() => _repositorio.eliminarAdicional(id));
  // Sus fotos se borran con el proyecto; también sus archivos.
  Future<bool> eliminarProyecto(int id) => _guardar(() async {
    final fotos = state.datos.fotosDeProyecto(id);
    await _repositorio.eliminarProyecto(id);
    for (final foto in fotos) {
      await _almacenFotos.eliminarArchivos(foto);
    }
  });

  // Optimiza y guarda varias fotos; si una falla, se conservan las anteriores.
  Future<bool> agregarFotos(int proyectoId, List<Uint8List> originales) =>
      _guardar(() async {
        for (final original in originales) {
          final foto = await _almacenFotos.guardarFoto(proyectoId, original);
          try {
            await _repositorio.guardarFoto(foto);
          } catch (_) {
            await _almacenFotos.eliminarArchivos(foto);
            rethrow;
          }
        }
      });
  Future<bool> guardarNotaFoto(FotoObra foto, String nota) =>
      _guardar(() => _repositorio.guardarFoto(foto.conNota(nota)));
  Future<bool> eliminarFoto(FotoObra foto) => _guardar(() async {
    await _repositorio.eliminarFoto(foto.id);
    await _almacenFotos.eliminarArchivos(foto);
  });
  Future<bool> eliminarMaterial(int id) => _guardar(() async {
    final rutaImagen = _materialPorId(id)?.imagenRuta;
    await _repositorio.eliminarMaterial(id);
    try {
      await _almacenImagenes.eliminar(rutaImagen);
    } catch (_) {}
  });
  Future<bool> eliminarGasto(int id) =>
      _guardar(() => _repositorio.eliminarGasto(id));

  MaterialObra? _materialPorId(int id) {
    for (final material in state.datos.materiales) {
      if (material.id == id) return material;
    }
    return null;
  }
}
