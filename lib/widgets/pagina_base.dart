import 'package:flutter/material.dart';
import 'coti_header.dart';

class PaginaBase extends StatelessWidget {
  const PaginaBase({
    super.key,
    required this.titulo,
    required this.children,
    this.accion,
  });
  final String titulo;
  final List<Widget> children;
  final Widget? accion;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Column(
      children: [
        CotiHeader(title: titulo),
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: ListView(
                padding: EdgeInsets.all(
                  MediaQuery.sizeOf(context).width < 600 ? 16 : 24,
                ),
                children: [
                  if (accion != null) ...[
                    Align(alignment: Alignment.centerRight, child: accion!),
                    const SizedBox(height: 16),
                  ],
                  ...children,
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
