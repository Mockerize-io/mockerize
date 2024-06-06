import 'package:flutter/material.dart';
import 'package:mockerize/modules/generic/layouts/log_settings.layout.dart';
import 'package:mockerize/modules/generic/layouts/theme_selection.layout.dart';

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Card(
            elevation: 0,
            clipBehavior: Clip.hardEdge,
            child: ExpansionTile(
              tilePadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
              title: const Text(
                "General Settings",
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              backgroundColor: Colors.black.withOpacity(0.1),
              collapsedBackgroundColor: colorScheme.surface,
              initiallyExpanded: true,
              children: [
                Container(
                  color: colorScheme.surface,
                  padding: const EdgeInsets.all(8.0),
                  child: const ThemeSelection(),
                ),
              ],
            ),
          ),
          Card(
            elevation: 0,
            clipBehavior: Clip.hardEdge,
            child: ExpansionTile(
              tilePadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
              title: const Text(
                "Log Settings",
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              backgroundColor: Colors.black.withOpacity(0.1),
              collapsedBackgroundColor: colorScheme.surface,
              initiallyExpanded: true,
              children: [
                Container(
                  color: colorScheme.surface,
                  padding: const EdgeInsets.all(8.0),
                  child: const LogsSettings(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
