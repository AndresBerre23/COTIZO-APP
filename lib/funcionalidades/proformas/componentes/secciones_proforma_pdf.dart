import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/formato.dart';
import '../../../dominio/modelos.dart';
import '../../../dominio/opciones_iva.dart';
import 'diseno_documento_pdf.dart';

// Datos de contacto que acompañan a un nombre en el PDF.
List<String> detallesContacto({
  String identificacion = '',
  String telefono = '',
  String correo = '',
  String direccion = '',
}) => [
  if (identificacion.trim().isNotEmpty) 'RUC/CI: ${identificacion.trim()}',
  [telefono.trim(), correo.trim()].where((dato) => dato.isNotEmpty).join(' · '),
  direccion.trim(),
].where((dato) => dato.isNotEmpty).toList();

List<String> detallesNegocio(DatosNegocio? negocio) => negocio == null
    ? const []
    : detallesContacto(
        identificacion: negocio.identificacion,
        telefono: negocio.telefono,
        correo: negocio.correo,
        direccion: negocio.direccion,
      );

List<String> detallesCliente(Cliente? cliente) => cliente == null
    ? const []
    : detallesContacto(
        identificacion: cliente.identificacion,
        telefono: cliente.telefono,
        correo: cliente.correo,
        direccion: cliente.direccion,
      );

// Totales con IVA, validez, forma de pago y condiciones (P-022, P-023).
List<pw.Widget> cierreProformaPdf(Proyecto proyecto, PdfColor azul) => [
  DisenoDocumentoPdf.fila('Subtotal', dinero(proyecto.totalCotizadoCentavos)),
  if (proyecto.ivaPuntos != null)
    DisenoDocumentoPdf.fila(
      etiquetaIva(proyecto.ivaPuntos),
      dinero(proyecto.ivaCentavos),
    ),
  DisenoDocumentoPdf.panelTotal(
    'TOTAL DE LA PROFORMA',
    dinero(proyecto.totalConIvaCentavos),
    azul,
  ),
  pw.SizedBox(height: 16),
  _parrafo(
    'Vigencia',
    'Emitida el ${fechaCorta(proyecto.creadoEl)}. Válida hasta el '
        '${fechaCorta(proyecto.validaHasta)} (${proyecto.validezDias} días).',
    azul,
  ),
  if (proyecto.formaPago.trim().isNotEmpty)
    _parrafo('Forma de pago', proyecto.formaPago.trim(), azul),
  if (proyecto.condiciones.trim().isNotEmpty)
    _parrafo('Condiciones', proyecto.condiciones.trim(), azul),
];

pw.Widget _parrafo(String titulo, String texto, PdfColor azul) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 10),
  child: pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        titulo,
        style: pw.TextStyle(
          color: azul,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.SizedBox(height: 2),
      pw.Text(texto, style: const pw.TextStyle(fontSize: 10)),
    ],
  ),
);
