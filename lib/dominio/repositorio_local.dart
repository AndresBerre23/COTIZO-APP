import 'modelos.dart';

abstract interface class RepositorioLocal {
  Future<DatosLocales> obtenerDatos();
  Future<PreferenciasApp> obtenerPreferencias();
  Future<void> guardarPreferencias(PreferenciasApp preferencias);
  Future<int> guardarProyecto(
    Proyecto proyecto,
    List<ItemProyecto> items, {
    List<GastoPrevisto>? gastosPrevistos,
  });
  Future<void> iniciarObra(int proyectoId, DateTime fechaInicioReal);
  Future<void> finalizarObra(int proyectoId, DateTime fechaFinReal);
  Future<int> guardarMaterial(MaterialObra material);
  Future<int> guardarGasto(Gasto gasto);
  Future<void> eliminarProyecto(int id);
  Future<void> eliminarMaterial(int id);
  Future<void> eliminarGasto(int id);
  Future<void> cerrar();
}
