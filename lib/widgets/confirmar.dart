import 'package:flutter/material.dart';

Future<bool> confirmarAccion(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  required String accion,
  String cancelar = 'Cancelar',
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexto, false),
            child: Text(cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(contexto, true),
            child: Text(accion),
          ),
        ],
      ),
    ) ??
    false;

Future<bool> confirmarEliminacion(BuildContext context, String mensaje) =>
    confirmarAccion(
      context,
      titulo: 'Confirmar eliminación',
      mensaje: mensaje,
      accion: 'Eliminar',
    );
