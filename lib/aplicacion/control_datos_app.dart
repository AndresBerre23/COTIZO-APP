import 'package:flutter/widgets.dart';

// Operaciones que necesitan acceso directo al almacenamiento local.
class ControlDatosApp extends InheritedWidget {
  const ControlDatosApp({
    super.key,
    required this.prepararRespaldo,
    required this.reemplazarDatos,
    required super.child,
  });

  final Future<void> Function() prepararRespaldo;

  // Cierra la base, ejecuta la tarea y vuelve a abrir la app.
  final Future<void> Function(Future<void> Function() tarea) reemplazarDatos;

  static ControlDatosApp of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<ControlDatosApp>()!;

  @override
  bool updateShouldNotify(ControlDatosApp anterior) => false;
}
