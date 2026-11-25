import 'package:flutter/material.dart';

import '../../../core/enfoque.dart';
import '../../../core/formato.dart';
import '../../../widgets/selector_iva.dart';
import '../utilidades/datos_proforma_editor.dart';
import 'seccion_cotizacion.dart';

// IVA, validez, forma de pago y condiciones de la proforma (P-022, P-023).
class CondicionesProformaEditor extends StatelessWidget {
  const CondicionesProformaEditor({
    super.key,
    required this.datos,
    required this.subtotalCentavos,
    required this.alCambiar,
  });

  final DatosProformaEditor datos;
  final int subtotalCentavos;
  final VoidCallback alCambiar;

  @override
  Widget build(BuildContext context) {
    final iva = datos.ivaPuntos == null
        ? 0
        : (subtotalCentavos * datos.ivaPuntos! + 5000) ~/ 10000;
    return SeccionCotizacion(
      titulo: 'Condiciones de la proforma',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SelectorIva(
            puntos: datos.ivaPuntos,
            alCambiar: (valor) {
              datos.ivaPuntos = valor;
              alCambiar();
            },
          ),
          const SizedBox(height: 12),
          _Fila('Subtotal', subtotalCentavos),
          if (datos.ivaPuntos != null) _Fila('IVA', iva),
          _Fila(
            'Total para el cliente',
            subtotalCentavos + iva,
            destacado: true,
          ),
          const SizedBox(height: 12),
          TextFormField(
            onTapOutside: cerrarFocoAlTocarFuera,
            controller: datos.validez,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Validez de la oferta',
              suffixText: 'días',
            ),
            validator: (texto) {
              final dias = int.tryParse(texto?.trim() ?? '');
              return dias == null || dias < 1 || dias > 365
                  ? 'Ingresa entre 1 y 365 días.'
                  : null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            onTapOutside: cerrarFocoAlTocarFuera,
            controller: datos.formaPago,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: 'Forma de pago',
              hintText: 'Ej.: 50 % de anticipo y 50 % al finalizar',
            ),
          ),
          TextFormField(
            onTapOutside: cerrarFocoAlTocarFuera,
            controller: datos.condiciones,
            minLines: 2,
            maxLines: 5,
            maxLength: 2000,
            decoration: const InputDecoration(labelText: 'Condiciones'),
          ),
        ],
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila(this.etiqueta, this.centavos, {this.destacado = false});

  final String etiqueta;
  final int centavos;
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    final estilo = TextStyle(
      fontWeight: destacado ? FontWeight.w700 : FontWeight.w400,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(etiqueta, style: estilo)),
          Text(dinero(centavos), style: estilo),
        ],
      ),
    );
  }
}
