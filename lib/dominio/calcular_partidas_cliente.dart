import 'modelos.dart';

// Línea que ve el cliente, con el margen ya incluido en su precio.
class PartidaCliente {
  const PartidaCliente({
    required this.descripcion,
    required this.cantidad,
    required this.unidad,
    required this.subtotalCentavos,
  });

  final String descripcion;
  final double cantidad;
  final String unidad;
  final int subtotalCentavos;

  int get unitarioCentavos =>
      cantidad <= 0 ? subtotalCentavos : (subtotalCentavos / cantidad).round();
}

const etiquetaManoObraCliente = 'Mano de obra y ejecución';

// Reparte el total cotizado entre las partidas en proporción a su costo (D-008).
// La suma de las partidas siempre es igual al total cotizado.
List<PartidaCliente> calcularPartidasCliente(
  Proyecto proyecto,
  List<ItemProyecto> items,
  List<GastoPrevisto> gastosPrevistos,
) {
  final servicios = [
    for (final item in items)
      if (item.esServicio)
        PartidaCliente(
          descripcion: item.nombreMaterial,
          cantidad: item.cantidad,
          unidad: item.unidadMedida,
          subtotalCentavos: item.subtotalCentavos,
        ),
  ];
  final precioServicios = servicios.fold<int>(
    0,
    (total, partida) => total + partida.subtotalCentavos,
  );
  // El margen se reparte solo entre las líneas de costo.
  final total = proyecto.totalCotizadoCentavos - precioServicios;
  final ejecucion =
      proyecto.cobroManoObraCentavos +
      gastosPrevistos.fold<int>(0, (suma, gasto) => suma + gasto.montoCentavos);
  final base = [
    for (final item in items.where((item) => !item.esServicio))
      (
        descripcion: item.nombreMaterial,
        cantidad: item.cantidad,
        unidad: item.unidadMedida,
        costo: item.subtotalCentavos,
      ),
    if (ejecucion > 0)
      (
        descripcion: etiquetaManoObraCliente,
        cantidad: 1.0,
        unidad: 'global',
        costo: ejecucion,
      ),
  ];
  final costoTotal = base.fold<int>(0, (suma, linea) => suma + linea.costo);
  if (costoTotal <= 0 || total <= 0) {
    if (total <= 0) return servicios;
    return [
      ...servicios,
      PartidaCliente(
        descripcion: proyecto.descripcion.isEmpty
            ? 'Servicio'
            : proyecto.descripcion,
        cantidad: 1,
        unidad: 'global',
        subtotalCentavos: total,
      ),
    ];
  }
  final montos = _repartir(total, [for (final l in base) l.costo], costoTotal);
  return [
    ...servicios,
    for (var i = 0; i < base.length; i++)
      PartidaCliente(
        descripcion: base[i].descripcion,
        cantidad: base[i].cantidad,
        unidad: base[i].unidad,
        subtotalCentavos: montos[i],
      ),
  ];
}

// Método del mayor residuo: evita que el redondeo cambie el total.
List<int> _repartir(int total, List<int> pesos, int sumaPesos) {
  final enteros = <int>[];
  final residuos = <int>[];
  for (final peso in pesos) {
    final producto = BigInt.from(peso) * BigInt.from(total);
    final divisor = BigInt.from(sumaPesos);
    enteros.add((producto ~/ divisor).toInt());
    residuos.add((producto % divisor).toInt());
  }
  var faltante = total - enteros.fold<int>(0, (a, b) => a + b);
  final orden = List.generate(pesos.length, (i) => i)
    ..sort((a, b) => residuos[b].compareTo(residuos[a]));
  for (var i = 0; faltante > 0 && orden.isNotEmpty; i++, faltante--) {
    enteros[orden[i % orden.length]]++;
  }
  return enteros;
}
