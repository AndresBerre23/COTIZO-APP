import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../aplicacion/preferencias_cubit.dart';
import '../../../dominio/modelos.dart';
import '../../../widgets/surface_card.dart';
import '../../bienvenida/pantalla_bienvenida.dart';

// Preferencia de tema claro, oscuro o del sistema.
class SeccionApariencia extends StatelessWidget {
  const SeccionApariencia({super.key});

  Future<void> _cambiarTema(BuildContext context, ModoTema? modo) async {
    if (modo == null) return;
    try {
      await context.read<PreferenciasCubit>().cambiarTema(modo);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar el tema.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: BlocBuilder<PreferenciasCubit, PreferenciasApp>(
      builder: (context, preferencias) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Apariencia', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<ModoTema>(
            value: preferencias.modoTema,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Tema de la aplicación',
            ),
            items: const [
              DropdownMenuItem(
                value: ModoTema.sistema,
                child: Text('Seguir el dispositivo'),
              ),
              DropdownMenuItem(value: ModoTema.claro, child: Text('Claro')),
              DropdownMenuItem(value: ModoTema.oscuro, child: Text('Oscuro')),
            ],
            onChanged: (modo) => _cambiarTema(context, modo),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (contexto) => PantallaBienvenida(
                  alTerminar: (_) => Navigator.of(contexto).pop(),
                ),
              ),
            ),
            icon: const Icon(Icons.slideshow_outlined),
            label: const Text('Ver tutorial de bienvenida'),
          ),
        ],
      ),
    ),
  );
}
