import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../aplicacion/preferencias_cubit.dart';
import '../../core/imagenes/optimizar_imagen.dart';
import '../../datos/almacen_foto_perfil.dart';
import '../../dominio/modelos.dart';
import '../../widgets/surface_card.dart';

class MiPerfilPagina extends StatefulWidget {
  const MiPerfilPagina({super.key});

  @override
  State<MiPerfilPagina> createState() => _MiPerfilPaginaState();
}

class _MiPerfilPaginaState extends State<MiPerfilPagina> {
  final _selector = ImagePicker();
  final _almacen = AlmacenFotoPerfil();
  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _apellido;
  Uint8List? _fotoTemporal;
  bool _quitarFoto = false;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final perfil = context.read<PreferenciasCubit>().state;
    _nombre = TextEditingController(text: perfil.nombre);
    _apellido = TextEditingController(text: perfil.apellido);
    _recuperarFotoPerdida();
  }

  @override
  void dispose() {
    _nombre.dispose();
    _apellido.dispose();
    super.dispose();
  }

  Future<void> _elegirFoto() async {
    final origen = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (origen == null || !mounted) return;
    try {
      final archivo = await _selector.pickImage(
        source: origen,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 90,
        requestFullMetadata: false,
      );
      if (archivo == null) return;
      final foto = await optimizarImagen(await archivo.readAsBytes());
      if (mounted) {
        setState(() {
          _fotoTemporal = foto;
          _quitarFoto = false;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo cargar la foto.');
    }
  }

  Future<void> _recuperarFotoPerdida() async {
    if (!Platform.isAndroid) return;
    try {
      final resultado = await _selector.retrieveLostData();
      if (resultado.isEmpty) return;
      if (resultado.exception != null) throw resultado.exception!;
      final archivos = resultado.files;
      if (archivos == null || archivos.isEmpty) return;
      final foto = await optimizarImagen(await archivos.first.readAsBytes());
      if (mounted) setState(() => _fotoTemporal = foto);
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo recuperar la foto.');
    }
  }

  Future<void> _guardarPerfil() async {
    if (_guardando || !(_formulario.currentState?.validate() ?? false)) return;
    setState(() {
      _guardando = true;
      _error = null;
    });
    final cubit = context.read<PreferenciasCubit>();
    final anterior = cubit.state;
    String? rutaNueva;
    try {
      if (_fotoTemporal != null) {
        rutaNueva = await _almacen.guardar(_fotoTemporal!);
      }
      final perfil = anterior.copyWith(
        nombre: _nombre.text.trim(),
        apellido: _apellido.text.trim(),
        fotoRuta: rutaNueva,
        quitarFoto: _quitarFoto,
      );
      await cubit.guardar(perfil);
      if (rutaNueva != null || _quitarFoto) {
        try {
          await _almacen.eliminar(anterior.fotoRuta);
        } catch (_) {}
      }
      if (mounted) Navigator.pop(context, perfil.tieneNombre);
    } catch (_) {
      if (rutaNueva != null) await _almacen.eliminar(rutaNueva);
      if (mounted) setState(() => _error = 'No se pudo guardar el perfil.');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Widget _mostrarFoto(PreferenciasApp perfil) {
    final foto = _fotoTemporal;
    if (foto != null) {
      return Image.memory(foto, width: 112, height: 112, fit: BoxFit.cover);
    }
    if (perfil.fotoRuta != null && !_quitarFoto) {
      return FutureBuilder<File>(
        future: _almacen.obtenerArchivo(perfil.fotoRuta!),
        builder: (context, resultado) => resultado.hasData
            ? Image.file(
                resultado.data!,
                width: 112,
                height: 112,
                fit: BoxFit.cover,
              )
            : _fotoVacia(context),
      );
    }
    return _fotoVacia(context);
  }

  Widget _fotoVacia(BuildContext context) => Center(
    child: Icon(
      Icons.person_outline,
      size: 48,
      color: Theme.of(context).colorScheme.onPrimaryContainer,
    ),
  );

  Future<void> _cambiarTema(ModoTema? modo) async {
    if (modo == null) return;
    try {
      await context.read<PreferenciasCubit>().cambiarTema(modo);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar el tema.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mi perfil')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SurfaceCard(
              child: Form(
                key: _formulario,
                child: Column(
                  children: [
                    ClipOval(
                      child: Container(
                        width: 112,
                        height: 112,
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: _mostrarFoto(
                          context.watch<PreferenciasCubit>().state,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _guardando ? null : _elegirFoto,
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: const Text('Agregar o cambiar foto'),
                    ),
                    if (context.watch<PreferenciasCubit>().state.fotoRuta !=
                            null ||
                        _fotoTemporal != null)
                      TextButton.icon(
                        onPressed: _guardando
                            ? null
                            : () => setState(() {
                                _fotoTemporal = null;
                                _quitarFoto = true;
                              }),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Quitar foto'),
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nombre,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _apellido,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Apellido'),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _guardando ? null : _guardarPerfil,
                      icon: const Icon(Icons.save_outlined),
                      label: Text(
                        _guardando ? 'Guardando...' : 'Guardar perfil',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SurfaceCard(
              child: BlocBuilder<PreferenciasCubit, PreferenciasApp>(
                builder: (context, preferencias) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Apariencia',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
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
                        DropdownMenuItem(
                          value: ModoTema.claro,
                          child: Text('Claro'),
                        ),
                        DropdownMenuItem(
                          value: ModoTema.oscuro,
                          child: Text('Oscuro'),
                        ),
                      ],
                      onChanged: _guardando ? null : _cambiarTema,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
