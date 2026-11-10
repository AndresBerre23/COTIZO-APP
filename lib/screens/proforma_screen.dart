import 'package:flutter/material.dart';

import '../funcionalidades/proformas/archivo_documentos_page.dart';
import '../funcionalidades/proformas/proforma_documento_page.dart';

class ProformaPage extends StatelessWidget {
  const ProformaPage({super.key, this.proyectoId});

  final int? proyectoId;

  @override
  Widget build(BuildContext context) => proyectoId == null
      ? const ArchivoDocumentosPage()
      : ProformaDocumentoPage(proyectoId: proyectoId!);
}
