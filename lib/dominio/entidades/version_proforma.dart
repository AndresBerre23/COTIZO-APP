import 'gasto_previsto.dart';
import 'item_proyecto.dart';
import 'proyecto.dart';

// Copia de una proforma ya enviada antes de editarla (P-032).
class VersionProforma {
  const VersionProforma({
    this.id = 0,
    required this.proyectoId,
    required this.numero,
    required this.fecha,
    required this.proyecto,
    required this.items,
    required this.gastosPrevistos,
  });

  final int id;
  final int proyectoId;
  final int numero;
  final DateTime fecha;
  final Proyecto proyecto;
  final List<ItemProyecto> items;
  final List<GastoPrevisto> gastosPrevistos;
}
