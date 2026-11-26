import 'package:flutter/material.dart';

import 'componentes/pagina_bienvenida.dart';
import 'contenido_bienvenida.dart';

// Tutorial rápido de la primera vez; también se abre desde Mi perfil.
class PantallaBienvenida extends StatefulWidget {
  const PantallaBienvenida({super.key, required this.alTerminar});

  // Recibe true si el usuario quiere configurar su negocio.
  final ValueChanged<bool> alTerminar;

  @override
  State<PantallaBienvenida> createState() => _PantallaBienvenidaState();
}

class _PantallaBienvenidaState extends State<PantallaBienvenida> {
  final _paginas = PageController();
  int _actual = 0;

  bool get _esUltima => _actual == pasosBienvenida.length - 1;

  @override
  void dispose() {
    _paginas.dispose();
    super.dispose();
  }

  void _siguiente() => _paginas.nextPage(
    duration: const Duration(milliseconds: 350),
    curve: Curves.easeOutCubic,
  );

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: AnimatedOpacity(
                  opacity: _esUltima ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: TextButton(
                    onPressed: _esUltima
                        ? null
                        : () => widget.alTerminar(false),
                    child: const Text('Saltar'),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _paginas,
                itemCount: pasosBienvenida.length,
                onPageChanged: (indice) => setState(() => _actual = indice),
                itemBuilder: (context, indice) {
                  final paso = pasosBienvenida[indice];
                  return PaginaBienvenida(
                    escena: paso.escena,
                    titulo: paso.titulo,
                    texto: paso.texto,
                    activa: indice == _actual,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < pasosBienvenida.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _actual ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _actual
                                ? colores.primary
                                : colores.outlineVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: _esUltima
                        ? Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => widget.alTerminar(true),
                                icon: const Icon(Icons.storefront_outlined),
                                label: const Text('Configurar mi negocio'),
                              ),
                              FilledButton(
                                onPressed: () => widget.alTerminar(false),
                                child: const Text('Empezar'),
                              ),
                            ],
                          )
                        : SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _siguiente,
                              child: const Text('Siguiente'),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
