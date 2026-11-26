import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/preferencias_cubit.dart';
import '../../widgets/ayuda/boton_ayuda.dart';
import '../../widgets/ayuda/temas_ayuda.dart';
import '../../widgets/surface_card.dart';
import 'servicio_autenticacion.dart';

// Tarjeta de Mi perfil para activar o quitar el bloqueo de la app.
class SeccionSeguridad extends StatefulWidget {
  const SeccionSeguridad({
    super.key,
    this.servicio = const ServicioAutenticacion(),
  });

  final ServicioAutenticacion servicio;

  @override
  State<SeccionSeguridad> createState() => _SeccionSeguridadState();
}

class _SeccionSeguridadState extends State<SeccionSeguridad> {
  late final Future<bool> _disponible = widget.servicio.disponible();

  // Cambiarlo en cualquier sentido exige confirmar con huella o clave.
  Future<void> _cambiar(bool activar) async {
    final cubit = context.read<PreferenciasCubit>();
    final mensajero = ScaffoldMessenger.of(context);
    final valido = await widget.servicio.autenticar(
      activar
          ? 'Confirma para activar el bloqueo'
          : 'Confirma para quitar el bloqueo',
    );
    if (!valido) return;
    await cubit.cambiarBloqueo(activar);
    mensajero.showSnackBar(
      SnackBar(
        content: Text(activar ? 'Bloqueo activado.' : 'Bloqueo desactivado.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: FutureBuilder<bool>(
      future: _disponible,
      builder: (context, disponible) {
        final puede = disponible.data ?? false;
        final activo = context.watch<PreferenciasCubit>().state.bloqueoActivo;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Seguridad',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const BotonAyuda(tema: TemaAyuda.seguridad),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.fingerprint),
              title: const Text('Pedir huella o clave al abrir Coti'),
              subtitle: Text(
                puede
                    ? 'Usa el bloqueo de tu teléfono; Coti no guarda claves.'
                    : 'Configura un bloqueo de pantalla en tu teléfono para usarlo.',
              ),
              value: activo,
              onChanged: puede || activo ? _cambiar : null,
            ),
          ],
        );
      },
    ),
  );
}
