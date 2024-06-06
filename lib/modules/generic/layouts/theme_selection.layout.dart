import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockerize/core/providers/mockerize.provider.dart';

class ThemeSelection extends ConsumerStatefulWidget {
  const ThemeSelection({super.key});

  @override
  ConsumerState<ThemeSelection> createState() => _ThemeSelectionState();
}

class _ThemeSelectionState extends ConsumerState<ThemeSelection> {
  bool localThemeMode = false;

  @override
  void initState() {
    final themeMode = ref.read(mockerizeProvider).themeMode;
    setLocalTheme(themeMode);

    super.initState();
  }

  void setLocalTheme(ThemeMode themeMode) {
    setState(() {
      localThemeMode = themeMode == ThemeMode.system
          ? SchedulerBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          : themeMode == ThemeMode.dark
              ? true
              : false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(mockerizeProvider).themeMode;

    final WidgetStateProperty<Icon?> thumbIcon =
        WidgetStateProperty.resolveWith<Icon?>(
      (Set<WidgetState> states) {
        if (themeMode == ThemeMode.system) {
          // use platformBrightness to determine icon
          return MediaQuery.of(context).platformBrightness == Brightness.dark
              ? const Icon(Icons.dark_mode)
              : const Icon(Icons.light_mode);
        }

        if (themeMode == ThemeMode.dark) {
          return const Icon(Icons.dark_mode);
        }
        return const Icon(Icons.light_mode);
      },
    );

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Text('Theme Selection'),
            const Spacer(),
            Switch(
              thumbIcon: thumbIcon,
              value: localThemeMode,
              onChanged: (bool value) {
                final themeMode = value ? ThemeMode.dark : ThemeMode.light;
                ref.read(mockerizeProvider.notifier).setGlobalTheme(themeMode);
                setLocalTheme(themeMode);
              },
            ),
          ],
        ),
      ),
    );
  }
}
