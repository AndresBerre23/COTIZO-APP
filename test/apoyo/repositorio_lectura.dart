import 'package:cotizo_app/dominio/modelos.dart';
import 'package:cotizo_app/dominio/repositorio_local.dart';
import 'package:cotizo_app/dominio/preferencias_app.dart';

class RepositorioLectura implements RepositorioLocal {
  RepositorioLectura(this.datos);
  DatosLocales datos;
  PreferenciasApp preferencias = const PreferenciasApp();
  bool fallarLectura = false;
  int escrituras = 0;
  @override
  Future<DatosLocales> obtenerDatos() async {
    if (fallarLectura) throw StateError('Lectura fallida');
    return datos;
  }

  @override
  Future<PreferenciasApp> obtenerPreferencias() async => preferencias;

  @override
  Future<void> guardarPreferencias(PreferenciasApp preferencias) async {
    this.preferencias = preferencias;
  }

  @override
  Future<int> guardarMaterial(MaterialObra material) async {
    escrituras++;
    return 1;
  }

  @override
  Future<int> guardarProyecto(
    Proyecto proyecto,
    List<ItemProyecto> items, {
    List<GastoPrevisto>? gastosPrevistos,
  }) async => 1;
  @override
  Future<void> iniciarObra(int proyectoId, DateTime fechaInicioReal) async {}
  @override
  Future<void> finalizarObra(int proyectoId, DateTime fechaFinReal) async {}
  @override
  Future<int> guardarGasto(Gasto gasto) async => 1;
  @override
  Future<void> eliminarProyecto(int id) async {}
  @override
  Future<void> eliminarMaterial(int id) async {}
  @override
  Future<void> eliminarGasto(int id) async {}
  @override
  Future<void> cerrar() async {}
}

DatosLocales datosMuestra() => DatosLocales(
  proyectos: [
    Proyecto(
      id: 1,
      nombreCliente: 'María Gómez',
      descripcion: 'Remodelación de cocina',
      fechaInicio: DateTime(2026, 11, 5),
      fechaFin: DateTime(2026, 11, 15),
      estado: EstadoProyecto.aprobado,
      totalCotizadoCentavos: 180000,
    ),
  ],
  materiales: const [
    MaterialObra(
      id: 1,
      nombre: 'Porcelanato gris 60 × 60',
      unidadMedida: 'm²',
      costoBaseCentavos: 2250,
    ),
  ],
  items: const [
    ItemProyecto(
      id: 1,
      proyectoId: 1,
      materialId: 1,
      cantidad: 18,
      costoUnitarioAplicadoCentavos: 2250,
      nombreMaterial: 'Porcelanato gris 60 × 60',
      unidadMedida: 'm²',
    ),
  ],
  gastos: [
    Gasto(
      id: 1,
      proyectoId: 1,
      montoCentavos: 3500,
      categoria: 'Transporte',
      fecha: DateTime(2026, 11, 5),
      nota: 'Entrega de materiales',
    ),
    Gasto(
      id: 2,
      montoCentavos: 1200,
      categoria: 'Herramientas',
      fecha: DateTime(2026, 11, 5),
    ),
  ],
);
