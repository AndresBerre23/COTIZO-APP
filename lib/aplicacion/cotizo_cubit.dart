import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../datos/almacen_imagenes_materiales.dart';
import '../dominio/modelos.dart';
import '../dominio/repositorio_local.dart';
import 'edicion_material.dart';

class EstadoCotizo {
  const EstadoCotizo({
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

class CotizoCubit extends Cubit<EstadoCotizo> {
  CotizoCubit(this._repositorio, {AlmacenImagenesMateriales? almacenImagenes})
    : _almacenImagenes = almacenImagenes ?? AlmacenImagenesMateriales(),
      super(const EstadoCotizo(cargando: true));
  final RepositorioLocal _repositorio;
  final AlmacenImagenesMateriales _almacenImagenes;

  Future<void> cargar() async {
    emit(EstadoCotizo(datos: state.datos, cargando: true));
    try {
      final datos = await _repositorio.obtenerDatos();
      if (!isClosed) emit(EstadoCotizo(datos: datos));
    } catch (_) {
      if (!isClosed) {
        emit(
          EstadoCotizo(
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
    emit(EstadoCotizo(datos: state.datos, guardando: true));
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
      if (!isClosed) emit(EstadoCotizo(datos: state.datos, error: mensaje));
      return false;
    }
    try {
      final datos = await _repositorio.obtenerDatos();
      if (!isClosed) emit(EstadoCotizo(datos: datos));
    } catch (_) {
      if (!isClosed) {
        emit(
          EstadoCotizo(
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
  Future<bool> eliminarProyecto(int id) =>
      _guardar(() => _repositorio.eliminarProyecto(id));
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
