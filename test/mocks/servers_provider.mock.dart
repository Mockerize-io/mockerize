import 'package:mockerize/modules/server/providers/servers.provider.dart';

class MockServersProvider extends ServersProvider {
  MockServersProvider(super.ref, super.data);

  @override
  Future<void> markServer(String id, bool status) async {
    return;
  }

  @override
  Future<void> refreshServer(String id) async {
    return;
  }

  @override
  Future<void> startServer(String id) async {
    return;
  }

  @override
  Future<void> stopServer(String id) async {
    return;
  }
}
