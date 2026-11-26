import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../dominio/modelos.dart';
import 'mapeadores_sqlite.dart';

// Campos que cambian lo que el cliente recibió; el estado y las fechas reales no.
const _camposComerciales = [
  'nombre_cliente',
  'descripcion',
  'fecha_inicio',
  'fecha_fin',
  'total_cotizado',
  'cobro_mano_obra',
  'iva_puntos',
  'validez_dias',
  'forma_pago',
  'condiciones',
];
const _camposPartida = [
  'material_id',
  'es_servicio',
  'cantidad',
  'costo_unitario_aplicado',
  'nombre_material',
  'unidad_medida',
];

// Antes de editar una proforma ya enviada, conserva la versión anterior (P-032).
Future<void> conservarVersionPrevia(
  DatabaseExecutor transaccion,
  Proyecto nuevo,
  List<ItemProyecto> items,
) async {
  if (nuevo.id == 0) return;
  final filas = await transaccion.query(
    'proyectos',
    where: 'id = ?',
    whereArgs: [nuevo.id],
  );
  if (filas.isEmpty) return;
  final anterior = filas.single;
  if (anterior['estado'] == EstadoProyecto.borrador.name) return;
  final partidas = await transaccion.query(
    'items_proyecto',
    where: 'proyecto_id = ?',
    whereArgs: [nuevo.id],
    orderBy: 'id',
  );
  final nuevaFila = escribirProyecto(nuevo);
  final nuevasPartidas = [for (final i in items) escribirItem(i, nuevo.id)];
  final igual =
      _camposComerciales.every((c) => anterior[c] == nuevaFila[c]) &&
      _mismasPartidas(partidas, nuevasPartidas);
  if (igual) return;
  final previstos = await transaccion.query(
    'gastos_previstos',
    where: 'proyecto_id = ?',
    whereArgs: [nuevo.id],
    orderBy: 'id',
  );
  final ultimo = await transaccion.rawQuery(
    'SELECT MAX(numero) AS numero FROM versiones_proforma WHERE proyecto_id = ?',
    [nuevo.id],
  );
  await transaccion.insert('versiones_proforma', {
    'proyecto_id': nuevo.id,
    'numero': ((ultimo.first['numero'] as int?) ?? 0) + 1,
    'fecha': DateTime.now().millisecondsSinceEpoch,
    'contenido': jsonEncode({
      'proyecto': anterior,
      'partidas': partidas,
      'previstos': previstos,
    }),
  });
}

bool _mismasPartidas(
  List<Map<String, Object?>> anteriores,
  List<Map<String, Object?>> nuevas,
) {
  if (anteriores.length != nuevas.length) return false;
  for (var i = 0; i < nuevas.length; i++) {
    for (final campo in _camposPartida) {
      final a = anteriores[i][campo], b = nuevas[i][campo];
      if (a is num && b is num ? a.toDouble() != b.toDouble() : a != b) {
        return false;
      }
    }
  }
  return true;
}

VersionProforma leerVersion(Map<String, Object?> fila) {
  final contenido = jsonDecode(fila['contenido'] as String) as Map;
  List<Map<String, Object?>> filas(String clave) => [
    for (final f in contenido[clave] as List) Map<String, Object?>.from(f),
  ];
  return VersionProforma(
    id: fila['id'] as int,
    proyectoId: fila['proyecto_id'] as int,
    numero: fila['numero'] as int,
    fecha: DateTime.fromMillisecondsSinceEpoch(fila['fecha'] as int),
    proyecto: leerProyecto(
      Map<String, Object?>.from(contenido['proyecto'] as Map),
    ),
    items: [for (final f in filas('partidas')) leerItem(f)],
    gastosPrevistos: [for (final f in filas('previstos')) leerGastoPrevisto(f)],
  );
}
