import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/coti_cubit.dart';
import '../../dominio/modelos.dart';
import '../../widgets/confirmar.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/surface_card.dart';
import 'formulario_cliente.dart';

// Lista de clientes reutilizables (P-021).
class ClientesPagina extends StatelessWidget {
  const ClientesPagina({super.key});

  Future<void> _editar(BuildContext context, [Cliente? cliente]) async {
    final cubit = context.read<CotiCubit>();
    final editado = await mostrarFormularioCliente(context, cliente: cliente);
    if (editado == null || !context.mounted) return;
    final guardado = await cubit.guardarCliente(editado);
    if (guardado && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cliente guardado.')));
    }
  }

  Future<void> _eliminar(BuildContext context, Cliente cliente) async {
    final cubit = context.read<CotiCubit>();
    final confirmado = await confirmarEliminacion(
      context,
      '¿Eliminar a ${cliente.nombre}? Sus cotizaciones conservan el nombre, '
      'pero dejarán de mostrar sus datos de contacto.',
    );
    if (confirmado) await cubit.eliminarCliente(cliente.id);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Clientes')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _editar(context),
      icon: const Icon(Icons.person_add_alt),
      label: const Text('Nuevo cliente'),
    ),
    body: BlocBuilder<CotiCubit, EstadoCoti>(
      builder: (context, estado) {
        final clientes = estado.datos.clientes;
        final cotizaciones = <int, int>{};
        for (final proyecto in estado.datos.proyectos) {
          final id = proyecto.clienteId;
          if (id != null) cotizaciones[id] = (cotizaciones[id] ?? 0) + 1;
        }
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
              children: [
                if (clientes.isEmpty)
                  const EstadoVacio(
                    icono: Icons.people_outline,
                    titulo: 'Aún no tienes clientes guardados',
                    mensaje:
                        'Se guardan solos al crear una cotización, o puedes '
                        'agregarlos aquí.',
                  ),
                for (final cliente in clientes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SurfaceCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          child: Text(cliente.nombre[0].toUpperCase()),
                        ),
                        title: Text(cliente.nombre),
                        subtitle: Text(
                          [
                            cliente.identificacion,
                            cliente.telefono,
                            cliente.correo,
                            '${cotizaciones[cliente.id] ?? 0} cotizaciones',
                          ].where((dato) => dato.isNotEmpty).join(' · '),
                        ),
                        onTap: () => _editar(context, cliente),
                        trailing: IconButton(
                          tooltip: 'Eliminar cliente',
                          onPressed: estado.guardando
                              ? null
                              : () => _eliminar(context, cliente),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
