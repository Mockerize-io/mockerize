import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockerize/modules/server/widgets/server/server-logs.widget.dart';

import '../shared/menu_option.dart';
import '../utils/load_app.dart';
import '../utils/screen_size.dart';

Future<void> serverTest() async {
  testWidgets("Server Smoke Test", (WidgetTester tester) async {
    await loadApp(tester);

    // find the start button
    final startButton = find.byIcon(Icons.play_arrow);

    expect(startButton, findsOneWidget);

    // tap the start button

    await tester.tap(startButton);

    // IMPORTANT: Infinite animations will cause pumpAndSettle to never complete
    // Any time (such as when on a screen with a screen's stop button) that an
    // infinite animation is running, you must call pump instead of pumpAndSettle
    // calling pumpAndSettle will cause the test to hang for the specified timeout
    // duration (10 minutes default) at which point an exception will be thrown.
    await tester.pump();

    // make an http request to the server
    await tester.runAsync(() async {
      var response =
          await http.Client().get(Uri.parse("http://localhost:8085"));

      expect(response.statusCode, 200);
      expect(response.body.trim(), "This is the index!");

      // try our route
      response =
          await http.Client().get(Uri.parse("http://localhost:8085/test"));

      expect(response.statusCode, 200);
      expect(response.body.trim(), "hello world");

      // check the headers
      expect(response.headers.keys, contains("test-header-updated"));
      expect(response.headers["test-header-updated"],
          equals("Test Value Updated"));

      expect(response.headers.keys, contains("response-header"));
      expect(response.headers["response-header"], equals("Test 123"));
    });

    // stop the server
    final stopButton = find.byIcon(Icons.stop);

    expect(stopButton, findsOneWidget);

    await tester.tap(stopButton);

    await tester.pumpAndSettle();

    if (getScreenSize(tester).width < 1200) {
      await findMenuAndPressOption(tester, "Logs", icon: Icons.more_vert);
    }

    final logs = find.descendant(
        of: find.byType(ServerLogs), matching: find.byType(ExpansionTile));

    // there should be two logs
    expect(logs, findsNWidgets(2));

    // find an icon button on the first one
    final firstLog = find.descendant(
        of: logs.at(0), matching: find.byIcon(Icons.expand_more));

    expect(firstLog, findsAtLeast(1));

    // tap the icon button

    await tester.tap(firstLog.first);

    await tester.pumpAndSettle();

    // check the log contents
    expect(find.text("Path: /"), findsOneWidget);
    expect(find.text("Method: GET"), findsOneWidget);
    expect(find.text("Body"), findsOneWidget);
    expect(find.text("No Data"), findsOneWidget);
    expect(find.text("Response"), findsOneWidget);
    expect(find.text("IP: 127.0.0.1"), findsOneWidget);
    expect(find.text("Status: 200"), findsOneWidget);
    expect(find.textContaining("Response Time:"), findsOneWidget);

    // Click copy to clipboard
    final copyButton = find.byIcon(Icons.copy);

    expect(copyButton, findsAtLeast(1));

    await tester.tap(copyButton.first);

    await tester.pumpAndSettle();

    // check the clipboard
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);

    // the content should be valid JSON (verify)
    expect(clipboardData, isNotNull);
    expect(clipboardData!.text, isNotEmpty);
    // parse the json
    try {
      var data = jsonDecode(clipboardData.text!);
      expect(data, isMap);
      expect(data["date"], isNotNull);
      expect(data["status"], 200);
      expect(data["response_time"], isNotNaN);
      expect(data["request"], isMap);
      expect(data["route_id"], isNotNull);
      expect(data["response_id"], isNotNull);
    } catch (e) {
      fail("Clipboard data is not valid JSON");
    }
  });
}
