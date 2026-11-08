import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/cotizo_cubit.dart';
import '../../core/formato.dart';
import '../../dominio/calcular_presupuesto_proyecto.dart';
import '../../dominio/leer_margen_deseado.dart';
import '../../dominio/modelos.dart';
import 'componentes/datos_cliente_editor.dart';
import 'componentes/gastos_previstos_editor.dart';
import 'componentes/partidas_editor.dart';
import 'componentes/precio_proyecto_editor.dart';
import 'formulario_partida.dart';

class EditorProyectoPagina extends StatefulWidget {
  const EditorProyectoPagina({super.key, this.proyecto});
  final Proyecto? proyecto;

  @override
  State<EditorProyectoPagina> createState() => _EditorProyectoPaginaState();
}

class _EditorProyectoPaginaState extends State<EditorProyectoPagina> {
  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _cliente;
  late final TextEditingController _descripcion;
  late final TextEditingController _total;
  late final TextEditingController _margen;
  late final List<ItemProyecto> _partidas;
  late List<GastoPrevisto> _gastosPrevistos;
  late DateTime _inicio;
  DateTime? _fin;
  String? _errorFecha;
  bool _guardando = false;
  bool _modificado = false;
  bool _permitirSalida = false;

  @override
  void initState() {
    super.initState();
    final proyecto = widget.proyecto;
    _cliente = TextEditingController(text: proyecto?.nombreCliente ?? '');
    _descripcion = TextEditingController(text: proyecto?.descripcion ?? '');
    _total = TextEditingController(
      text: proyecto == null
          ? ''
          : (proyecto.totalCotizadoCentavos / 100).toStringAsFixed(2),
    );
    _margen = TextEditingController(
      text: proyecto?.margenDeseadoPuntos == null
          ? ''
          : (proyecto!.margenDeseadoPuntos! / 100).toStringAsFixed(2),
    );
    final hoy = DateTime.now();
    _inicio = proyecto?.fechaInicio ?? DateTime(hoy.year, hoy.month, hoy.day);
    _fin =
        proyecto?.fechaFin ??
        (proyecto == null ? DateTime(hoy.year, hoy.month, hoy.day) : null);
    _partidas = proyecto == null
        ? []
        : List.of(
            context.read<CotizoCubit>().state.datos.itemsDeProyecto(
              proyecto.id,
            ),
          );
    _gastosPrevistos = proyecto == null
        ? []
        : List.of(
            context.read<CotizoCubit>().state.datos.gastosPrevistosDeProyecto(
              proyecto.id,
            ),
          );
  }

  @override
  void dispose() {
    _cliente.dispose();
    _descripcion.dispose();
    _total.dispose();
    _margen.dispose();
    super.dispose();
  }

  Future<void> _salir() async {
    if (_guardando) return;
    final salir = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Descartar cambios?'),
        content: const Text(
          'Los cambios de esta cotización todavía no se han guardado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Seguir editando'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    if (salir != true || !mounted) return;
    setState(() => _permitirSalida = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  Future<void> _editarPartida([int? indice]) async {
    final partida = await mostrarFormularioPartida(
      context,
      partida: indice == null ? null : _partidas[indice],
    );
    if (partida == null || !mounted) return;
    setState(() {
      _modificado = true;
      if (indice == null) {
        _partidas.add(partida);
      } else {
        _partidas[indice] = partida;
      }
    });
  }

  Future<void> _guardar() async {
    if (_guardando) return;
    final valido = _formulario.currentState!.validate();
    setState(
      () => _errorFecha = _fin == null
          ? widget.proyecto == null
                ? 'Selecciona la fecha final prevista.'
                : null
          : _fin!.isBefore(_inicio)
          ? 'La entrega no puede ser anterior al inicio.'
          : null,
    );
    if (!valido || _errorFecha != null) return;
    setState(() => _guardando = true);
    final guardado = await context.read<CotizoCubit>().guardarProyecto(
      Proyecto(
        id: widget.proyecto?.id ?? 0,
        nombreCliente: _cliente.text.trim(),
        descripcion: _descripcion.text.trim(),
        fechaInicio: _inicio,
        fechaFin: _fin,
        fechaInicioReal: widget.proyecto?.fechaInicioReal,
        fechaFinReal: widget.proyecto?.fechaFinReal,
        estado: widget.proyecto?.estado ?? EstadoProyecto.borrador,
        totalCotizadoCentavos: leerCentavos(_total.text)!,
        margenDeseadoPuntos: leerMargenDeseadoPuntos(_margen.text),
      ),
      _partidas,
      gastosPrevistos: _gastosPrevistos,
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

  @override
  Widget build(BuildContext context) {
    final datosCliente = DatosClienteEditor(
      cliente: _cliente,
      descripcion: _descripcion,
      inicio: _inicio,
      fin: _fin,
      errorFecha: _errorFecha,
      alCambiarInicio: (fecha) => setState(() {
        _inicio = fecha;
        _modificado = true;
      }),
      alCambiarFin: (fecha) => setState(() {
        _fin = fecha;
        _modificado = true;
      }),
    );
    final materiales = PartidasEditor(
      partidas: _partidas,
      alAgregar: _editarPartida,
      alEditar: _editarPartida,
      alEliminar: (indice) => setState(() {
        _partidas.removeAt(indice);
        _modificado = true;
      }),
    );
    final presupuesto = calcularPresupuestoProyecto(
      _partidas,
      _gastosPrevistos,
      leerMargenDeseadoPuntos(_margen.text),
    );
    final sugerido = presupuesto.precioSugeridoCentavos;
    final resumen = PrecioProyectoEditor(
      total: _total,
      costoPrevisto: presupuesto.costoPrevistoCentavos,
      margen: _margen,
      precioSugerido: sugerido,
      aplicarSugerido: sugerido != null && sugerido <= 99999999999
          ? () => setState(
              () => _total.text = (sugerido / 100).toStringAsFixed(2),
            )
          : null,
      guardando: _guardando,
      alCambiar: () => setState(() {}),
      alGuardar: _guardar,
    );
    return PopScope(
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
        body: AbsorbPointer(
          absorbing: _guardando,
          child: Form(
            key: _formulario,
            onChanged: () {
              if (!_modificado) setState(() => _modificado = true);
            },
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: LayoutBuilder(
                  builder: (context, limites) => SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: limites.maxWidth >= 900
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 7,
                                child: Column(
                                  children: [
                                    datosCliente,
                                    const SizedBox(height: 16),
                                    materiales,
                                    const SizedBox(height: 16),
                                    GastosPrevistosEditor(
                                      gastos: _gastosPrevistos,
                                      alCambiar: (gastos) => setState(() {
                                        _gastosPrevistos = gastos;
                                        _modificado = true;
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(flex: 5, child: resumen),
                            ],
                          )
                        : Column(
                            children: [
                              datosCliente,
                              const SizedBox(height: 16),
                              materiales,
                              const SizedBox(height: 16),
                              GastosPrevistosEditor(
                                gastos: _gastosPrevistos,
                                alCambiar: (gastos) => setState(() {
                                  _gastosPrevistos = gastos;
                                  _modificado = true;
                                }),
                              ),
                              const SizedBox(height: 16),
                              resumen,
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
