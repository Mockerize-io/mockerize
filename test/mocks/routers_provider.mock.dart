import 'dart:io';

import 'package:mockerize/modules/server/components/mockerize-router.dart';
import 'package:mockerize/modules/server/models/header.dart';
import 'package:mockerize/modules/server/providers/routers.provider.dart';

class MockRoutersProvider extends RoutersProvider {
  MockRoutersProvider(super.ref, super.data);

  @override
  Map<String, MockerizeRouter> get state => super.state;

  @override
  Future<void> upsertRouter(
    String serverId, {
    HttpServer? server,
    String? routerId,
    List<Header>? serverHeaders,
  }) async {
    // insert the router so calls to the state are valid
    state[routerId!] = MockerizeRouter(
      id: routerId,
      serverId: serverId,
      routes: [],
      logger: null,
      restarter: null,
      server: server,
      serverHeaders: [],
    );
    return;
  }

  @override
  Future<void> startRouter(
    String routerId,
    HttpServer server, {
    List<Header>? serverHeaders,
  }) async {
    return;
  }

  @override
  Future<void> stopRouter(String routerId) async {
    return;
  }

  @override
  Future<void> deleteRouter(String id) async {
    return;
  }
}
