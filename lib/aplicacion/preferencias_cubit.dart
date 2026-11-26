import 'package:flutter_bloc/flutter_bloc.dart';

import '../dominio/preferencias_app.dart';
import '../dominio/repositorio_local.dart';

class PreferenciasCubit extends Cubit<PreferenciasApp> {
  PreferenciasCubit(
    this._repositorio, {
    PreferenciasApp inicial = const PreferenciasApp(),
  }) : super(inicial);

  final RepositorioLocal _repositorio;

  Future<void> guardar(PreferenciasApp preferencias) async {
    await _repositorio.guardarPreferencias(preferencias);
    if (!isClosed) emit(preferencias);
  }

  Future<void> cambiarTema(ModoTema modoTema) =>
      guardar(state.copyWith(modoTema: modoTema));

  Future<void> cambiarBloqueo(bool activo) =>
      guardar(state.copyWith(bloqueoActivo: activo));

  Future<void> marcarTutorialVisto() =>
      guardar(state.copyWith(tutorialVisto: true));

  Future<void> omitirAvisoNombre() =>
      guardar(state.copyWith(omitirAvisoNombre: true));
}
