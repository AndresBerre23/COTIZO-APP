import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/formato.dart';
import '../../../dominio/modelos.dart';
import '../../../dominio/opciones_iva.dart';
import '../../proformas/componentes/bloque_personas_pdf.dart';
import '../../proformas/componentes/diseno_documento_pdf.dart';
import '../../proformas/componentes/secciones_proforma_pdf.dart';
import '../../proformas/servicios/datos_emisor_pdf.dart';

// Orden de cambio en PDF para un adicional (P-031).
class ServicioPdfAdicional {
  Future<Uint8List> generar(
    Proyecto proyecto,
    Adicional adicional, {
    required int numero,
    required DatosEmisorPdf emisor,
    Cliente? cliente,
  }) async {
    final fuente = pw.Font.ttf(
      await rootBundle.load('assets/fuentes/Roboto-Regular.ttf'),
    );
    final negrita = pw.Font.ttf(
      await rootBundle.load('assets/fuentes/Roboto-Bold.ttf'),
    );
    final pw.ImageProvider logo = emisor.logo != null
        ? pw.MemoryImage(emisor.logo!)
        : await DisenoDocumentoPdf.cargarLogo();
    final azul = PdfColor.fromHex('#10144C');
    final codigo = '${codigoDocumento(proyecto.id)} · A$numero';
    final documento = pw.Document(
      title: 'Orden de cambio $codigo',
      author: emisor.nombre ?? 'Coti',
      theme: pw.ThemeData.withFont(base: fuente, bold: negrita),
    );
    documento.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (contexto) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            DisenoDocumentoPdf.encabezado(
              logo,
              false,
              proyecto.id,
              azul,
              PdfColor.fromHex('#4C36B8'),
              titulo: 'Orden de cambio',
              codigo: codigo,
            ),
            pw.SizedBox(height: 20),
            bloquePersonasPdf(
              emisor.nombre ?? 'Coti',
              proyecto.nombreCliente,
              azul,
              PdfColor.fromHex('#00796F'),
              detallesEmisor: detallesNegocio(emisor.negocio),
              detallesCliente: detallesCliente(cliente),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              'Adicional a la proforma ${codigoDocumento(proyecto.id)} '
              '(${proyecto.descripcion}), acordado el ${fechaCorta(adicional.fecha)}.',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.SizedBox(height: 16),
            DisenoDocumentoPdf.tituloSeccion('Trabajo adicional', azul),
            pw.SizedBox(height: 6),
            pw.Text(adicional.descripcion),
            pw.SizedBox(height: 16),
            DisenoDocumentoPdf.fila(
              'Subtotal',
              dinero(adicional.montoCentavos),
            ),
            if (proyecto.ivaPuntos != null)
              DisenoDocumentoPdf.fila(
                etiquetaIva(proyecto.ivaPuntos),
                dinero(proyecto.ivaDe(adicional.montoCentavos)),
              ),
            DisenoDocumentoPdf.panelTotal(
              'TOTAL DEL ADICIONAL',
              dinero(proyecto.conIva(adicional.montoCentavos)),
              azul,
            ),
            pw.Spacer(),
            pw.Text(
              'Documento de referencia. No constituye una factura ni un '
              'comprobante de pago.',
              style: const pw.TextStyle(fontSize: 8),
            ),
          ],
        ),
      ),
    );
    return documento.save();
  }
}
