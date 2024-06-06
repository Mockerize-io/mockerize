import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockerize/core/models/storage.dart';
import 'package:mockerize/modules/server/models/header.dart';
import 'package:mockerize/modules/server/utils/port-check.dart';
import 'package:mockerize/modules/server/models/server.dart';
import 'package:mockerize/modules/server/providers/log.provider.dart';
import 'package:mockerize/modules/server/providers/routers.provider.dart';
import 'package:mockerize/core/utils/storage.dart';
import 'package:uuid/uuid.dart';

class ServersProvider extends StateNotifier<Map<String, MockerizeServer>> {
  final Ref ref;
  ServersProvider(this.ref, Map<String, MockerizeServer> data) : super(data);

  // List<MockerizeServer> get serverList {
  //   // Convert to a List
  //   final List<MockerizeServer> servers =
  //       state.entries.map((e) => e.value).toList();
  //   // Sort list a to z
  //   servers.sort((a, b) => a.name.compareTo(b.name));

  //   return servers;
  // }

  List<MockerizeServer> search(
      {reverseSort = false, bool active = false, String? query}) {
    // Convert to a List
    List<MockerizeServer> servers = state.entries.map((e) => e.value).toList();

    // Sort list a to z
    servers.sort((a, b) => a.name.compareTo(b.name));

    if (reverseSort) {
      servers = servers.reversed.toList();
    }

    if (active) {
      return servers.where((element) => element.server != null).toList();
    }

    if (query != null) {
      servers = servers
          .where((element) =>
              element.name.toLowerCase().contains(query!.toLowerCase()))
          .toList();
    }

    return servers;
  }

  Future<void> setState(String id, {MockerizeServer? server}) async {
    if (server == null) {
      state = {
        ...Map<String, MockerizeServer>.fromEntries(
            state.entries.where((element) => element.key != id)),
      };
    } else {
      state = {...state, id: server};
    }
  }

  Future<bool> upsertServer(String name, dynamic address, int port,
      {String? description, String? id, List<Header>? headers}) async {
    final originalServer = id != null ? state[id] : null;

    bool needsRestart = false;
    bool canRestart = false;
    bool valid = true;

    // Since we're upserting, it's possibile that the server may or may not exist
    if (originalServer == null ||
        (originalServer.address != address || originalServer.port != port)) {
      // Check to see if the port can be used
      valid = await canUsePort(port);

      // if the original server isn't null, then a listening
      // parameter has changed (either port or address)
      // and we'll need to restart the server.
      needsRestart = originalServer != null && originalServer.server != null;
    }

    if (!valid) {
      return false;
    }

    if (originalServer != null &&
        !needsRestart &&
        originalServer.server != null &&
        jsonEncode(originalServer.headers) != jsonEncode(headers)) {
      needsRestart = true;
    }

    // Re-use or create the server id and router ids
    final serverId = originalServer?.serverID ?? const Uuid().v4();
    final routerId = originalServer?.routerId ?? const Uuid().v4();

    if (needsRestart) {
      await originalServer!.server!.close();
      if (!await isPortInUse(port, address: address)) {
        canRestart = true;
      }
    }

    final server = MockerizeServer(
      serverID: serverId,
      address: address,
      port: port,
      name: name,
      routerId: routerId,
      // if we don't need to restart, then we can keep the original server
      // if the original server is null, then we can keep the server as null
      // otherwise we need to bind a new server, but only if the port and address
      // are available.
      server: !needsRestart
          ? originalServer == null
              ? null
              : state[id]!.server
          : canRestart
              ? await HttpServer.bind(
                  address,
                  port,
                )
              : null,
      description: description ?? originalServer?.description,
      headers: headers ?? originalServer?.headers ?? [],
    );

    // set the state

    await setState(serverId, server: server);

    // Now create (or update) a router

    await ref.read(routersProvider.notifier).upsertRouter(
          serverId,
          server: state[serverId]!.server,
          routerId: routerId,
          serverHeaders: state[serverId]!.headers,
        );

    // Start the router if we restarted (if the port isn't already being used)
    if (needsRestart && canRestart) {
      await ref
          .read(routersProvider.notifier)
          .startRouter(routerId, state[id]!.server!);
    }

    // Update the storaged data on the disk.
    await save(
      serverId,
      StorageType.server,
      ServerStorage(
          server: state[serverId]!,
          router: ref.read(routersProvider)[state[serverId]!.routerId]!),
    );

    return true;
  }

  Future<void> startServer(String id) async {
    final tmpServer = state[id]!;

    // Make sure the port is available
    if (await isPortInUse(tmpServer.port)) {
      // TODO if the port is in use by a server in mockerize, should we stop that server?
      return;
    }

    await setState(
      id,
      server: MockerizeServer(
        serverID: tmpServer.serverID,
        address: tmpServer.address,
        port: tmpServer.port,
        name: tmpServer.name,
        routerId: tmpServer.routerId,
        server: await HttpServer.bind(
          tmpServer.address,
          tmpServer.port,
        ),
        description: tmpServer.description,
        headers: tmpServer.headers,
      ),
    );

    await ref.read(routersProvider.notifier).startRouter(
          state[id]!.routerId,
          state[id]!.server!,
          serverHeaders: tmpServer.headers,
        );
  }

  Future<void> stopServer(String id) async {
    if (state[id]?.server == null) {
      return;
    }

    await state[id]!.server!.close();

    await setState(
      id,
      server: MockerizeServer(
        serverID: id,
        address: state[id]!.address,
        port: state[id]!.port,
        name: state[id]!.name,
        routerId: state[id]!.routerId,
        server: null,
        description: state[id]!.description,
        headers: state[id]!.headers,
      ),
    );

    await ref.read(routersProvider.notifier).stopRouter(state[id]!.routerId);
  }

  // Used by routers provider to ensure that
  // changes get applied.
  Future<void> refreshServer(String id) async {
    await setState(
      id,
      server: MockerizeServer(
        serverID: id,
        address: state[id]!.address,
        port: state[id]!.port,
        name: state[id]!.name,
        routerId: state[id]!.routerId,
        server: state[id]!.server,
        description: state[id]!.description,
        headers: state[id]!.headers,
      ),
    );
  }

  // marks the server to indicate if it has new logs or not.
  Future<void> markServer(String id, bool status) async {
    // if the status is the same, don't do anything.
    if ((state[id]?.newLogs ?? false) == status) {
      return;
    }

    await setState(
      id,
      server: MockerizeServer(
        serverID: id,
        address: state[id]!.address,
        port: state[id]!.port,
        name: state[id]!.name,
        routerId: state[id]!.routerId,
        server: state[id]!.server,
        description: state[id]!.description,
        headers: state[id]!.headers,
        newLogs: status,
      ),
    );
  }

  Future<void> deleteServer(String id) async {
    await state[id]!.server?.close();
    // Delete the router after closing the server
    await ref.read(routersProvider.notifier).deleteRouter(state[id]!.routerId);
    // Delete the logs next
    await ref.read(logProvider.notifier).deleteServer(id);
    // Finally delete the server from the state
    await setState(id);

    // Update the storaged data on the disk.
    await delete(id, StorageType.server);
  }

  @override
  void dispose() {
    // Close all the servers
    state.forEach((key, value) async {
      // Despite the provider being disposed, the port & address binding
      // would still be active, this ensures that it is removed
      // before the entire provider is disposed.
      await value.server?.close();
    });
    super.dispose();
  }
}

final serversProvider = StateNotifierProvider.autoDispose<ServersProvider,
    Map<String, MockerizeServer>>(
  (ref) => ServersProvider(ref, {}),
);
