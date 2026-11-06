import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class ObraProHeader extends StatelessWidget {
  const ObraProHeader({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.cobalt,
            child: Icon(Icons.construction, size: 22, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'OBRAPRO',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Tooltip(
            message: 'Tus datos se guardan en este dispositivo',
            child: Chip(
              avatar: Icon(Icons.offline_pin_outlined, size: 16),
              label: Text('Local'),
            ),
          ),
        ],
      ),
    ),
  );
}
