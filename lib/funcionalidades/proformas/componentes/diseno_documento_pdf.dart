import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import '../../../core/formato.dart';

class DisenoDocumentoPdf {
  static Future<pw.MemoryImage> cargarLogo() async {
    final datos = await rootBundle.load('assets/images/CotiIcono.png');
    return pw.MemoryImage(
      datos.buffer.asUint8List(datos.offsetInBytes, datos.lengthInBytes),
    );
  }

  // El aviso legal va en el pie para no ocupar una página extra.
  static pw.Widget piePagina(
    bool esCierre,
    int numeroPagina,
    int paginas,
  ) => pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    children: [
      pw.Expanded(
        child: pw.Text(
          '${esCierre ? 'Cierre de obra' : 'Proforma'} / USD. '
          '${esCierre ? 'Reporte informativo de cierre' : 'Cotización de referencia'}; '
          'no constituye una factura ni un comprobante de pago.',
          style: const pw.TextStyle(fontSize: 8),
        ),
      ),
      pw.SizedBox(width: 12),
      pw.Text(
        '$numeroPagina / $paginas',
        style: const pw.TextStyle(fontSize: 9),
      ),
    ],
  );

  static pw.Widget encabezadoPagina(
    pw.ImageProvider logo,
    bool esCierre,
    int proyectoId,
    bool mostrar,
    PdfColor azul,
    PdfColor morado,
  ) => !mostrar
      ? pw.SizedBox()
      : pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 10),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColor.fromHex('#E5E3EE')),
            ),
          ),
          child: pw.Row(
            children: [
              pw.Image(logo, width: 22, height: 22),
              pw.SizedBox(width: 8),
              pw.Text(
                'COTI  /  ${esCierre ? 'CIERRE DE OBRA' : 'PROFORMA'}',
                style: pw.TextStyle(
                  color: azul,
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              pw.Spacer(),
              pw.Text(
                codigoDocumento(proyectoId),
                style: pw.TextStyle(color: morado, fontSize: 9),
              ),
            ],
          ),
        );

  static pw.Widget fila(
    String etiqueta,
    String valor, {
    bool destacado = false,
  }) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 6),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          child: pw.Text(
            etiqueta,
            style: pw.TextStyle(
              fontWeight: destacado ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ),
        pw.Text(
          valor,
          style: pw.TextStyle(
            fontSize: destacado ? 16 : 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  static pw.Widget encabezado(
    pw.ImageProvider logo,
    bool esCierre,
    int proyectoId,
    PdfColor azul,
    PdfColor morado, {
    String? titulo,
    String? codigo,
  }) => pw.Container(
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      color: azul,
      borderRadius: pw.BorderRadius.circular(14),
    ),
    child: pw.Row(
      children: [
        pw.Container(
          width: 44,
          height: 44,
          padding: const pw.EdgeInsets.all(4),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            borderRadius: pw.BorderRadius.circular(9),
          ),
          child: pw.Image(logo, fit: pw.BoxFit.contain),
        ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'COTI',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 9,
                  letterSpacing: 2,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                titulo ?? (esCierre ? 'Reporte de cierre' : 'Proforma'),
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 19,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: pw.BoxDecoration(
            color: morado,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Text(
            codigo ?? codigoDocumento(proyectoId),
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );

  static pw.Widget datoCompacto(
    String etiqueta,
    String valor,
    PdfColor superficie,
    PdfColor azul,
  ) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 10),
    decoration: pw.BoxDecoration(
      color: superficie,
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          etiqueta,
          style: pw.TextStyle(
            color: PdfColor.fromHex('#68697A'),
            fontSize: 7,
            letterSpacing: .5,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          valor,
          maxLines: 2,
          style: pw.TextStyle(
            color: azul,
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  static pw.Widget tituloSeccion(String texto, PdfColor azul) => pw.Text(
    texto,
    style: pw.TextStyle(
      color: azul,
      fontSize: 13,
      fontWeight: pw.FontWeight.bold,
    ),
  );

  static pw.Widget panelTotal(String etiqueta, String valor, PdfColor azul) =>
      pw.Container(
        margin: const pw.EdgeInsets.only(top: 8),
        padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: pw.BoxDecoration(
          color: azul,
          borderRadius: pw.BorderRadius.circular(10),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Text(
                etiqueta,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Text(
              valor,
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      );
}
