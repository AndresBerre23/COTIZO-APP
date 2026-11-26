import 'package:local_auth/local_auth.dart';

// Usa el bloqueo del teléfono (huella, rostro, PIN o patrón); Coti no guarda claves.
class ServicioAutenticacion {
  const ServicioAutenticacion();

  static final _autenticacion = LocalAuthentication();

  // Falso si el teléfono no tiene bloqueo de pantalla o no lo permite.
  Future<bool> disponible() async {
    try {
      return await _autenticacion.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> autenticar(String motivo) async {
    try {
      return await _autenticacion.authenticate(
        localizedReason: motivo,
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } catch (_) {
      return false;
    }
  }
}
