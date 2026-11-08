import 'package:cotizo_app/dominio/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('deriva obra en curso, finalizada y retrasada desde sus fechas', () {
    final enCurso = Proyecto(
      id: 1,
      nombreCliente: 'Cliente',
      descripcion: 'Obra',
      fechaInicio: DateTime(2026, 11, 1),
      fechaFin: DateTime(2026, 11, 7),
      fechaInicioReal: DateTime(2026, 11, 2),
      estado: EstadoProyecto.aprobado,
      totalCotizadoCentavos: 1000,
    );

    expect(enCurso.esObra, isTrue);
    expect(enCurso.estaEnCurso, isTrue);
    expect(enCurso.estaRetrasada(DateTime(2026, 11, 7, 23, 59)), isFalse);
    expect(enCurso.estaRetrasada(DateTime(2026, 11, 8)), isTrue);
    expect(enCurso.diasDeRetraso(DateTime(2026, 11, 10)), 3);
    expect(enCurso.etapa, 'En curso');

    final historica = Proyecto(
      id: 2,
      nombreCliente: 'Cliente',
      descripcion: 'Obra histórica',
      fechaInicio: DateTime(2025, 1, 1),
      estado: EstadoProyecto.finalizado,
      totalCotizadoCentavos: 1000,
    );
    expect(historica.esObra, isTrue);
    expect(historica.estaEnCurso, isFalse);
    expect(historica.etapa, 'Finalizada');
  });
}
