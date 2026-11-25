import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../aplicacion/preferencias_cubit.dart';
import '../../../core/enfoque.dart';
import '../../../core/imagenes/optimizar_imagen.dart';
import '../../../datos/almacen_imagen_local.dart';
import '../../../dominio/modelos.dart';
import '../../../widgets/surface_card.dart';

// Datos del emisor que aparecen en la proforma (P-020).
class SeccionDatosNegocio extends StatefulWidget {
  const SeccionDatosNegocio({super.key});

  @override
  State<SeccionDatosNegocio> createState() => _SeccionDatosNegocioState();
}

class _SeccionDatosNegocioState extends State<SeccionDatosNegocio> {
  static const _almacen = AlmacenLogoNegocio();
  late final Map<String, TextEditingController> _campos;
  Uint8List? _logoNuevo;
  bool _quitarLogo = false;
  bool _guardando = false;

  static const _etiquetas = {
    'nombreComercial': 'Nombre comercial',
    'identificacion': 'RUC o cédula',
    'telefono': 'Teléfono',
    'correo': 'Correo',
    'direccion': 'Dirección',
  };

  @override
  void initState() {
    super.initState();
    final negocio = context.read<PreferenciasCubit>().state.negocio;
    final valores = {
      'nombreComercial': negocio.nombreComercial,
      'identificacion': negocio.identificacion,
      'telefono': negocio.telefono,
      'correo': negocio.correo,
      'direccion': negocio.direccion,
    };
    _campos = {
      for (final MapEntry(:key, :value) in valores.entries)
        key: TextEditingController(text: value),
    };
  }

  @override
  void dispose() {
    for (final campo in _campos.values) {
      campo.dispose();
    }
    super.dispose();
  }

  Future<void> _elegirLogo() async {
    try {
      final archivo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        requestFullMetadata: false,
      );
      if (archivo == null) return;
      final logo = await optimizarImagen(await archivo.readAsBytes());
      if (mounted) {
        setState(() {
          _logoNuevo = logo;
          _quitarLogo = false;
        });
      }
    } catch (_) {
      _avisar('No se pudo cargar el logo.');
    }
  }

  void _avisar(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _guardar() async {
    final cubit = context.read<PreferenciasCubit>();
    final anterior = cubit.state.negocio;
    setState(() => _guardando = true);
    String? rutaNueva;
    try {
      if (_logoNuevo != null) rutaNueva = await _almacen.guardar(_logoNuevo!);
      final negocio = anterior.copyWith(
        nombreComercial: _campos['nombreComercial']!.text.trim(),
        identificacion: _campos['identificacion']!.text.trim(),
        telefono: _campos['telefono']!.text.trim(),
        correo: _campos['correo']!.text.trim(),
        direccion: _campos['direccion']!.text.trim(),
        logoRuta: rutaNueva,
        quitarLogo: _quitarLogo,
      );
      await cubit.guardar(cubit.state.copyWith(negocio: negocio));
      if (rutaNueva != null || _quitarLogo) {
        try {
          await _almacen.eliminar(anterior.logoRuta);
        } catch (_) {}
      }
      setState(() {
        _logoNuevo = null;
        _quitarLogo = false;
      });
      _avisar('Datos del negocio guardados.');
    } catch (_) {
      if (rutaNueva != null) await _almacen.eliminar(rutaNueva);
      _avisar('No se pudieron guardar los datos del negocio.');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Widget _vistaLogo(DatosNegocio negocio) {
    final colores = Theme.of(context).colorScheme;
    Widget contenido = Icon(Icons.storefront_outlined, color: colores.primary);
    if (_logoNuevo != null) {
      contenido = Image.memory(_logoNuevo!, fit: BoxFit.cover);
    } else if (negocio.logoRuta != null && !_quitarLogo) {
      contenido = FutureBuilder<File>(
        future: _almacen.obtenerArchivo(negocio.logoRuta!),
        builder: (context, archivo) => archivo.hasData
            ? Image.file(archivo.data!, fit: BoxFit.cover)
            : const SizedBox.shrink(),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 72,
        height: 72,
        color: colores.primaryContainer,
        child: contenido,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final negocio = context.watch<PreferenciasCubit>().state.negocio;
    final tieneLogo =
        _logoNuevo != null || (negocio.logoRuta != null && !_quitarLogo);
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Datos del negocio',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Aparecen como emisor en tus proformas. Si no tienes nombre '
            'comercial, se usa tu nombre.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _vistaLogo(negocio),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _guardando ? null : _elegirLogo,
                      icon: const Icon(Icons.image_outlined),
                      label: Text(tieneLogo ? 'Cambiar logo' : 'Agregar logo'),
                    ),
                    if (tieneLogo)
                      TextButton(
                        onPressed: _guardando
                            ? null
                            : () => setState(() {
                                _logoNuevo = null;
                                _quitarLogo = true;
                              }),
                        child: const Text('Quitar'),
                      ),
                  ],
                ),
              ),
            ],
          ),
          for (final MapEntry(:key, :value) in _etiquetas.entries) ...[
            const SizedBox(height: 12),
            TextField(
              onTapOutside: cerrarFocoAlTocarFuera,
              controller: _campos[key],
              maxLength: 200,
              keyboardType: switch (key) {
                'telefono' => TextInputType.phone,
                'correo' => TextInputType.emailAddress,
                _ => TextInputType.text,
              },
              decoration: InputDecoration(labelText: value, counterText: ''),
            ),
          ],
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: _guardando ? null : _guardar,
              child: Text(_guardando ? 'Guardando...' : 'Guardar negocio'),
            ),
          ),
        ],
      ),
    );
  }
}
