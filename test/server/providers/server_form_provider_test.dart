import 'package:flutter_test/flutter_test.dart';
import 'package:mockerize/modules/server/models/header.dart';
import 'package:mockerize/modules/server/models/server.dart';
import 'package:mockerize/modules/server/providers/server-form.provider.dart';

import '../../test-utils/data_generator.dart';
import '../../test-utils/provider_container.dart';

void main() {
  group('Test construction', () {
    test('Default values', () async {
      // Create a ProviderContainer for this test.
      // DO NOT share ProviderContainers between tests.
      final container = createContainer();

      final provider = container.read(serverFormProvider);

      /** Text Controller Defaults */
      expect(provider.name.controller, isNotNull);
      expect(provider.name.controller.text, isEmpty);
      expect(provider.description.controller, isNotNull);
      expect(provider.description.controller.text, isEmpty);
      expect(provider.port.controller, isNotNull);
      expect(provider.port.controller.text, isEmpty);

      expect(provider.ip, equals("127.0.0.1"));
      expect(provider.headers, isEmpty);
    });

    test('Provided Server', () async {
      final header = createHeader();

      final container = createContainer(overrides: [
        serverFormProvider
            .overrideWith((ref) => ServerFormProvider(MockerizeServer(
                  address: "192.168.0.1",
                  serverID: 'abc123',
                  port: 8080,
                  description: "testing",
                  routerId: "abc123",
                  name: "Test",
                  server: null,
                  headers: [
                    header,
                  ],
                )))
      ]);

      final provider = container.read(serverFormProvider);

      /** Text Controller Defaults */
      expect(provider.name.controller, isNotNull);
      expect(provider.name.controller.text, equals("Test"));
      expect(provider.description.controller, isNotNull);
      expect(provider.description.controller.text, equals("testing"));
      expect(provider.port.controller, isNotNull);
      expect(provider.port.controller.text, equals("8080"));

      expect(provider.ip, equals("192.168.0.1"));
      expect(provider.headers, isNotEmpty);
      expect(provider.headers[0], equals(header));
    });
  });

  group('Test server form provider functionality', () {
    test('changeAddress should update state with new address', () async {
      final container = createContainer();
      // verify the starting IP is 127.0.0.1
      final provider =
          container.listen<ServerForm>(serverFormProvider, (_, __) {});
      expect(provider.read().ip, equals("127.0.0.1"));
      // Now change the IP
      await container
          .read(serverFormProvider.notifier)
          .changeAddress("192.168.0.1");
      // Now check to see if our provider's IP has changed
      expect(provider.read().ip, equals("192.168.0.1"));
    });

    test('upsertHeader should update state with new header', () async {
      final container = createContainer();
      // verify the header list is empty
      final provider =
          container.listen<ServerForm>(serverFormProvider, (_, __) {});
      expect(provider.read().headers, isEmpty);
      // Now add a header
      await container
          .read(serverFormProvider.notifier)
          .upsertHeader("abc", "123", true);
      // Now check to see if our provider's header list size has changed
      expect(provider.read().headers.length, equals(1));
      expect(provider.read().headers[0].key, equals("abc"));
      expect(provider.read().headers[0].value, equals("123"));
      expect(provider.read().headers[0].active, isTrue);
    });

    test('deleteHeader should update state with removed header', () async {
      final header = createHeader();

      final container = createContainer(overrides: [
        serverFormProvider.overrideWith(
          (ref) => ServerFormProvider(
            MockerizeServer(
              address: "192.168.0.1",
              serverID: 'abc123',
              port: 8080,
              description: "testing",
              routerId: "abc123",
              name: "Test",
              server: null,
              headers: [header],
            ),
          ),
        ),
      ]);
      // verify the header list is not empty
      final provider =
          container.listen<ServerForm>(serverFormProvider, (_, __) {});
      expect(provider.read().headers, isNotEmpty);
      // Now delete the header
      await container.read(serverFormProvider.notifier).deleteHeader(header.id);
      // Now check to see if our provider's header list size has changed
      expect(provider.read().headers, isEmpty);
    });

    test('upsertHeader should update existing header', () async {
      final header = createHeader();

      final container = createContainer(overrides: [
        serverFormProvider.overrideWith(
          (ref) => ServerFormProvider(
            MockerizeServer(
              address: "192.168.0.1",
              serverID: 'abc123',
              port: 8080,
              description: "testing",
              routerId: "abc123",
              name: "Test",
              server: null,
              headers: [
                header,
              ],
            ),
          ),
        ),
      ]);
      // verify the header list is not empty
      final provider =
          container.listen<ServerForm>(serverFormProvider, (_, __) {});
      expect(provider.read().headers[0].value, equals(header.value));
      // Now update the header
      await container
          .read(serverFormProvider.notifier)
          .upsertHeader(header.key, "test456", true, id: header.id);
      // Now check to see if our provider's header list size has changed
      expect(provider.read().headers.length, equals(1));
      expect(provider.read().headers[0].value, equals("test456"));
    });
  });

  group('Test validators', () {
    test('name validator', () async {
      final container = createContainer();

      final provider = container.read(serverFormProvider);

      // When the value is empty or null, it should return a message
      expect(provider.name.validation!(null), equals("name is required"));
      expect(provider.name.validation!(""), equals("name is required"));
      expect(provider.name.validation!(" "), equals("name is required"));

      // When the value is not empty or not null, it should return null
      expect(provider.name.validation!("Test name"), isNull);
    });

    test('port validator', () async {
      final container = createContainer();

      final provider = container.read(serverFormProvider);

      // When the value is empty or null, it should return a message
      expect(provider.port.validation!(null), equals("port is required"));
      expect(provider.port.validation!(""), equals("port is required"));

      // When the value is not an int, it should return a message
      expect(provider.port.validation!("test"),
          equals("port must be an actual number"));
      expect(provider.port.validation!("100.2"),
          equals("port must be an actual number"));

      // When the value is not between 1 and 65535, it should return a message
      expect(provider.port.validation!("0"),
          equals("port must be between 1-65535"));
      expect(provider.port.validation!("65536"),
          equals("port must be between 1-65535"));

      // When the value is valid, it should return null
      expect(provider.port.validation!("8080"), isNull);
    });
  });
}
