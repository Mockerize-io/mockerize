import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockerize/modules/server/models/endpoint.dart';
import 'package:mockerize/theme/mockerize-input.widget.dart';
import 'package:http/http.dart' as http;

import '../shared/add_response.dart';
import '../shared/add_route_btn.dart';
import '../shared/submit_btn.dart';
import '../utils/load_app.dart';

Future<void> liveSwitchingTest() async {
  testWidgets('Live Switching Smoke Test', (WidgetTester tester) async {
    await loadApp(tester);

    await findAndPressAddRouteBtn(tester);

    // find the Path field and enter a new path
    final pathInput = find.ancestor(
        of: find.text("Path"), matching: find.byType(MockerizeTextFormField));

    expect(pathInput, findsOneWidget);

    await tester.enterText(pathInput, "/switching-test");

    await tester.pumpAndSettle();

    await addResponse(
      tester,
      name: "test response 1",
      headerName: "Test-Header",
      headerValue: "Testing 123",
      body: "This is a test",
      status: 200,
    );

    // add another response
    await addResponse(
      tester,
      name: "test response 2",
      headerName: "Test-Header",
      headerValue: "Testing 456",
      body: '{"message": "This is a test"}',
      type: ResponseType.json,
      status: 201,
    );

    // find the submit button and tap it
    await findAndPressSubmitButton(tester);

    // find the routes list
    // Find the Server Routes panel
    final routesPanel = find.text("Routes");

    expect(routesPanel, findsOneWidget);

    // tap the widget
    await tester.tap(routesPanel);

    await tester.pumpAndSettle();

    // find the start button
    final startButton = find.byIcon(Icons.play_arrow);

    expect(startButton, findsOneWidget);

    // tap the start button
    await tester.tap(startButton);

    // From this point on until the stop button is pressed, do not use pumpAndSettle
    await tester.pump();

    // make an http request to the server
    await tester.runAsync(() async {
      var response = await http.Client()
          .get(Uri.parse("http://localhost:8085/switching-test"));

      expect(response.statusCode, 200);
      expect(response.body.trim(), "This is a test");

      expect(response.headers.keys, contains("test-header"));
      expect(response.headers["test-header"], equals("Testing 123"));
    });

    // Find the widget for test response 1
    final testResponse1 = find.text("test response 1");

    expect(testResponse1, findsOneWidget);

    // scroll to the widget
    await tester.scrollUntilVisible(testResponse1, 10.0,
        scrollable: find.byType(Scrollable).last);

    // tap the widget
    await tester.tap(testResponse1);

    await tester.pump();

    // find test response 2
    final testResponse2 = find.text("test response 2");

    expect(testResponse2, findsOneWidget);

    // tap the widget
    await tester.tap(testResponse2);

    await tester.pump();

    // make an http request to the server

    await tester.runAsync(() async {
      var response = await http.Client()
          .get(Uri.parse("http://localhost:8085/switching-test"));

      expect(response.statusCode, 201);
      expect(response.body.trim(), '{"message": "This is a test"}');

      // check the headers
      expect(response.headers.keys, contains("test-header"));
      expect(response.headers["test-header"], equals("Testing 456"));
    });

    // stop the server
    final stopButton = find.byIcon(Icons.stop);

    expect(stopButton, findsOneWidget);

    await tester.pump();

    // scroll to the stop button
    await tester.scrollUntilVisible(stopButton, 10.0,
        scrollable: find.byType(Scrollable).last);

    await tester.tap(stopButton);

    await tester.pumpAndSettle();
  });
}
