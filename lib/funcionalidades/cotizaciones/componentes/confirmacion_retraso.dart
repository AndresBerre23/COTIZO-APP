import 'package:flutter/material.dart';

import '../../../dominio/modelos.dart';

class ConfirmacionRetraso extends StatefulWidget {
  const ConfirmacionRetraso({
    super.key,
    required this.proyecto,
    required this.alFinalizar,
  });

  final Proyecto proyecto;
  final Future<void> Function(DateTime fecha) alFinalizar;

  @override
  State<ConfirmacionRetraso> createState() => _ConfirmacionRetrasoState();
}

class _ConfirmacionRetrasoState extends State<ConfirmacionRetraso> {
  bool _mostrada = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_mostrada || !widget.proyecto.estaRetrasada(DateTime.now())) return;
    _mostrada = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _mostrar());
  }

  Future<void> _mostrar() async {
    if (!mounted) return;
    final finalizar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('La fecha prevista terminó'),
        content: const Text('¿La obra ya finalizó?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Aún no termino'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Finalizar obra'),
          ),
        ],
      ),
    );
    if (finalizar == true && mounted) {
      final ahora = DateTime.now();
      await widget.alFinalizar(DateTime(ahora.year, ahora.month, ahora.day));
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
