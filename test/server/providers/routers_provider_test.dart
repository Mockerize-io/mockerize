import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockerize/modules/server/components/mockerize-router.dart';
import 'package:mockerize/modules/server/models/server.dart';
import 'package:mockerize/modules/server/providers/log.provider.dart';
import 'package:mockerize/modules/server/providers/routers.provider.dart';
import 'package:mockerize/modules/server/providers/servers.provider.dart';

import '../../mocks/log_provider.mock.dart';
import '../../mocks/servers_provider.mock.dart';
import '../../test-utils/data_generator.dart';
import '../../test-utils/provider_container.dart';

void main() {
  late ProviderContainer container;
  late ProviderSubscription<Map<String, MockerizeRouter>> rtrProvider;
  setUp(() {
    container = createContainer(
      overrides: [
        serversProvider.overrideWith((ref) => MockServersProvider(ref, {
              "abc123": const MockerizeServer(
                address: "127.0.0.1",
                serverID: "abc123",
                port: 65535,
                name: 'test',
                routerId: 'abc123',
                server: null,
                headers: [],
              )
            })),
        logProvider.overrideWith((ref) => MockLogProvider(ref, {})),
      ],
    );

    TestWidgetsFlutterBinding.ensureInitialized();

    rtrProvider = container.listen<Map<String, MockerizeRouter>>(
        routersProvider, (_, __) {});
  });

  test('can create/update a router', () async {
    // upsert a router
    await container.read(routersProvider.notifier).upsertRouter("abc123");

    // verify the router was created
    expect(rtrProvider.read().keys, hasLength(1));
    // verify headers are empty
    expect(rtrProvider.read().values.first.serverHeaders, isEmpty);

    final header = createHeader();
    // upsert with server header
    await container.read(routersProvider.notifier).upsertRouter("abc123",
        serverHeaders: [header], routerId: rtrProvider.read().keys.first);

    // verify the router was updated
    expect(rtrProvider.read().values.first.serverHeaders, isNotEmpty);

    // verify the header was added
    expect(rtrProvider.read().values.first.serverHeaders.first, equals(header));
  });

  test('can start/stop router', () async {
    // bind an http server
    final srv = await HttpServer.bind("127.0.0.1", 65535);

    // upsert a router
    await container.read(routersProvider.notifier).upsertRouter("abc123");

    // verify that the router server is null
    expect(rtrProvider.read().values.first.server, isNull);

    // start the router
    await container
        .read(routersProvider.notifier)
        .startRouter(rtrProvider.read().keys.first, srv);

    // verify the router server is not null
    expect(rtrProvider.read().values.first.server, isNotNull);

    // stop the router
    await container
        .read(routersProvider.notifier)
        .stopRouter(rtrProvider.read().keys.first);

    // verify the router server is null
    expect(rtrProvider.read().values.first.server, isNull);

    // close the http server
    await srv.close();
  });

  test('can delete a router', () async {
    // upsert a router
    await container.read(routersProvider.notifier).upsertRouter("abc123");

    // verify the router was created
    expect(rtrProvider.read().keys, hasLength(1));

    // delete the router
    await container
        .read(routersProvider.notifier)
        .deleteRouter(rtrProvider.read().keys.first);

    // verify the router was deleted
    expect(rtrProvider.read(), isEmpty);
  });

  test('can get router by server id', () async {
    // upsert a router
    await container.read(routersProvider.notifier).upsertRouter("abc123");

    // verify the router was created
    expect(rtrProvider.read().keys, hasLength(1));

    // get the router by server id
    final router =
        container.read(routersProvider.notifier).getByServerID("abc123");

    // verify the router was found
    expect(router, isNotNull);
  });

  test('can create/update a route', () async {
    // upsert a router
    await container.read(routersProvider.notifier).upsertRouter("abc123");

    // create a route
    final route = createRoute();

    // upsert the route
    await container
        .read(routersProvider.notifier)
        .upsertRoute(rtrProvider.read().keys.first, route);

    // verify the route was created
    expect(rtrProvider.read().values.first.routes, hasLength(2));

    expect(rtrProvider.read().values.first.routes.last, equals(route));

    // update the route
    await container.read(routersProvider.notifier).upsertRoute(
          rtrProvider.read().keys.first,
          createRoute(path: "/test-123456", id: route.id),
        );

    // verify the route was updated
    expect(rtrProvider.read().values.first.routes.last.path, "/test-123456");
  });

  test('can delete a route', () async {
    // upsert a router
    await container.read(routersProvider.notifier).upsertRouter("abc123");

    // create a route
    final route = createRoute();

    // upsert the route
    await container
        .read(routersProvider.notifier)
        .upsertRoute(rtrProvider.read().keys.first, route);

    // verify the route was created
    expect(rtrProvider.read().values.first.routes, hasLength(2));

    // delete the route
    await container
        .read(routersProvider.notifier)
        .deleteRoute(rtrProvider.read().keys.first, route.id);

    // verify the route was deleted
    expect(rtrProvider.read().values.first.routes, hasLength(1));
  });

  test('can set active response', () async {
    // upsert a router
    await container.read(routersProvider.notifier).upsertRouter("abc123");

    // create a route
    final route = createRoute();

    // upsert the route
    await container
        .read(routersProvider.notifier)
        .upsertRoute(rtrProvider.read().keys.first, route);

    // verify the route was created
    expect(rtrProvider.read().values.first.routes, hasLength(2));

    // set the active response
    await container.read(routersProvider.notifier).setActiveResponse(
        rtrProvider.read().keys.first, route.id, route.responses.first.id);

    // verify the active response was set
    expect(rtrProvider.read().values.first.routes.last.activeResponse,
        route.responses.first.id);
  });
}
