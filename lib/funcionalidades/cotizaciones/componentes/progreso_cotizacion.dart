import 'package:flutter/material.dart';

class ProgresoCotizacion extends StatelessWidget {
  const ProgresoCotizacion({super.key, required this.paso});

  final int paso;

  static const _titulos = [
    'Cliente y proyecto',
    'Materiales',
    'Gastos previstos',
    'Precio y revisión',
  ];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Paso ${paso + 1} de ${_titulos.length}',
        style: Theme.of(context).textTheme.labelLarge,
      ),
      const SizedBox(height: 4),
      Text(_titulos[paso], style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      LinearProgressIndicator(value: (paso + 1) / _titulos.length),
      const SizedBox(height: 8),
      Text(
        'Puedes volver a los pasos anteriores antes de guardar.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  );
}

class AccionesPasoCotizacion extends StatelessWidget {
  const AccionesPasoCotizacion({
    super.key,
    required this.paso,
    required this.guardando,
    required this.pasoOpcionalVacio,
    required this.alCancelar,
    required this.alRetroceder,
    required this.alAvanzar,
    required this.alGuardar,
  });

  final int paso;
  final bool guardando;
  final bool pasoOpcionalVacio;
  final VoidCallback alCancelar;
  final VoidCallback alRetroceder;
  final VoidCallback alAvanzar;
  final VoidCallback alGuardar;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          // Los botones se encogen en pantallas angostas en lugar de desbordar.
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: paso == 0
                    ? TextButton(
                        onPressed: guardando ? null : alCancelar,
                        child: const _Etiqueta('Cancelar'),
                      )
                    : OutlinedButton.icon(
                        onPressed: guardando ? null : alRetroceder,
                        icon: const Icon(Icons.arrow_back),
                        label: const _Etiqueta('Atrás'),
                      ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: paso == 3
                    ? FilledButton.icon(
                        onPressed: guardando ? null : alGuardar,
                        icon: const Icon(Icons.save_outlined),
                        label: _Etiqueta(
                          guardando ? 'Guardando…' : 'Guardar cotización',
                        ),
                      )
                    : FilledButton.icon(
                        onPressed: guardando ? null : alAvanzar,
                        icon: const Icon(Icons.arrow_forward),
                        label: _Etiqueta(
                          pasoOpcionalVacio ? 'Omitir por ahora' : 'Continuar',
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) =>
      Text(texto, maxLines: 1, overflow: TextOverflow.ellipsis);
}
