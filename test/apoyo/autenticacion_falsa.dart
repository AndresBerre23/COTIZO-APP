import 'package:coti/funcionalidades/seguridad/servicio_autenticacion.dart';

// Simula el sensor del teléfono en las pruebas.
class AutenticacionFalsa extends ServicioAutenticacion {
  AutenticacionFalsa({this.hayBloqueo = false, this.aceptar = true});

  final bool hayBloqueo;
  final bool aceptar;
  int intentos = 0;

  @override
  Future<bool> disponible() async => hayBloqueo;

  @override
  Future<bool> autenticar(String motivo) async {
    intentos++;
    return aceptar;
  }
}
