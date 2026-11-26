import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../aplicacion/coti_cubit.dart';
import '../../aplicacion/preferencias_cubit.dart';
import '../../core/formato.dart';
import '../../dominio/modelos.dart';
import 'componentes/condiciones_proforma_editor.dart';
import 'componentes/datos_cliente_editor.dart';
import 'componentes/dialogo_confirmar_cotizacion.dart';
import 'componentes/gastos_previstos_editor.dart';
import 'componentes/partidas_editor.dart';
import 'componentes/precio_proyecto_editor.dart';
import 'componentes/progreso_cotizacion.dart';
import 'componentes/resumen_costo_previsto.dart';
import 'formulario_partida.dart';
import 'formulario_servicio.dart';
import 'utilidades/estado_editor_cotizacion.dart';
import '../../widgets/confirmar.dart';

class EditorProyectoPagina extends StatefulWidget {
  const EditorProyectoPagina({super.key, this.proyecto});
  final Proyecto? proyecto;

  @override
  State<EditorProyectoPagina> createState() => _EditorProyectoPaginaState();
}

class _EditorProyectoPaginaState extends State<EditorProyectoPagina> {
  final _formularios = List.generate(4, (_) => GlobalKey<FormState>());
  late final EstadoEditorCotizacion _e;
  String? _errorFecha;
  int _paso = 0;
  bool _guardando = false;
  bool _modificado = false;
  bool _permitirSalida = false;

  @override
  void initState() {
    super.initState();
    _e = EstadoEditorCotizacion.desde(
      widget.proyecto,
      context.read<CotiCubit>().state.datos,
      context.read<PreferenciasCubit>().state,
    );
  }

  @override
  void dispose() {
    _e.dispose();
    super.dispose();
  }

  // Aplica un cambio y marca la cotización como modificada.
  void _cambiar(VoidCallback cambio) => setState(() {
    cambio();
    _modificado = true;
  });

  void _continuar() {
    if (_guardando) return;
    final valido = _formularios[_paso].currentState?.validate() ?? true;
    if (_paso == 0) {
      final errorFecha = _e.validarFechas();
      setState(() => _errorFecha = errorFecha);
      if (!valido || errorFecha != null) return;
    } else if (!valido) {
      return;
    }
    setState(() => _paso++);
  }

  void _retroceder() {
    if (_paso > 0 && !_guardando) setState(() => _paso--);
  }

  Future<void> _cancelar() async {
    if (_modificado) return _salir();
    setState(() => _permitirSalida = true);
    Navigator.of(context).pop();
  }

