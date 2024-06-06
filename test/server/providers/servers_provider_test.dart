import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockerize/modules/server/models/server.dart';
import 'package:mockerize/modules/server/providers/log.provider.dart';
import 'package:mockerize/modules/server/providers/routers.provider.dart';
import 'package:mockerize/modules/server/providers/servers.provider.dart';
import 'package:mockerize/modules/server/utils/port-check.dart';

import '../../mocks/log_provider.mock.dart';
import '../../mocks/routers_provider.mock.dart';
import '../../test-utils/provider_container.dart';

void main() {
  late ProviderContainer container;
  late ProviderSubscription srvProvider;
  setUp(() {
    // Because this is setUp and not setUpAll, we can
    // safely create our containers and providers
    // and it is ensured that they will be fresh for each test run.
    container = createContainer(overrides: [
      routersProvider.overrideWith(
        (ref) => MockRoutersProvider(ref, {}),
      ),
      logProvider.overrideWith((ref) => MockLogProvider(ref, {})),
    ]);
    TestWidgetsFlutterBinding.ensureInitialized();

    srvProvider = container.listen<Map<String, MockerizeServer>>(
        serversProvider, (_, __) {});
  });

  test('can create server', () async {
    final result = await container
        .read(serversProvider.notifier)
        .upsertServer("test server", "127.0.0.1", 65535);

    expect(result, isTrue);

    expect(srvProvider.read().keys, hasLength(1));
  });

  test('can update server', () async {
    await container
        .read(serversProvider.notifier)
        .upsertServer("test server", "127.0.0.1", 65535);

    await container.read(serversProvider.notifier).upsertServer(
        "updated server", "127.0.0.1", 65535,
        id: srvProvider.read().keys.first);

    // verify the new name
    expect(srvProvider.read().values.first.name, equals("updated server"));
  });

  test('can delete server', () async {
    await container
        .read(serversProvider.notifier)
        .upsertServer("test server", "127.0.0.1", 65535);

    await container
        .read(serversProvider.notifier)
        .deleteServer(srvProvider.read().keys.first);

    // verify the size of the state
    expect(srvProvider.read(), isEmpty);
  });

  test('can start/stop server', () async {
    await container
        .read(serversProvider.notifier)
        .upsertServer("test server", "127.0.0.1", 65535);

    await container
        .read(serversProvider.notifier)
        .startServer(srvProvider.read().keys.first);

    // verify the server is running
    expect(srvProvider.read().values.first.server, isNotNull);

    // check to make sure the port is in use
    await isPortInUse(
      srvProvider.read().values.first.port,
      address: srvProvider.read().values.first.address,
    ).then((value) {
      expect(value, isTrue);
    });

    // now stop and verify
    await container
        .read(serversProvider.notifier)
        .stopServer(srvProvider.read().keys.first);

    expect(srvProvider.read().values.first.server, isNull);

    await isPortInUse(
      srvProvider.read().values.first.port,
      address: srvProvider.read().values.first.address,
    ).then((value) {
      expect(value, isFalse);
    });
  });

  test('can make change to running server', () async {
    await container
        .read(serversProvider.notifier)
        .upsertServer("test server", "127.0.0.1", 65535);

    // start the server
    await container
        .read(serversProvider.notifier)
        .startServer(srvProvider.read().keys.first);

    // verify the server is running
    expect(srvProvider.read().values.first.server, isNotNull);

    // now update the server
    await container.read(serversProvider.notifier).upsertServer(
        "updated server", "127.0.0.1", 65535,
        id: srvProvider.read().keys.first);

    // verify the new name
    expect(srvProvider.read().values.first.name, equals("updated server"));

    // verify the server is still running
    expect(srvProvider.read().values.first.server, isNotNull);

    // make sure the port is still in use
    await isPortInUse(
      srvProvider.read().values.first.port,
      address: srvProvider.read().values.first.address,
    ).then((value) {
      expect(value, isTrue);
    });
  });

  test('can change port of running server', () async {
    await container
        .read(serversProvider.notifier)
        .upsertServer("test server", "127.0.0.1", 65535);

    // start the server
    await container
        .read(serversProvider.notifier)
        .startServer(srvProvider.read().keys.first);

    // verify the server is running
    expect(srvProvider.read().values.first.server, isNotNull);

    // now update the server
    await container.read(serversProvider.notifier).upsertServer(
        "test server", "127.0.0.1", 65534,
        id: srvProvider.read().keys.first);

    // verify that the old port is not in use
    await isPortInUse(
      65535,
      address: srvProvider.read().values.first.address,
    ).then((value) {
      expect(value, isFalse);
    });

    // verify the server is still running
    expect(srvProvider.read().values.first.server, isNotNull);

    // make sure the new port is in use
    await isPortInUse(
      65534,
      address: srvProvider.read().values.first.address,
    ).then((value) {
      expect(value, isTrue);
    });
  });

  test('mark server sets newLogs flag properly', () async {
    await container
        .read(serversProvider.notifier)
        .upsertServer("test server", "127.0.0.1", 65535);

    // check the newLogs flag
    expect(srvProvider.read().values.first.newLogs, isFalse);

    // mark the server
    await container
        .read(serversProvider.notifier)
        .markServer(srvProvider.read().keys.first, true);

    // check the newLogs flag
    expect(srvProvider.read().values.first.newLogs, isTrue);

    // call it again to make sure it doesn't change
    await container
        .read(serversProvider.notifier)
        .markServer(srvProvider.read().keys.first, true);

    expect(srvProvider.read().values.first.newLogs, isTrue);
  });

  test('refresh server just refreshes the state', () async {
    // close the srvListener so we can override it
    srvProvider.close();

    // override the server provider with a new instance

    srvProvider = container.listen<Map<String, MockerizeServer>>(
        serversProvider, (previous, next) {
      if (previous!.keys.isEmpty) {
        // this is the first call, we don't need to check anything
        return;
      }

      expect(jsonEncode(next.values.first),
          equals(jsonEncode(previous.values.first)));
    });

    await container
        .read(serversProvider.notifier)
        .upsertServer("test server", "127.0.0.1", 65535);

    // refresh the server
    await container
        .read(serversProvider.notifier)
        .refreshServer(srvProvider.read().keys.first);
  });
}
