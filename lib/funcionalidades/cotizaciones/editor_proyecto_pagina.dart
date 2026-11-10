import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../aplicacion/cotizo_cubit.dart';
import '../../core/formato.dart';
import '../../dominio/calcular_presupuesto_proyecto.dart';
import '../../dominio/calcular_precio_sugerido.dart';
import '../../dominio/modelos.dart';
import '../../widgets/surface_card.dart';
import 'componentes/datos_cliente_editor.dart';
import 'componentes/dialogo_confirmar_cotizacion.dart';
import 'componentes/gastos_previstos_editor.dart';
import 'componentes/partidas_editor.dart';
import 'componentes/precio_proyecto_editor.dart';
import 'componentes/progreso_cotizacion.dart';
import 'formulario_partida.dart';

class EditorProyectoPagina extends StatefulWidget {
  const EditorProyectoPagina({super.key, this.proyecto});
  final Proyecto? proyecto;

  @override
  State<EditorProyectoPagina> createState() => _EditorProyectoPaginaState();
}

class _EditorProyectoPaginaState extends State<EditorProyectoPagina> {
  final _formularios = List.generate(4, (_) => GlobalKey<FormState>());
  late final TextEditingController _cliente;
  late final TextEditingController _descripcion;
  late final TextEditingController _total;
  late final TextEditingController _cobroManoObra;
  late final List<ItemProyecto> _partidas;
  late List<GastoPrevisto> _gastosPrevistos;
  late DateTime _inicio;
  DateTime? _fin;
  String? _errorFecha;
  bool _incluirManoObra = false;
  int _paso = 0;
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
    _cobroManoObra = TextEditingController(
      text: proyecto == null || proyecto.cobroManoObraCentavos == 0
          ? ''
          : (proyecto.cobroManoObraCentavos / 100).toStringAsFixed(2),
    );
    _incluirManoObra = (proyecto?.cobroManoObraCentavos ?? 0) > 0;
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
    _cobroManoObra.dispose();
    super.dispose();
  }

  String? _validarFechas() {
    if (_fin == null && widget.proyecto == null) {
      return 'Selecciona la fecha final prevista.';
    }
    if (_fin?.isBefore(_inicio) ?? false) {
      return 'La entrega no puede ser anterior al inicio.';
    }
    return null;
  }

  void _continuar() {
    if (_guardando) return;
    final valido = _formularios[_paso].currentState?.validate() ?? true;
    if (_paso == 0) {
      final errorFecha = _validarFechas();
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

  void _cancelar() {
    if (_modificado) {
      _salir();
      return;
    }
    setState(() => _permitirSalida = true);
    Navigator.of(context).pop();
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

  Proyecto _proyectoActual() => Proyecto(
    id: widget.proyecto?.id ?? 0,
    nombreCliente: _cliente.text.trim(),
    descripcion: _descripcion.text.trim(),
    fechaInicio: _inicio,
    fechaFin: _fin,
    fechaInicioReal: widget.proyecto?.fechaInicioReal,
    fechaFinReal: widget.proyecto?.fechaFinReal,
    estado: widget.proyecto?.estado ?? EstadoProyecto.borrador,
    totalCotizadoCentavos: leerCentavos(_total.text) ?? 0,
    cobroManoObraCentavos: _incluirManoObra
        ? leerCentavos(_cobroManoObra.text) ?? 0
        : 0,
    margenDeseadoPuntos: margenSugeridoFijoPuntos,
  );

  Future<void> _guardar() async {
    if (_guardando || !(_formularios[3].currentState?.validate() ?? false)) {
      return;
    }
    final errorFecha = _validarFechas();
    if (errorFecha != null) {
      setState(() {
        _paso = 0;
        _errorFecha = errorFecha;
      });
      return;
    }
    final confirmar = await mostrarConfirmacionCotizacion(
      context: context,
      proyecto: _proyectoActual(),
      partidas: _partidas,
      gastosPrevistos: _gastosPrevistos,
    );
    if (confirmar != true || !mounted) return;
    setState(() => _guardando = true);
    final guardado = await context.read<CotizoCubit>().guardarProyecto(
      _proyectoActual(),
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

  Widget _contenidoPaso() {
    final datosCliente = DatosClienteEditor(
      cliente: _cliente,
      descripcion: _descripcion,
      inicio: _inicio,
      fin: _fin,
      errorFecha: _errorFecha,
      alCambiarInicio: (fecha) => setState(() {
        _inicio = fecha;
        _errorFecha = null;
        _modificado = true;
      }),
      alCambiarFin: (fecha) => setState(() {
        _fin = fecha;
        _errorFecha = null;
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
    final gastos = GastosPrevistosEditor(
      gastos: _gastosPrevistos,
      alCambiar: (nuevos) => setState(() {
        _gastosPrevistos = nuevos;
        _modificado = true;
      }),
    );
    final presupuesto = calcularPresupuestoProyecto(
      _partidas,
      _gastosPrevistos,
      cobroManoObraCentavos: _incluirManoObra
          ? leerCentavos(_cobroManoObra.text) ?? 0
          : 0,
    );
    final sugerido = presupuesto.precioSugeridoCentavos;
    final precio = PrecioProyectoEditor(
      total: _total,
      cobroManoObra: _cobroManoObra,
      incluirManoObra: _incluirManoObra,
      alCambiarInclusionManoObra: (incluir) => setState(() {
        _incluirManoObra = incluir;
        _modificado = true;
      }),
      costoPrevisto: presupuesto.costoPrevistoCentavos,
      precioSugerido: sugerido,
      aplicarSugerido: sugerido != null && sugerido <= 99999999999
          ? () => setState(() {
              _total.text = (sugerido / 100).toStringAsFixed(2);
              _modificado = true;
            })
          : null,
      alCambiar: () => setState(() {}),
    );

    return switch (_paso) {
      0 => datosCliente,
      1 => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          materiales,
          if (_partidas.isEmpty) ...[
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
          gastos,
          const SizedBox(height: 12),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Costo previsto de la cotización'),
                const SizedBox(height: 8),
                Text(
                  'Materiales: ${dinero(presupuesto.costoMaterialesCentavos)}',
                ),
                Text(
                  'Gastos previstos: ${dinero(presupuesto.costoPrevistoCentavos - presupuesto.costoMaterialesCentavos)}',
                ),
                const Divider(height: 20),
                Text(
                  'Total previsto: ${dinero(presupuesto.costoPrevistoCentavos)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          if (_gastosPrevistos.isEmpty) ...[
            const SizedBox(height: 8),
            const Text('Puedes continuar sin agregar gastos previstos.'),
          ],
        ],
      ),
      _ => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [precio],
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
                      autovalidateMode: AutovalidateMode.disabled,
                      onChanged: () {
                        if (!_modificado) {
                          setState(() => _modificado = true);
                        }
                      },
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
            (_paso == 1 && _partidas.isEmpty) ||
            (_paso == 2 && _gastosPrevistos.isEmpty),
        alCancelar: _cancelar,
        alRetroceder: _retroceder,
        alAvanzar: _continuar,
        alGuardar: _guardar,
      ),
    ),
  );
}
