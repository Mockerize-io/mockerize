import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockerize/core/models/settings.dart';
import 'package:mockerize/core/models/storage.dart';
import 'package:mockerize/core/providers/mockerize.provider.dart';
import 'package:mockerize/core/utils/storage.dart';
import 'package:mockerize/main.dart';
import 'package:mockerize/modules/server/models/log.dart';
import 'package:mockerize/modules/server/models/server.dart';
import 'package:mockerize/modules/server/providers/log.provider.dart';
import 'package:mockerize/modules/server/providers/routers.provider.dart';
import 'package:mockerize/modules/server/providers/servers.provider.dart';

Future<void> loadApp(WidgetTester tester, {bool firstRun = false}) async {
  final List<Override> overrides = [];

  if (!firstRun) {
    // because loadApp technically reloads the app, we need to ensure that data
    // is persisted between reloads.
    final List<ServerStorage> loadedData =
        await load<ServerStorage>(StorageType.server);

    final Settings? settings = await load<Settings>(StorageType.settings);

    final List<LogStorage> loadedLogs = (settings?.loadLogs ?? true)
        ? await load<LogStorage>(StorageType.log)
        : [];

    overrides.addAll([
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
                ? Map.fromIterables(loadedData.map((e) => e.router.id).toList(),
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
    ]);
  }

  await tester.pumpWidget(ProviderScope(
    overrides: overrides,
    child: const MyApp(),
  ));

  // This is done to ensure that if in mobile the floating action button
  // has time to load in.
  await tester.pumpAndSettle();
}
