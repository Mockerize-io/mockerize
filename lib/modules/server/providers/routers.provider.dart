import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockerize/core/models/storage.dart';
import 'package:mockerize/modules/server/components/mockerize-router.dart';
import 'package:mockerize/modules/server/models/endpoint.dart';
import 'package:mockerize/modules/server/models/header.dart';
import 'package:mockerize/modules/server/models/log.dart';
import 'package:mockerize/modules/server/models/server.dart';
import 'package:mockerize/modules/server/providers/log.provider.dart';
import 'package:mockerize/modules/server/providers/servers.provider.dart';
import 'package:mockerize/core/utils/storage.dart';
import 'package:uuid/uuid.dart';

class RoutersProvider extends StateNotifier<Map<String, MockerizeRouter>> {
  final Ref ref;

  RoutersProvider(this.ref, Map<String, MockerizeRouter> data) : super(data);

  Future<void> setState(String id, {MockerizeRouter? router}) async {
    if (router == null) {
      state = {
        ...Map<String, MockerizeRouter>.fromEntries(
            state.entries.where((element) => element.key != id)),
      };
    } else {
      state = {...state, id: router};
    }
  }

  Future<void> _logger(
      String serverId, String routerId, ResponseLog log) async {
    await ref.read(logProvider.notifier).addLog(serverId, log);

    if (log.routeId != null) {
      var tmpRouter = state[routerId]!;

      final routeIndex =
          tmpRouter.routes.indexWhere((route) => route.id == log.routeId);

      if (routeIndex != -1) {
        tmpRouter.routes[routeIndex].hitCount++;
      }
      // Not sure if this will work, map is immutable, and we might need
      // to do a brand new object, which means the handler might not be running.
      await setState(routerId, router: tmpRouter);
      // mark the server as having new logs.
      await ref.read(serversProvider.notifier).markServer(serverId, true);
    }
  }

  Future<void> _restart(String serverID, bool refresh) async {
    if (refresh) {
      await ref.read(serversProvider.notifier).refreshServer(serverID);
      return;
    }

    await ref.read(serversProvider.notifier).stopServer(serverID);
    await ref.read(serversProvider.notifier).startServer(serverID);
  }

  /// THIS SHOULD ONLY BE CALLED FROM MAIN.DART
  /// IT IS A WORKAROUND FOR GETTING THE LOGGER LOADED
  /// INTO EACH ROUTER.
  void initLoggers() {
    state = {
      ...state.map(
        (key, value) => MapEntry(
          key,
          MockerizeRouter(
            id: value.id,
            serverId: value.serverId,
            routes: value.routes,
            logger: _logger,
            restarter: _restart,
            serverHeaders: [],
          ),
        ),
      )
    };
  }

  Future<void> _save(String routerID) async {
    await save(
      state[routerID]!.serverId,
      StorageType.server,
      ServerStorage(
        server: ref.read(serversProvider)[state[routerID]!.serverId]!,
        router: state[routerID]!,
      ),
    );
  }

  Future<void> upsertRouter(
    String serverId, {
    HttpServer? server,
    String? routerId,
    List<Header>? serverHeaders,
  }) async {
    // either new or existing
    final id = routerId ?? const Uuid().v4();
    final activeResponseId = const Uuid().v4(); // temp testing
    await setState(
      id,
      router: MockerizeRouter(
        id: id,
        serverId: state[id]?.serverId ?? serverId,
        routes: state[id]?.routes ??
            [
              ServerRoute(
                path: "/",
                activeResponse: activeResponseId,
                responses: [
                  Response(
                    id: activeResponseId,
                    name: "Default response",
                    status: Status.ok,
                    response: "This is the index!",
                    responseType: ResponseType.text,
                    active: true,
                    headers: [],
                  )
                ],
                method: Method.get,
                headers: [],
              ),
            ],
        logger: _logger,
        restarter: _restart,
        server: server,
        serverHeaders: serverHeaders ?? state[id]?.serverHeaders ?? [],
      ),
    );
  }

  // This is to only be called from the servers provider.
  Future<void> startRouter(
    String routerId,
    HttpServer server, {
    List<Header>? serverHeaders,
  }) async {
    var tmpRouter = state[routerId];
    // update the router
    await setState(
      routerId,
      router: MockerizeRouter(
        id: routerId,
        serverId: tmpRouter!.serverId,
        routes: tmpRouter.routes,
        logger: _logger,
        restarter: _restart,
        server: server,
        serverHeaders: serverHeaders ?? tmpRouter.serverHeaders,
      ),
    );

    // Start the router
    state[routerId]!.start();
  }

