import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/preferencias_cubit.dart';
import '../../dominio/modelos.dart';
import '../perfil/mi_perfil_pagina.dart';
import '../seguridad/pantalla_proteccion.dart';
import '../seguridad/servicio_autenticacion.dart';
import 'pantalla_bienvenida.dart';

// Muestra el tutorial y luego ofrece el bloqueo, hasta completarlos.
class PuertaBienvenida extends StatefulWidget {
  const PuertaBienvenida({
    super.key,
    required this.child,
    this.servicio = const ServicioAutenticacion(),
  });

  final Widget child;
  final ServicioAutenticacion servicio;

  @override
  State<PuertaBienvenida> createState() => _PuertaBienvenidaState();
}

class _PuertaBienvenidaState extends State<PuertaBienvenida> {
  bool _preguntarBloqueo = false;
  bool _configurarNegocio = false;

  Future<void> _terminarTutorial(bool configurarNegocio) async {
    _configurarNegocio = configurarNegocio;
    // Solo se ofrece si el teléfono tiene huella, PIN o patrón.
    if (await widget.servicio.disponible()) {
      if (mounted) setState(() => _preguntarBloqueo = true);
    } else {
      await _finalizar();
    }
  }

  Future<void> _decidirBloqueo(bool activar) async {
    final cubit = context.read<PreferenciasCubit>();
    if (activar &&
        await widget.servicio.autenticar('Confirma para activar el bloqueo')) {
      await cubit.cambiarBloqueo(true);
    }
    await _finalizar();
  }

  Future<void> _finalizar() async {
    final navegador = Navigator.of(context);
    await context.read<PreferenciasCubit>().marcarTutorialVisto();
    if (_configurarNegocio) {
      await navegador.push(
        MaterialPageRoute<void>(builder: (_) => const MiPerfilPagina()),
      );
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<PreferenciasCubit, PreferenciasApp>(
        buildWhen: (anterior, actual) =>
            anterior.tutorialVisto != actual.tutorialVisto,
        builder: (context, preferencias) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: preferencias.tutorialVisto
              ? widget.child
              : _preguntarBloqueo
              ? PantallaProteccion(alDecidir: _decidirBloqueo)
              : PantallaBienvenida(alTerminar: _terminarTutorial),
        ),
      );
}
