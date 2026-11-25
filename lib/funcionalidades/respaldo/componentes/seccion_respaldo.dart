import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../aplicacion/control_datos_app.dart';
import '../../../core/formato.dart';
import '../../../widgets/confirmar.dart';
import '../../../widgets/surface_card.dart';
import '../servicios/formato_respaldo.dart';
import '../servicios/servicio_respaldo.dart';

// Tarjeta de Mi perfil para crear y restaurar respaldos (P-007).
class SeccionRespaldo extends StatefulWidget {
  const SeccionRespaldo({super.key});

  @override
  State<SeccionRespaldo> createState() => _SeccionRespaldoState();
}

class _SeccionRespaldoState extends State<SeccionRespaldo> {
  bool _ocupado = false;

  void _avisar(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _crear() async {
    final control = ControlDatosApp.of(context);
    setState(() => _ocupado = true);
    try {
      await control.prepararRespaldo();
      final servicio = await ServicioRespaldo.predeterminado();
      final archivo = await servicio.crear(await getTemporaryDirectory());
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(archivo.path, mimeType: 'application/zip')],
          subject: 'Respaldo de Coti',
        ),
      );
    } catch (_) {
      _avisar('No se pudo crear el respaldo. Inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _restaurar() async {
    final control = ControlDatosApp.of(context);
    setState(() => _ocupado = true);
    try {
      final seleccion = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['zip'],
        withData: true,
      );
      final Uint8List? bytes = seleccion?.files.single.bytes;
      if (bytes == null) return;
      final servicio = await ServicioRespaldo.predeterminado();
      final contenido = servicio.leer(bytes);
      if (!mounted || !await _confirmar(contenido)) return;
      await control.reemplazarDatos(() => servicio.restaurar(contenido));
    } on FormatException catch (error) {
      _avisar(error.message);
    } catch (_) {
      _avisar('No se pudo leer el archivo seleccionado.');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<bool> _confirmar(ContenidoRespaldo contenido) => confirmarAccion(
    context,
    titulo: 'Restaurar respaldo',
    mensaje:
        'Tus datos actuales se reemplazarán por los del respaldo del '
        '${fechaHoraCorta(contenido.creado)} '
        '(${contenido.totalImagenes} imágenes). '
        'Antes se guarda una copia interna de los datos actuales.',
    accion: 'Restaurar',
  );

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.backup_outlined, color: colores.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Respaldo de datos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tus datos viven solo en este teléfono. Crea un archivo .zip con '
            'cotizaciones, gastos, materiales e imágenes y guárdalo en tu '
            'correo o en la nube para no perderlos.',
            style: TextStyle(color: colores.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          if (_ocupado) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 16),
          ],
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: _ocupado ? null : _crear,
                icon: const Icon(Icons.archive_outlined),
                label: const Text('Crear respaldo'),
              ),
              OutlinedButton.icon(
                onPressed: _ocupado ? null : _restaurar,
                icon: const Icon(Icons.settings_backup_restore),
                label: const Text('Restaurar respaldo'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
