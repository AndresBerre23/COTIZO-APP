import 'entidades/cliente.dart';
import 'entidades/gasto.dart';
import 'entidades/gasto_previsto.dart';
import 'entidades/ingreso.dart';
import 'entidades/item_proyecto.dart';
import 'entidades/material_obra.dart';
import 'entidades/proyecto.dart';

class DatosLocales {
  const DatosLocales({
    this.proyectos = const [],
    this.materiales = const [],
    this.items = const [],
    this.gastos = const [],
    this.gastosPrevistos = const [],
    this.ingresos = const [],
    this.clientes = const [],
  });

  final List<Proyecto> proyectos;
  final List<MaterialObra> materiales;
  final List<ItemProyecto> items;
  final List<Gasto> gastos;
  final List<GastoPrevisto> gastosPrevistos;
  final List<Ingreso> ingresos;
  final List<Cliente> clientes;

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
