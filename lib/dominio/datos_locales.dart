import 'entidades/gasto.dart';
import 'entidades/gasto_previsto.dart';
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
  });

  final List<Proyecto> proyectos;
  final List<MaterialObra> materiales;
  final List<ItemProyecto> items;
  final List<Gasto> gastos;
  final List<GastoPrevisto> gastosPrevistos;

  List<ItemProyecto> itemsDeProyecto(int proyectoId) =>
      items.where((item) => item.proyectoId == proyectoId).toList();

  List<Gasto> gastosDeProyecto(int proyectoId) =>
      gastos.where((gasto) => gasto.proyectoId == proyectoId).toList();

  List<GastoPrevisto> gastosPrevistosDeProyecto(int proyectoId) =>
      gastosPrevistos.where((gasto) => gasto.proyectoId == proyectoId).toList();
}
