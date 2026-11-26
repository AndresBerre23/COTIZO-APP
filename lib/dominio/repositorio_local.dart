import 'modelos.dart';

abstract interface class RepositorioLocal {
  Future<DatosLocales> obtenerDatos();
  Future<PreferenciasApp> obtenerPreferencias();
  Future<void> guardarPreferencias(PreferenciasApp preferencias);
  Future<int> guardarProyecto(
    Proyecto proyecto,
    List<ItemProyecto> items, {
    List<GastoPrevisto>? gastosPrevistos,
    Cliente? cliente,
  });
  Future<void> iniciarObra(int proyectoId, DateTime fechaInicioReal);
  Future<void> finalizarObra(int proyectoId, DateTime fechaFinReal);
  Future<int> guardarMaterial(MaterialObra material);
  Future<int> guardarGasto(Gasto gasto);
  Future<int> guardarIngreso(Ingreso ingreso);
  Future<void> eliminarProyecto(int id);
  Future<void> eliminarMaterial(int id);
  Future<void> eliminarGasto(int id);
  Future<void> eliminarIngreso(int id);
  Future<int> guardarCliente(Cliente cliente);
  Future<void> eliminarCliente(int id);
  Future<int> guardarAdicional(Adicional adicional);
  Future<void> eliminarAdicional(int id);
  Future<int> guardarFoto(FotoObra foto);
  Future<void> eliminarFoto(int id);
  // Deja todos los cambios en el archivo principal antes de copiarlo.
  Future<void> prepararRespaldo();
  Future<void> cerrar();
}
