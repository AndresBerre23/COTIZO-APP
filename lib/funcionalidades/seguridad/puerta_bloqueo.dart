import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/preferencias_cubit.dart';
import '../../dominio/modelos.dart';
import 'pantalla_bloqueo.dart';
import 'servicio_autenticacion.dart';

// Pide huella o clave al abrir la app y al volver tras un rato fuera (D-026).
class PuertaBloqueo extends StatefulWidget {
  const PuertaBloqueo({
    super.key,
    required this.child,
    this.servicio = const ServicioAutenticacion(),
  });

  final Widget child;
  final ServicioAutenticacion servicio;

  // Tiempo en segundo plano antes de volver a pedir el desbloqueo.
  static const tiempoGracia = Duration(minutes: 1);

  @override
  State<PuertaBloqueo> createState() => _PuertaBloqueoState();
}

class _PuertaBloqueoState extends State<PuertaBloqueo>
    with WidgetsBindingObserver {
  bool _desbloqueada = false;
  bool _autenticando = false;
  DateTime? _salida;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Activarlo dentro de la sesión no bloquea hasta salir de la app.
    _desbloqueada = !context.read<PreferenciasCubit>().state.bloqueoActivo;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    // El diálogo de huella también pausa la app; no cuenta como salida.
    if (_autenticando) return;
    if (estado == AppLifecycleState.paused) {
      _salida = DateTime.now();
    } else if (estado == AppLifecycleState.resumed && _salida != null) {
      final fuera = DateTime.now().difference(_salida!);
      _salida = null;
      if (fuera >= PuertaBloqueo.tiempoGracia) {
        setState(() => _desbloqueada = false);
      }
    }
  }

  Future<void> _desbloquear() async {
    if (_autenticando) return;
    setState(() => _autenticando = true);
    final valido = await widget.servicio.autenticar('Desbloquea Coti');
    if (!mounted) return;
    setState(() {
      _autenticando = false;
      _desbloqueada = valido;
    });
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<PreferenciasCubit, PreferenciasApp>(
        buildWhen: (anterior, actual) =>
            anterior.bloqueoActivo != actual.bloqueoActivo,
        builder: (context, preferencias) {
          if (!preferencias.bloqueoActivo || _desbloqueada) return widget.child;
          return PantallaBloqueo(
            autenticando: _autenticando,
            alDesbloquear: _desbloquear,
          );
        },
      );
}
