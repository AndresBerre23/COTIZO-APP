// Tasas de IVA ofrecidas (D-106); nulo significa que no aplica.
const opcionesIva = <({String etiqueta, int? puntos})>[
  (etiqueta: 'IVA 15 %', puntos: 1500),
  (etiqueta: 'IVA 0 %', puntos: 0),
  (etiqueta: 'No cobro IVA (RIMPE negocio popular)', puntos: null),
];

String etiquetaIva(int? puntos) {
  for (final opcion in opcionesIva) {
    if (opcion.puntos == puntos) return opcion.etiqueta;
  }
  return 'IVA ${puntos! / 100} %';
}
