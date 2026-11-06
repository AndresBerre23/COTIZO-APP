import 'package:flutter_bloc/flutter_bloc.dart';
import '../dominio/modelos.dart';
import '../dominio/repositorio_local.dart';

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
  CotizoCubit(this._repositorio) : super(const EstadoCotizo(cargando: true));
  final RepositorioLocal _repositorio;

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

  Future<bool> guardarProyecto(Proyecto proyecto, List<ItemProyecto> items) =>
      _guardar(() async {
        await _repositorio.guardarProyecto(proyecto, items);
      });
  Future<bool> guardarMaterial(MaterialObra material) => _guardar(() async {
    await _repositorio.guardarMaterial(material);
  });
  Future<bool> guardarGasto(Gasto gasto) => _guardar(() async {
    await _repositorio.guardarGasto(gasto);
  });
  Future<bool> eliminarProyecto(int id) =>
      _guardar(() => _repositorio.eliminarProyecto(id));
  Future<bool> eliminarMaterial(int id) =>
      _guardar(() => _repositorio.eliminarMaterial(id));
  Future<bool> eliminarGasto(int id) =>
      _guardar(() => _repositorio.eliminarGasto(id));
}
