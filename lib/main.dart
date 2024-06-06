// Global Imports
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockerize/core/models/settings.dart';
import 'package:mockerize/core/models/storage.dart';
import 'package:mockerize/core/providers/mockerize.provider.dart';
import 'package:mockerize/modules/server/models/log.dart';
import 'package:mockerize/modules/server/models/server.dart';
import 'package:mockerize/modules/server/providers/log.provider.dart';
// Relative Imports
import 'package:mockerize/core/router/router.dart';
import 'package:mockerize/modules/server/providers/routers.provider.dart';
import 'package:mockerize/modules/server/providers/servers.provider.dart';
import 'package:mockerize/core/utils/storage.dart';
import 'package:mockerize/theme/mockerize.theme.dart';
import 'package:window_size/window_size.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<ServerStorage> loadedData =
      await load<ServerStorage>(StorageType.server);

  final Settings? settings = await load<Settings>(StorageType.settings);

  final List<LogStorage> loadedLogs = (settings?.loadLogs ?? true)
      ? await load<LogStorage>(StorageType.log)
      : [];

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(600, 800));
  }

  runApp(
    ProviderScope(
      overrides: [
        mockerizeProvider.overrideWith((ref) => settings != null
            ? MockerizeProvider(
                ref,
                initialSettings: settings,
              )
            : MockerizeProvider(ref)),
        serversProvider.overrideWith((ref) => ServersProvider(
            ref,
            loadedData.isNotEmpty
                ? Map.fromIterables(
                    loadedData.map((e) => e.server.serverID).toList(),
                    loadedData.map((e) => e.server).toList())
                : {})),
        routersProvider.overrideWith((ref) {
          final provider = RoutersProvider(
              ref,
              loadedData.isNotEmpty
                  ? Map.fromIterables(
                      loadedData.map((e) => e.router.id).toList(),
                      loadedData.map((e) => e.router).toList())
                  : {});
          provider.initLoggers();
          return provider;
        }),
        logProvider.overrideWith((ref) => LogProvider(
            ref,
            loadedLogs.isNotEmpty
                ? Map.fromIterables(
                    loadedLogs.map((e) => e.serverId).toList(),
                    loadedLogs.map((e) => e.logs).toList(),
                  )
                : {})),
      ],
      child: const MyApp(),
    ),
  );
}

class _GlobalWrapper extends ConsumerWidget {
  const _GlobalWrapper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(serversProvider);
    ref.watch(routersProvider);
    ref.watch(logProvider);

    return child;
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(mockerizeProvider).themeMode;
    return _GlobalWrapper(
      child: MaterialApp.router(
        routerConfig: applicationRouter,
        theme: mockerizeLightTheme,
        darkTheme: mockerizeDarkTheme,
        themeMode: themeMode,
      ),
    );
  }
}
