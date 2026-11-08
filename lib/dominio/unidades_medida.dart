class OpcionUnidadMedida {
  const OpcionUnidadMedida(this.nombre, [this.alias = const []]);

  final String nombre;
  final List<String> alias;
}

class GrupoUnidadesMedida {
  const GrupoUnidadesMedida(this.nombre, this.unidades);

  final String nombre;
  final List<OpcionUnidadMedida> unidades;
}

const valorOtraUnidad = '__otra_unidad__';

const gruposUnidadesMedida = <GrupoUnidadesMedida>[
  GrupoUnidadesMedida('Conteo y presentación', [
    OpcionUnidadMedida('Unidad', ['unidades', 'unid', 'u']),
    OpcionUnidadMedida('par', ['pares']),
    OpcionUnidadMedida('juego', ['juegos', 'set']),
    OpcionUnidadMedida('caja', ['cajas']),
    OpcionUnidadMedida('paquete', ['paquetes']),
    OpcionUnidadMedida('saco', ['sacos']),
    OpcionUnidadMedida('bolsa', ['bolsas']),
    OpcionUnidadMedida('rollo', ['rollos']),
    OpcionUnidadMedida('plancha', ['planchas']),
    OpcionUnidadMedida('lámina', ['lamina', 'laminas', 'hoja']),
    OpcionUnidadMedida('tubo', ['tubos']),
    OpcionUnidadMedida('barra', ['barras']),
    OpcionUnidadMedida('caneca', ['canecas']),
  ]),
  GrupoUnidadesMedida('Longitud y superficie', [
    OpcionUnidadMedida('mm', ['milimetro', 'milimetros']),
    OpcionUnidadMedida('cm', ['centimetro', 'centimetros']),
    OpcionUnidadMedida('m', ['metro', 'metros']),
    OpcionUnidadMedida('m²', ['m2', 'metro cuadrado', 'metros cuadrados']),
  ]),
  GrupoUnidadesMedida('Volumen', [
    OpcionUnidadMedida('m³', ['m3', 'metro cubico', 'metros cubicos']),
    OpcionUnidadMedida('mL', ['ml', 'mililitro', 'mililitros']),
    OpcionUnidadMedida('L', ['litro', 'litros']),
    OpcionUnidadMedida('galón', ['galon', 'galones']),
  ]),
  GrupoUnidadesMedida('Peso', [
    OpcionUnidadMedida('g', ['gramo', 'gramos']),
    OpcionUnidadMedida('kg', ['kilogramo', 'kilogramos']),
    OpcionUnidadMedida('tonelada', ['toneladas', 't']),
    OpcionUnidadMedida('libra', ['libras', 'lb', 'lbs']),
  ]),
];

List<OpcionUnidadMedida> buscarUnidadesMedida(String consulta) {
  final texto = normalizarUnidad(consulta.trim());
  final unidades = gruposUnidadesMedida.expand((grupo) => grupo.unidades);
  if (texto.isEmpty) return unidades.toList();
  return unidades.where((unidad) {
    return [
      unidad.nombre,
      ...unidad.alias,
    ].any((valor) => normalizarUnidad(valor).contains(texto));
  }).toList();
}

bool esUnidadPredefinida(String valor) {
  final texto = normalizarUnidad(valor.trim());
  return gruposUnidadesMedida
      .expand((grupo) => grupo.unidades)
      .any(
        (unidad) => [
          unidad.nombre,
          ...unidad.alias,
        ].any((alias) => normalizarUnidad(alias) == texto),
      );
}

String normalizarUnidad(String texto) => texto
    .toLowerCase()
    .replaceAll('á', 'a')
    .replaceAll('é', 'e')
    .replaceAll('í', 'i')
    .replaceAll('ó', 'o')
    .replaceAll('ú', 'u')
    .replaceAll('ü', 'u')
    .replaceAll('²', '2')
    .replaceAll('³', '3');
