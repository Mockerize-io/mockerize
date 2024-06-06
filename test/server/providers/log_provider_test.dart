import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockerize/core/providers/mockerize.provider.dart';
import 'package:mockerize/modules/server/models/log.dart';
import 'package:mockerize/modules/server/providers/log.provider.dart';

import '../../mocks/mockerize_provider.mock.dart';
import '../../test-utils/data_generator.dart';
import '../../test-utils/provider_container.dart';

void main() {
  late ProviderContainer container;
  late ProviderSubscription<Map<String, List<ResponseLog>>> lgProvider;
  setUp(() {
    container = createContainer(overrides: [
      mockerizeProvider.overrideWith((ref) => MockMockerizeProvider(ref))
    ]);

    lgProvider = container.listen(logProvider, (_, __) {});
  });

  test('can add log', () async {
    final log = createLog();

    await container.read(logProvider.notifier).addLog("abc123", log);

    expect(lgProvider.read()['abc123'], hasLength(1));

    expect(lgProvider.read()['abc123'], contains(log));
  });

  test('can delete logs for server', () async {
    final log = createLog();

    await container.read(logProvider.notifier).addLog("abc123", log);

    expect(lgProvider.read()['abc123'], hasLength(1));

    await container.read(logProvider.notifier).deleteLogsForServer("abc123");

    expect(lgProvider.read()['abc123'], isEmpty);
  });

  test('can delete server', () async {
    final log = createLog();

    await container.read(logProvider.notifier).addLog("abc123", log);

    expect(lgProvider.read()['abc123'], hasLength(1));

    await container.read(logProvider.notifier).deleteServer("abc123");

    expect(lgProvider.read()['abc123'], isNull);
  });

  test('cannot go over limit of logs', () async {
    final log = createLog();

    for (var i = 0; i < 6; i++) {
      await container.read(logProvider.notifier).addLog("abc123", log);
    }

    expect(lgProvider.read()['abc123'], hasLength(5));
  });
}
