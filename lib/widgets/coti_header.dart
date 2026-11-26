import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../aplicacion/preferencias_cubit.dart';
import '../datos/almacen_foto_perfil.dart';
import '../dominio/modelos.dart';
import '../funcionalidades/perfil/mi_perfil_pagina.dart';
import 'ayuda/boton_ayuda.dart';
import 'ayuda/temas_ayuda.dart';

class CotiHeader extends StatelessWidget {
  const CotiHeader({super.key, required this.title, this.ayuda});

  final String title;
  final TemaAyuda? ayuda;

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/CotiIcono.png',
              width: 40,
              height: 40,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COTI',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (ayuda != null) BotonAyuda(tema: ayuda!),
          BlocBuilder<PreferenciasCubit, PreferenciasApp>(
            builder: (context, preferencias) => IconButton(
              tooltip: 'Mi perfil',
              onPressed: () => Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const MiPerfilPagina()),
              ),
              icon: _avatar(preferencias),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _avatar(PreferenciasApp preferencias) {
    final color = const Color(0xFF10144C);
    final iniciales = [preferencias.nombre, preferencias.apellido]
        .where((parte) => parte.trim().isNotEmpty)
        .map((parte) => parte.trim().substring(0, 1).toUpperCase())
        .join();
    final ruta = preferencias.fotoRuta;
    if (ruta == null) {
      return CircleAvatar(
        backgroundColor: color,
        child: iniciales.isEmpty
            ? const Icon(Icons.person_outline, color: Colors.white)
            : Text(
                iniciales,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
      );
    }
    return FutureBuilder<File>(
      future: AlmacenFotoPerfil().obtenerArchivo(ruta),
      builder: (context, resultado) => CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: resultado.hasData
            ? ClipOval(
                child: Image.file(
                  resultado.data!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(Icons.person_outline),
      ),
    );
  }
}
