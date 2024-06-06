import 'package:flutter/material.dart';
import 'package:mockerize/modules/server/models/endpoint.dart';

class LogTitleBadge extends StatelessWidget {
  final DateTime date;
  final Method method;

  const LogTitleBadge({
    super.key,
    required this.date,
    required this.method,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final dateString = date.toLocal().toString().split('.')[0];
    return Transform.scale(
      scale: 1,
      alignment: Alignment.centerRight,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
            width: 4,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Badge(
          // offset: Offset.infinite,
          padding: const EdgeInsets.only(
            left: 8,
            right: 0,
          ),
          backgroundColor: colorScheme.surfaceContainerHighest,
          label: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  right: 8,
                ),
                child: Text(
                  dateString,
                  style: TextStyle(
                    color: colorScheme.inverseSurface,
                  ),
                ),
              ),
              Badge(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                backgroundColor: colorScheme.primary,
                // textColor: Theme.of(context).colorScheme.onSurface,
                textColor: colorScheme.onPrimary,
                label: Text(
                  method.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
