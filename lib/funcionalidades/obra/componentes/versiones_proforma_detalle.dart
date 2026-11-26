import 'package:flutter/material.dart';

import '../../../core/formato.dart';
import '../../../dominio/modelos.dart';
import '../../cotizaciones/componentes/seccion_cotizacion.dart';
import '../servicios/compartir_documentos_obra.dart';
import '../../../widgets/ayuda/temas_ayuda.dart';

// Proformas enviadas que luego se editaron (P-032).
class VersionesProformaDetalle extends StatelessWidget {
  const VersionesProformaDetalle({super.key, required this.versiones});

  // De la más reciente a la más antigua.
  final List<VersionProforma> versiones;

  @override
  Widget build(BuildContext context) => SeccionCotizacion(
    titulo: 'Versiones de la proforma',
    ayuda: TemaAyuda.versiones,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Vigente: versión ${versiones.length + 1}. Las anteriores se '
          'conservan tal como se enviaron.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        for (final version in versiones)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(child: Text('v${version.numero}')),
            title: Text(
              'Total ${dinero(version.proyecto.totalConIvaCentavos)}',
            ),
            subtitle: Text('Reemplazada el ${fechaHoraCorta(version.fecha)}'),
            trailing: IconButton(
              tooltip: 'Compartir versión ${version.numero}',
              onPressed: () => compartirVersion(context, version),
              icon: const Icon(Icons.picture_as_pdf_outlined),
            ),
          ),
      ],
    ),
  );
}
