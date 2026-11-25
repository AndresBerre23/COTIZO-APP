// Datos comunes de un gasto o un ingreso registrado.
abstract interface class Movimiento {
  int get id;
  int? get proyectoId;
  int get montoCentavos;
  String get categoria;
  DateTime get fecha;
  String get nota;
}
