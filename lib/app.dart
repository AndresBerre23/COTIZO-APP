import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'aplicacion/control_datos_app.dart';
import 'aplicacion/coti_cubit.dart';
import 'aplicacion/preferencias_cubit.dart';
import 'core/theme/app_theme.dart';
import 'datos/repositorio_sqlite.dart';
import 'dominio/repositorio_local.dart';
import 'dominio/modelos.dart';
import 'funcionalidades/arranque/componentes/cortina_arranque.dart';
import 'funcionalidades/arranque/pantalla_arranque.dart';
import 'funcionalidades/bienvenida/puerta_bienvenida.dart';
import 'funcionalidades/navegacion/navegacion_principal.dart';
import 'funcionalidades/seguridad/puerta_bloqueo.dart';
import 'funcionalidades/seguridad/servicio_autenticacion.dart';
import 'widgets/estado_vacio.dart';

// Repositorio abierto y preferencias leídas al iniciar.
typedef _DatosIniciales = (RepositorioLocal, PreferenciasApp);

class CotiApp extends StatefulWidget {
  const CotiApp({
    super.key,
    this.repositorio,
    this.autenticacion = const ServicioAutenticacion(),
  });
  final RepositorioLocal? repositorio;

  // Inyectable para pruebas, donde no hay sensor de huella.
  final ServicioAutenticacion autenticacion;
  @override
  State<CotiApp> createState() => _CotiAppState();
}

class _CotiAppState extends State<CotiApp> {
  late Future<_DatosIniciales> _carga;
  late Future<RepositorioLocal> _apertura;
  bool _almacenamientoAbierto = false;
  bool _arranqueTerminado = false;
  String? _avisoPendiente;
  final _mensajero = GlobalKey<ScaffoldMessengerState>();
  @override
  void initState() {
    super.initState();
    _abrir();
  }

  void _abrir() {
    _almacenamientoAbierto = false;
    _apertura = widget.repositorio != null
        ? Future.value(widget.repositorio!)
        : RepositorioSqlite.abrir();
    _cargarPreferencias();
  }

  void _cargarPreferencias() {
    _carga = _apertura.then((repositorio) async {
      _almacenamientoAbierto = true;
      return (repositorio, await repositorio.obtenerPreferencias());
    });
  }

  Future<void> _reemplazarDatos(Future<void> Function() tarea) async {
    await (await _apertura).cerrar();
    try {
      await tarea();
      _avisoPendiente = 'Respaldo restaurado.';
    } catch (_) {
      // La copia previa queda en el almacenamiento interno de la app.
      _avisoPendiente = 'No se pudo restaurar el respaldo.';
    } finally {
      if (mounted) {
        setState(() {
          _arranqueTerminado = false;
          _abrir();
        });
      }
    }
  }

  void _mostrarAvisoPendiente() {
    final aviso = _avisoPendiente;
    if (aviso == null) return;
    _avisoPendiente = null;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) =>
          _mensajero.currentState?.showSnackBar(SnackBar(content: Text(aviso))),
    );
  }

  void _reintentar() =>
      setState(_almacenamientoAbierto ? _cargarPreferencias : _abrir);

  Widget _aplicacion(Widget inicio, {ThemeMode modoTema = ThemeMode.system}) =>
      MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Coti',
        theme: appTheme,
        darkTheme: darkAppTheme,
        themeMode: modoTema,
        scaffoldMessengerKey: _mensajero,
        locale: const Locale('es'),
        supportedLocales: const [Locale('es')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: inicio,
      );

  Widget _aplicacionConPreferencias(Widget inicio) =>
      BlocBuilder<PreferenciasCubit, PreferenciasApp>(
        builder: (context, preferencias) => _aplicacion(
          inicio,
          modoTema: switch (preferencias.modoTema) {
            ModoTema.sistema => ThemeMode.system,
            ModoTema.claro => ThemeMode.light,
            ModoTema.oscuro => ThemeMode.dark,
          },
        ),
      );

  @override
  Widget build(BuildContext context) => FutureBuilder<_DatosIniciales>(
    future: _carga,
    builder: (context, resultado) {
      if (resultado.hasError) return _aplicacion(_pantallaError());
      if (!resultado.hasData || !_arranqueTerminado) {
        return _aplicacion(
          PantallaArranque(
            alTerminar: () {
              if (mounted) setState(() => _arranqueTerminado = true);
            },
          ),
        );
      }
      final (repositorio, preferencias) = resultado.data!;
      return _aplicacionConDatos(repositorio, preferencias);
    },
  );

  Widget _pantallaError() => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: _almacenamientoAbierto
              ? EstadoVacio(
                  icono: Icons.settings_outlined,
                  titulo: 'No se pudieron cargar tus ajustes',
                  mensaje: 'Vuelve a intentar. Tus datos siguen guardados.',
                  accion: FilledButton(
                    onPressed: _reintentar,
                    child: const Text('Reintentar'),
                  ),
                )
              : EstadoVacio(
                  icono: Icons.storage_outlined,
                  titulo: 'No se pudo abrir el almacenamiento',
                  mensaje:
                      'Vuelve a intentar. No se eliminará ningún registro.',
                  accion: FilledButton(
                    onPressed: _reintentar,
                    child: const Text('Reintentar'),
                  ),
                ),
        ),
      ),
    ),
  );

  Widget _aplicacionConDatos(
    RepositorioLocal repositorio,
    PreferenciasApp preferencias,
  ) {
    _mostrarAvisoPendiente();
    return ControlDatosApp(
      prepararRespaldo: repositorio.prepararRespaldo,
      reemplazarDatos: _reemplazarDatos,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => CotiCubit(repositorio)..cargar()),
          BlocProvider(
            create: (_) =>
                PreferenciasCubit(repositorio, inicial: preferencias),
          ),
        ],
        child: BlocListener<CotiCubit, EstadoCoti>(
          listenWhen: (anterior, actual) =>
              actual.error != null && anterior.error != actual.error,
          listener: (_, estado) => _mensajero.currentState?.showSnackBar(
            SnackBar(content: Text(estado.error!)),
          ),
          child: _aplicacionConPreferencias(
            CortinaArranque(
              child: PuertaBloqueo(
                servicio: widget.autenticacion,
                child: PuertaBienvenida(
                  servicio: widget.autenticacion,
                  child: const NavegacionPrincipal(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
