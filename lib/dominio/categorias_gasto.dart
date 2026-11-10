const categoriasGasto = <String>[
  'Alimentación',
  'Mano de obra',
  'Transporte de materiales',
  'Transporte de personal',
  'Transporte propio',
  'Herramientas',
  'Materiales adicionales',
  'Otros',
];

const categoriaManoObra = 'Mano de obra';
const categoriaPagoTrabajadores = 'Pago a trabajadores';

final categoriasGastoPrevisto = categoriasGasto
    .map(
      (categoria) => categoria == categoriaManoObra
          ? categoriaPagoTrabajadores
          : categoria,
    )
    .toList(growable: false);