  Future<void> stopRouter(String routerId) async {
    var tmpRouter = state[routerId];
    // update the router
    await setState(
      routerId,
      router: MockerizeRouter(
        id: routerId,
        serverId: tmpRouter!.serverId,
        routes: tmpRouter.routes,
        logger: _logger,
        restarter: _restart,
        server: null,
        serverHeaders: tmpRouter.serverHeaders,
      ),
    );
  }

  Future<void> deleteRouter(String id) async {
    await setState(id);
  }

  MockerizeRouter? getByServerID(String serverID) {
    return state.entries
        .firstWhereOrNull((router) => router.value.serverId == serverID)
        ?.value;
  }

  Future<void> setActiveResponse(
      String routerID, String routeID, String responseID) async {
    // Grab the router the route/response is for
    final tmpRouter = state[routerID];

    if (tmpRouter == null) {
      // This shouldn't be null, if it is, then something
      // broke down.
      return;
    }

    final newRoutes = tmpRouter.routes.map((route) {
      // We only care about the route we're modifying, leave unrelated ones
      // unmodified.
      if (route.id != routeID) {
        return route;
      }

      // Recreate the ServerRoute with almost everything the same
      // except for the responses list and active response field
      return ServerRoute(
        path: route.path,
        responses: route.responses.map((response) {
          response.active = response.id == responseID;
          return response;
        }).toList(),
        activeResponse: responseID,
        method: route.method,
        hitCount: route.hitCount,
        routeId: route.id,
        headers: route.headers,
      );
    }).toList();

    await setState(routerID,
        router: MockerizeRouter(
          id: tmpRouter.id,
          serverId: tmpRouter.serverId,
          routes: newRoutes,
          logger: tmpRouter.logger,
          restarter: tmpRouter.restarter,
          server: tmpRouter.server,
          serverHeaders: tmpRouter.serverHeaders,
        ));

    // restart the server (or refresh if not running)
    await _restart(tmpRouter.serverId, tmpRouter.server == null);

    // update the saved data on disk
    await _save(routerID);
  }

  Future<void> deleteRoute(
    String routerID,
    String routeID,
  ) async {
    // Grab the router the route being deleted is under
    final tmpRouter = state[routerID];

    if (tmpRouter == null) {
      // This shouldn't be null, if it is, then something
      // broke down.
      return;
    }

    // create the new list of routes
    final newRoutes =
        tmpRouter.routes.where((route) => route.id != routeID).toList();

    await setState(
      routerID,
      router: MockerizeRouter(
        id: tmpRouter.id,
        serverId: tmpRouter.serverId,
        routes: newRoutes,
        logger: tmpRouter.logger,
        restarter: tmpRouter.restarter,
        server: tmpRouter.server,
        serverHeaders: tmpRouter.serverHeaders,
      ),
    );

    // restart the server (or refresh if not running) to apply changes
    await _restart(tmpRouter.serverId, tmpRouter.server == null);

    // update the saved data on disk
    await _save(routerID);
  }

  Future<bool> upsertRoute(String routerID, ServerRoute route) async {
    // Grab the router the route being added to is under
    final tmpRouter = state[routerID];

    if (tmpRouter == null) {
      // This shouldn't be null, if it is, then something
      // broke down.
      return false;
    }

    // Search for the route's ID to see if it exists

    final routeIndex = tmpRouter.routes.indexWhere((r) => r.id == route.id);

    List<ServerRoute> tmpRoutes = [...tmpRouter.routes];

    if (routeIndex == -1) {
      // we're inserting a new route
      tmpRoutes.add(route);
    } else {
      // we're updating an existing one
      route.hitCount = tmpRoutes[routeIndex].hitCount;
      tmpRoutes[routeIndex] = route;
    }

    await setState(
      routerID,
      router: MockerizeRouter(
        id: tmpRouter.id,
        server: tmpRouter.server,
        serverId: tmpRouter.serverId,
        routes: tmpRoutes,
        logger: tmpRouter.logger,
        restarter: tmpRouter.restarter,
        serverHeaders: tmpRouter.serverHeaders,
      ),
    );

    // restart the server (or refresh if not running) to apply changes
    await _restart(tmpRouter.serverId, tmpRouter.server == null);

    // update the saved data on disk
    await _save(routerID);

    return true;
  }
}

final routersProvider = StateNotifierProvider.autoDispose<RoutersProvider,
    Map<String, MockerizeRouter>>((ref) => RoutersProvider(ref, {}));
