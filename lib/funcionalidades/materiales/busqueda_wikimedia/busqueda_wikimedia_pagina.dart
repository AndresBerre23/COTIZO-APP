import 'package:flutter/material.dart';
import 'package:coti/core/enfoque.dart';

import '../componentes/detalle_atribucion_imagen.dart';
import 'imagen_wikimedia.dart';
import 'miniatura_wikimedia.dart';
import 'servicio_wikimedia.dart';

class BusquedaWikimediaPagina extends StatefulWidget {
  const BusquedaWikimediaPagina({
    super.key,
    required this.consultaInicial,
    this.servicio,
  });

  final String consultaInicial;
  final ServicioWikimedia? servicio;

  @override
  State<BusquedaWikimediaPagina> createState() =>
      _BusquedaWikimediaPaginaState();
}

class _BusquedaWikimediaPaginaState extends State<BusquedaWikimediaPagina> {
  late final TextEditingController _consulta;
  late final ServicioWikimedia _servicio;
  final List<ImagenWikimedia> _imagenes = [];
  bool _cargando = false;
  String? _error;
  int? _siguienteOffset;
  ImagenWikimedia? _descargando;

  @override
  void initState() {
    super.initState();
    _consulta = TextEditingController(text: widget.consultaInicial);
    _servicio = widget.servicio ?? ServicioWikimedia();
    if (_consulta.text.trim().isNotEmpty) _buscar();
  }

  @override
  void dispose() {
    _consulta.dispose();
    if (widget.servicio == null) _servicio.cerrar();
    super.dispose();
  }

  Future<void> _buscar({bool siguiente = false}) async {
    if (_cargando || _descargando != null) return;
    final consulta = _consulta.text.trim();
    if (consulta.isEmpty) {
      setState(() => _error = 'Escribe el nombre de un material.');
      return;
    }
    final offset = siguiente ? _siguienteOffset : null;
    setState(() {
      _cargando = true;
      _error = null;
      if (!siguiente) {
        _imagenes.clear();
        _siguienteOffset = null;
      }
    });
    try {
      final pagina = await _servicio.buscar(consulta, offset: offset ?? 0);
      if (!mounted) return;
      setState(() {
        _imagenes.addAll(pagina.imagenes);
        _siguienteOffset = pagina.siguienteOffset;
        _cargando = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = error is ErrorWikimedia
            ? error.mensaje
            : 'No se pudo buscar. Revisa tu conexión e intenta otra vez.';
      });
    }
  }

  Future<void> _previsualizar(ImagenWikimedia imagen) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          imagen.titulo,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 220,
                child: MiniaturaWikimedia(
                  imagen: imagen,
                  servicio: _servicio,
                  ajuste: BoxFit.contain,
                ),
              ),
              DetalleAtribucionImagen(atribucion: imagen.atribucion),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Usar esta imagen'),
          ),
        ],
      ),
    );
    if (confirmar == true) await _descargar(imagen);
  }

  Future<void> _descargar(ImagenWikimedia imagen) async {
    setState(() {
      _descargando = imagen;
      _error = null;
    });
    try {
      final bytes = await _servicio.descargar(imagen);
      if (!mounted) return;
      Navigator.pop(
        context,
        ImagenWikimediaElegida(bytes: bytes, atribucion: imagen.atribucion),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _descargando = null;
        _error = error is ErrorWikimedia
            ? error.mensaje
            : 'No se pudo descargar la imagen. Intenta con otra.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Buscar en Wikimedia Commons')),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onTapOutside: cerrarFocoAlTocarFuera,
              controller: _consulta,
              maxLength: 100,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _buscar(),
              decoration: InputDecoration(
                labelText: 'Nombre del material',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Buscar',
                  onPressed: _cargando ? null : _buscar,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
            ),
            if (_cargando && _imagenes.isEmpty)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_error != null && _imagenes.isEmpty)
              Expanded(child: _estado(_error!, Icons.wifi_off_outlined))
            else if (_imagenes.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('No hay imágenes con licencia compatible.'),
                ),
              )
            else
              Expanded(
                child: LayoutBuilder(
                  builder: (context, limites) {
                    final columnas = limites.maxWidth >= 720 ? 3 : 2;
                    return GridView.builder(
                      itemCount:
                          _imagenes.length + (_siguienteOffset == null ? 0 : 1),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columnas,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.82,
                      ),
                      itemBuilder: (context, indice) {
                        if (indice == _imagenes.length) {
                          return Center(
                            child: OutlinedButton(
                              onPressed: _cargando
                                  ? null
                                  : () => _buscar(siguiente: true),
                              child: Text(_cargando ? 'Cargando…' : 'Ver más'),
                            ),
                          );
                        }
                        return _tarjeta(_imagenes[indice]);
                      },
                    );
                  },
                ),
              ),
            if (_error != null && _imagenes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (_descargando != null) const LinearProgressIndicator(),
          ],
        ),
      ),
    ),
  );

  Widget _tarjeta(ImagenWikimedia imagen) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: _descargando == null ? () => _previsualizar(imagen) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: MiniaturaWikimedia(imagen: imagen, servicio: _servicio),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              imagen.titulo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Text(
              imagen.atribucion.licencia,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _estado(String mensaje, IconData icono) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 36),
        const SizedBox(height: 12),
        Text(mensaje, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _buscar,
          child: const Text('Intentar de nuevo'),
        ),
      ],
    ),
  );
}
