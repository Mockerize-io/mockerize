import 'package:flutter_test/flutter_test.dart';
import 'package:mockerize/modules/server/models/endpoint.dart';
import 'package:mockerize/modules/server/providers/route-form.provider.dart';

import '../../test-utils/data_generator.dart';
import '../../test-utils/provider_container.dart';

void main() {
  group('Test construction', () {
    test('Default values', () async {
      final container = createContainer();

      final provider = container.read(routeFormProvider);

      expect(provider.path.controller, isNotNull);
      expect(provider.path.controller.text, isEmpty);

      expect(provider.responses, isEmpty);
      expect(provider.headers, isEmpty);
      expect(provider.activeResponse, isNull);

      expect(provider.method, equals(Method.get));
    });

    test('Provided Route', () async {
      final response = createResponse();
      final header = createHeader();

      final container = createContainer(overrides: [
        routeFormProvider.overrideWith(
          (ref) => RouteFormProvider(ServerRoute(
            headers: [header],
            path: '/test',
            responses: [response],
            method: Method.post,
            activeResponse: response.id,
          )),
        )
      ]);

      final provider = container.read(routeFormProvider);

      expect(provider.path.controller, isNotNull);
      expect(provider.path.controller.text, '/test');

      expect(provider.responses, contains(response));
      expect(provider.headers, contains(header));
      expect(provider.activeResponse, equals(response.id));

      expect(provider.method, equals(Method.post));
    });
  });

  group('Test functionality', () {
    test('set method', () {
      final container = createContainer();
      final provider =
          container.listen<RouteForm>(routeFormProvider, (_, __) {});

      // defaults to get
      expect(provider.read().method, equals(Method.get));
      // call set method to change to post and verify
      container.read(routeFormProvider.notifier).setMethod(Method.post);
      expect(provider.read().method, equals(Method.post));
    });
    test('upsert response: new', () {
      final container = createContainer();
      final provider =
          container.listen<RouteForm>(routeFormProvider, (_, __) {});

      // defaults to empty
      expect(provider.read().responses, isEmpty);
      // upsert a new response and verify
      container.read(routeFormProvider.notifier).upsertResponse(
        name: "hello",
        status: Status.ok,
        response: "Hello World",
        responseType: ResponseType.text,
        headers: [],
      );

      expect(provider.read().responses, hasLength(1));
      final response = provider.read().responses[0];

      expect(response.name, equals("hello"));
      expect(response.response, equals("Hello World"));
      expect(response.responseType, equals(ResponseType.text));
      expect(response.headers, isEmpty);
      expect(response.active, isTrue);

      expect(provider.read().activeResponse, equals(response.id));
    });

    test('upsert response: existing', () {
      final response = createResponse();

      final container = createContainer(overrides: [
        routeFormProvider.overrideWith(
          (ref) => RouteFormProvider(ServerRoute(
            headers: [],
            path: '/test',
            responses: [response],
            method: Method.post,
            activeResponse: response.id,
          )),
        )
      ]);

      final provider =
          container.listen<RouteForm>(routeFormProvider, (_, __) {});

      // verify existing response
      expect(provider.read().responses, contains(response));
      // upsert the changes for the response
      container.read(routeFormProvider.notifier).upsertResponse(
            name: "hello",
            status: Status.ok,
            response: "Hello World",
            responseType: ResponseType.text,
            headers: [],
            id: response.id,
          );

      expect(provider.read().responses, hasLength(1));
      final resp = provider.read().responses[0];

      expect(resp.name, equals("hello"));
      expect(resp.response, equals("Hello World"));
      expect(resp.responseType, equals(ResponseType.text));
    });

    test('delete response: no active', () {
      final response = createResponse();

      final container = createContainer(overrides: [
        routeFormProvider.overrideWith(
          (ref) => RouteFormProvider(ServerRoute(
            headers: [],
            path: '/test',
            responses: [response],
            method: Method.post,
            activeResponse: response.id,
          )),
        )
      ]);

      final provider =
          container.listen<RouteForm>(routeFormProvider, (_, __) {});

      // verify existing response
      expect(provider.read().responses, contains(response));
      // delete and verify
      container.read(routeFormProvider.notifier).removeResponse(response.id);
      expect(provider.read().responses, isEmpty);
      expect(provider.read().activeResponse, isNull);
    });
    test('delete response: has active', () {
      final response1 = createResponse();
      final response2 = createResponse();

      final container = createContainer(overrides: [
        routeFormProvider.overrideWith(
          (ref) => RouteFormProvider(ServerRoute(
            headers: [],
            path: '/test',
            responses: [response1, response2],
            method: Method.post,
            activeResponse: response1.id,
          )),
        )
      ]);

      final provider =
          container.listen<RouteForm>(routeFormProvider, (_, __) {});

      // verify existing response
      expect(provider.read().responses, contains(response1));
      // delete and verify
      container.read(routeFormProvider.notifier).removeResponse(response1.id);
      expect(provider.read().responses, hasLength(1));
      expect(provider.read().activeResponse, equals(response2.id));
    });

    test('upsert header: new', () {
      final container = createContainer();
      final provider =
          container.listen<RouteForm>(routeFormProvider, (_, __) {});

      // defaults to empty
      expect(provider.read().headers, isEmpty);
      // upsert a new header and verify
      container.read(routeFormProvider.notifier).upsertHeader(
            "hello",
            "world",
            true,
          );

      expect(provider.read().headers, hasLength(1));
      final header = provider.read().headers[0];

      expect(header.key, equals("hello"));
      expect(header.value, equals("world"));
      expect(header.active, isTrue);
    });

    test('upsert header: existing', () {
      final header = createHeader();

      final container = createContainer(overrides: [
        routeFormProvider.overrideWith(
          (ref) => RouteFormProvider(ServerRoute(
            headers: [header],
            path: '/test',
            responses: [],
            method: Method.post,
            activeResponse: null,
          )),
        )
      ]);

      final provider =
          container.listen<RouteForm>(routeFormProvider, (_, __) {});

      // verify existing header
      expect(provider.read().headers, contains(header));
      // upsert the changes for the header
      container.read(routeFormProvider.notifier).upsertHeader(
            "hello",
            "world",
            true,
            id: header.id,
          );

      expect(provider.read().headers, hasLength(1));
      final head = provider.read().headers[0];

      expect(head.key, equals("hello"));
      expect(head.value, equals("world"));
    });

    test('delete header', () {
      final header = createHeader();

      final container = createContainer(overrides: [
        routeFormProvider.overrideWith(
          (ref) => RouteFormProvider(ServerRoute(
            headers: [header],
            path: '/test',
            responses: [],
            method: Method.post,
            activeResponse: null,
          )),
        )
      ]);

      final provider =
          container.listen<RouteForm>(routeFormProvider, (_, __) {});

      // verify existing header
      expect(provider.read().headers, contains(header));
      // delete and verify
      container.read(routeFormProvider.notifier).deleteHeader(header.id);
      expect(provider.read().headers, isEmpty);
    });
  });

  test('test path validator', () {
    final container = createContainer();
    final provider = container.read(routeFormProvider);

    expect(provider.path.validation!(null), contains("path is required"));
    expect(provider.path.validation!(""), contains("path is required"));
    expect(provider.path.validation!(" "), contains("path is required"));
    expect(provider.path.validation!("/"), isNull);
  });
}
