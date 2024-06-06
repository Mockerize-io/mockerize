import 'package:mockerize/modules/server/providers/log.provider.dart';

class MockLogProvider extends LogProvider {
  MockLogProvider(super.ref, super.data);

  @override
  Future<void> deleteServer(String serverId) async {
    return;
  }
}
