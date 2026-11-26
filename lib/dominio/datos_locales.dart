import 'entidades/adicional.dart';
import 'entidades/cliente.dart';
import 'entidades/foto_obra.dart';
import 'entidades/gasto.dart';
import 'entidades/gasto_previsto.dart';
import 'entidades/ingreso.dart';
import 'entidades/item_proyecto.dart';
import 'entidades/material_obra.dart';
import 'entidades/proyecto.dart';
import 'entidades/version_proforma.dart';

class DatosLocales {
  const DatosLocales({
    this.proyectos = const [],
    this.materiales = const [],
    this.items = const [],
    this.gastos = const [],
    this.gastosPrevistos = const [],
    this.ingresos = const [],
    this.clientes = const [],
    this.adicionales = const [],
    this.versiones = const [],
    this.fotos = const [],
  });

  final List<Proyecto> proyectos;
  final List<MaterialObra> materiales;
  final List<ItemProyecto> items;
  final List<Gasto> gastos;
  final List<GastoPrevisto> gastosPrevistos;
  final List<Ingreso> ingresos;
  final List<Cliente> clientes;
  final List<Adicional> adicionales;
  final List<VersionProforma> versiones;
  final List<FotoObra> fotos;

  // De la más reciente a la más antigua.
  List<FotoObra> fotosDeProyecto(int proyectoId) =>
      fotos.where((f) => f.proyectoId == proyectoId).toList()
        ..sort((a, b) => b.fecha.compareTo(a.fecha));

  // Un proyecto con dinero registrado se cancela en lugar de eliminarse (D-025).
  bool tieneMovimientos(int proyectoId) =>
      gastos.any((g) => g.proyectoId == proyectoId) ||
      ingresos.any((i) => i.proyectoId == proyectoId);

  List<Adicional> adicionalesDeProyecto(int proyectoId) =>
      adicionales.where((a) => a.proyectoId == proyectoId).toList();

  // Ordenadas de la más reciente a la más antigua.
  List<VersionProforma> versionesDeProyecto(int proyectoId) =>
      versiones.where((v) => v.proyectoId == proyectoId).toList()
        ..sort((a, b) => b.numero.compareTo(a.numero));

  Cliente? clientePorId(int? id) {
    for (final cliente in clientes) {
      if (cliente.id == id) return cliente;
    }
    return null;
  }

  List<ItemProyecto> itemsDeProyecto(int proyectoId) =>
      items.where((item) => item.proyectoId == proyectoId).toList();

  List<Gasto> gastosDeProyecto(int proyectoId) =>
      gastos.where((gasto) => gasto.proyectoId == proyectoId).toList();

  List<Ingreso> ingresosDeProyecto(int proyectoId) =>
      ingresos.where((ingreso) => ingreso.proyectoId == proyectoId).toList();

  List<GastoPrevisto> gastosPrevistosDeProyecto(int proyectoId) =>
      gastosPrevistos.where((gasto) => gasto.proyectoId == proyectoId).toList();
}
