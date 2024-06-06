import 'package:flutter/material.dart';

class AddressPortBadge extends StatelessWidget {
  final String address;
  final String port;
  final bool active;
  final AlignmentGeometry? alignment;
  const AddressPortBadge({
    super.key,
    required this.address,
    required this.port,
    required this.active,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomRight,
      width: alignment != null ? null : 156,
      child: Transform.scale(
        scale: 1.3,
        alignment: alignment ?? Alignment.centerRight,
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
            backgroundColor:
                active ? Colors.white : Theme.of(context).colorScheme.onSurface,
            label: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    right: 8,
                  ),
                  child: Text(
                    address,
                    style: TextStyle(
                      color: active
                          ? Colors.black
                          : Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
                Badge(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  backgroundColor: active ? Colors.blue : Colors.grey,
                  // textColor: Theme.of(context).colorScheme.onSurface,
                  textColor: Colors.white,
                  label: Text(port),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
