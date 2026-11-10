import 'package:flutter/material.dart';
import 'package:cotizo_app/core/enfoque.dart';

import '../../../core/formato.dart';
import '../../../dominio/calcular_precio_sugerido.dart';
import 'selector_mano_obra_propia.dart';
import 'seccion_cotizacion.dart';

class PrecioProyectoEditor extends StatelessWidget {
  const PrecioProyectoEditor({
    super.key,
    required this.total,
    required this.cobroManoObra,
    required this.incluirManoObra,
    required this.alCambiarInclusionManoObra,
    required this.costoPrevisto,
    required this.precioSugerido,
    required this.aplicarSugerido,
    required this.alCambiar,
  });

  final TextEditingController total;
  final TextEditingController cobroManoObra;
  final bool incluirManoObra;
  final ValueChanged<bool> alCambiarInclusionManoObra;
  final int costoPrevisto;
  final int? precioSugerido;
  final VoidCallback? aplicarSugerido;
  final VoidCallback alCambiar;

  @override
  Widget build(BuildContext context) {
    final cotizadoLeido = leerCentavos(total.text);
    final totalValido = cotizadoLeido != null && cotizadoLeido > 0;
    final cotizado = cotizadoLeido ?? 0;
    final manoObra = incluirManoObra
        ? leerCentavos(cobroManoObra.text) ?? 0
        : 0;
    final precioPorDebajoDeCostos =
        totalValido && cotizado < costoPrevisto + manoObra;
    final margenSugerido = precioSugerido == null
        ? null
        : precioSugerido! - costoPrevisto - manoObra;
    return SeccionCotizacion(
      titulo: 'Precio de tu trabajo',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SelectorManoObraPropia(
            incluido: incluirManoObra,
            alCambiar: alCambiarInclusionManoObra,
          ),
          if (incluirManoObra) ...[
            TextFormField(
              onTapOutside: cerrarFocoAlTocarFuera,
              controller: cobroManoObra,
              validator: validarImporte,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => alCambiar(),
              decoration: const InputDecoration(
                labelText: 'Cobro por mano de obra propia',
                prefixText: '\$ ',
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (precioSugerido != null)
            _PrecioSugeridoDestacado(
              precio: precioSugerido!,
              costos: costoPrevisto,
              manoObra: manoObra,
              margen: margenSugerido!,
              aplicar: aplicarSugerido,
            )
          else
            Text(
              'Agrega costos previstos o un cobro de mano de obra para calcular un precio sugerido.',
            ),
          const SizedBox(height: 16),
          TextFormField(
            onTapOutside: cerrarFocoAlTocarFuera,
            controller: total,
            validator: validarImporte,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => alCambiar(),
            decoration: const InputDecoration(
              labelText: 'Total que cobrarás al cliente',
              helperText: 'Puedes usar el precio sugerido o escribir otro.',
              prefixText: '\$ ',
            ),
          ),
          const SizedBox(height: 20),
          Text(
            incluirManoObra
                ? 'Margen adicional, aparte de tu mano de obra'
                : 'Margen adicional sobre costos',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              totalValido
                  ? dinero(cotizado - costoPrevisto - manoObra)
                  : 'Completa el total para calcularlo',
              style: TextStyle(
                fontSize: 28,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                color: precioPorDebajoDeCostos
                    ? Theme.of(context).colorScheme.error
                    : totalValido
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (precioPorDebajoDeCostos)
            Text(
              'El precio cotizado está por debajo de los costos y el cobro de mano de obra.',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          const SizedBox(height: 8),
          Text(
            '${manoObra > 0 ? 'Ganancia prevista total (incluye tu mano de obra)' : 'Ganancia prevista total'}: ${totalValido ? dinero(cotizado - costoPrevisto) : 'Pendiente'}',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'El precio final sigue siendo editable. Los gastos registrados se calcularán por separado.',
          ),
        ],
      ),
    );
  }
}

class _PrecioSugeridoDestacado extends StatelessWidget {
  const _PrecioSugeridoDestacado({
    required this.precio,
    required this.costos,
    required this.manoObra,
    required this.margen,
    required this.aplicar,
  });

  final int precio;
  final int costos;
  final int manoObra;
  final int margen;
  final VoidCallback? aplicar;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Theme.of(context).colorScheme.secondary),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'PRECIO SUGERIDO TOTAL',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            dinero(precio),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Aplica un margen del ${margenSugeridoFijoPuntos ~/ 100} % al precio de materiales y otros costos. Tu mano de obra se suma aparte.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Divider(height: 20),
        _FilaDesglosePrecio(
          etiqueta: 'Materiales y otros costos',
          monto: costos,
        ),
        if (manoObra > 0)
          _FilaDesglosePrecio(
            etiqueta: 'Cobro por tu mano de obra',
            monto: manoObra,
          ),
        _FilaDesglosePrecio(etiqueta: 'Margen estimado', monto: margen),
        if (aplicar == null)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'El precio sugerido supera el límite admitido.',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          )
        else ...[
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: aplicar,
            icon: Icon(Icons.check),
            label: Text('Usar este precio'),
          ),
        ],
      ],
    ),
  );
}

class _FilaDesglosePrecio extends StatelessWidget {
  const _FilaDesglosePrecio({required this.etiqueta, required this.monto});

  final String etiqueta;
  final int monto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(etiqueta)),
        const SizedBox(width: 12),
        Text(dinero(monto), style: TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}