  Future<void> _salir() async {
    if (_guardando) return;
    final salir = await confirmarAccion(
      context,
      titulo: '¿Descartar cambios?',
      mensaje: 'Los cambios de esta cotización todavía no se han guardado.',
      accion: 'Descartar',
      cancelar: 'Seguir editando',
    );
    if (!salir || !mounted) return;
    setState(() => _permitirSalida = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  Future<void> _editarPartida([int? indice, bool servicio = false]) async {
    final actual = indice == null ? null : _e.partidas[indice];
    final partida = servicio || (actual?.esServicio ?? false)
        ? await mostrarFormularioServicio(context, partida: actual)
        : await mostrarFormularioPartida(context, partida: actual);
    if (partida == null || !mounted) return;
    _cambiar(() {
      if (indice == null) {
        _e.partidas.add(partida);
      } else {
        _e.partidas[indice] = partida;
      }
    });
  }

  Future<void> _guardar() async {
    if (_guardando || !(_formularios[3].currentState?.validate() ?? false)) {
      return;
    }
    final errorFecha = _e.validarFechas();
    if (errorFecha != null) {
      setState(() {
        _paso = 0;
        _errorFecha = errorFecha;
      });
      return;
    }
    final confirmar = await mostrarConfirmacionCotizacion(
      context: context,
      proyecto: _e.proyectoActual(),
      partidas: _e.partidas,
      gastosPrevistos: _e.gastosPrevistos,
    );
    if (confirmar != true || !mounted) return;
    setState(() => _guardando = true);
    final cubit = context.read<CotiCubit>();
    final guardado = await cubit.guardarProyecto(
      _e.proyectoActual(),
      _e.partidas,
      gastosPrevistos: _e.gastosPrevistos,
      cliente: _e.clienteActual(cubit.state.datos.clientes),
    );
    if (!mounted) return;
    setState(() {
      _guardando = false;
      _permitirSalida = guardado;
    });
    if (guardado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cotización guardada en este dispositivo'),
        ),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  Widget _contenidoPaso() {
    final presupuesto = _e.presupuesto;
    final sugerido = presupuesto.precioSugeridoCentavos;
    return switch (_paso) {
      0 => DatosClienteEditor(
        datosProforma: _e.proforma,
        clientes: context.read<CotiCubit>().state.datos.clientes,
        alElegirCliente: (cliente) =>
            _cambiar(() => _e.proforma.elegirCliente(cliente)),
        cliente: _e.cliente,
        descripcion: _e.descripcion,
        inicio: _e.inicio,
        fin: _e.fin,
        errorFecha: _errorFecha,
        alCambiarInicio: (fecha) => _cambiar(() {
          _e.inicio = fecha;
          _errorFecha = null;
        }),
        alCambiarFin: (fecha) => _cambiar(() {
          _e.fin = fecha;
          _errorFecha = null;
        }),
      ),
      1 => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PartidasEditor(
            partidas: _e.partidas,
            alAgregar: _editarPartida,
            alAgregarServicio: () => _editarPartida(null, true),
            alEditar: _editarPartida,
            alEliminar: (indice) =>
                _cambiar(() => _e.partidas.removeAt(indice)),
          ),
          if (_e.partidas.isEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Puedes omitir este paso si cotizas solo mano de obra o servicios.',
            ),
          ],
        ],
      ),
      2 => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GastosPrevistosEditor(
            gastos: _e.gastosPrevistos,
            alCambiar: (nuevos) => _cambiar(() => _e.gastosPrevistos = nuevos),
          ),
          const SizedBox(height: 12),
          ResumenCostoPrevisto(presupuesto: presupuesto),
          if (_e.gastosPrevistos.isEmpty) ...[
            const SizedBox(height: 8),
            const Text('Puedes continuar sin agregar gastos previstos.'),
          ],
        ],
      ),
      _ => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrecioProyectoEditor(
            total: _e.total,
            cobroManoObra: _e.cobroManoObra,
            incluirManoObra: _e.incluirManoObra,
            alCambiarInclusionManoObra: (incluir) =>
                _cambiar(() => _e.incluirManoObra = incluir),
            costoPrevisto: presupuesto.costoPrevistoCentavos,
            precioSugerido: sugerido,
            aplicarSugerido: sugerido != null && sugerido <= 99999999999
                ? () => _cambiar(
                    () => _e.total.text = (sugerido / 100).toStringAsFixed(2),
                  )
                : null,
            alCambiar: () => setState(() {}),
            precioServicios: presupuesto.precioServiciosCentavos,
            margenPuntos: _e.proforma.margenPuntos,
          ),
          const SizedBox(height: 16),
          CondicionesProformaEditor(
            datos: _e.proforma,
            subtotalCentavos: leerCentavos(_e.total.text) ?? 0,
            alCambiar: () => setState(() => _modificado = true),
          ),
        ],
      ),
    };
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_guardando && (!_modificado || _permitirSalida),
    onPopInvokedWithResult: (salio, _) {
      if (!salio) _salir();
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(
          widget.proyecto == null ? 'Nueva cotización' : 'Editar cotización',
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProgresoCotizacion(paso: _paso),
                  const SizedBox(height: 20),
                  AbsorbPointer(
                    absorbing: _guardando,
                    child: Form(
                      key: _formularios[_paso],
                      onChanged: () => _modificado
                          ? null
                          : setState(() => _modificado = true),
                      child: _contenidoPaso(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AccionesPasoCotizacion(
        paso: _paso,
        guardando: _guardando,
        pasoOpcionalVacio:
            (_paso == 1 && _e.partidas.isEmpty) ||
            (_paso == 2 && _e.gastosPrevistos.isEmpty),
        alCancelar: _cancelar,
        alRetroceder: _retroceder,
        alAvanzar: _continuar,
        alGuardar: _guardar,
      ),
    ),
  );
}
