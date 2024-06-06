import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_editor/widgets/markdown_form_field.dart';
import 'package:mockerize/modules/server/widgets/server/sever-overview.widget.dart';

import '../shared/add_header.dart';
import '../shared/submit_btn.dart';
import '../utils/load_app.dart';
import '../utils/misc.dart';
import '../utils/screen_size.dart';

Future<void> _createServer(WidgetTester tester,
    {String name = "Test", String port = "8080"}) async {
  final nameInput = find.ancestor(
      of: find.text("Name"), matching: find.byType(TextFormField));

  expect(nameInput, findsOneWidget);

  // enter the name
  await tester.enterText(nameInput, name);
  await tester.pumpAndSettle();

  // find the description input
  final descriptionInput = find.ancestor(
      of: find.text("Description"), matching: find.byType(MarkdownFormField));

  expect(descriptionInput, findsOneWidget);

  // enter the description
  await tester.enterText(descriptionInput, "### This is a test server");
  await tester.pumpAndSettle();

  // now find the port input
  final portInput = find.ancestor(
      of: find.text("Port"), matching: find.byType(TextFormField));

  expect(portInput, findsOneWidget);

  // enter the port

  await tester.enterText(portInput, port);
  await tester.pumpAndSettle();

  // add a header
  await addHeader(tester);

  await findAndPressSubmitButton(tester);
}

Future<void> _desktopTest(WidgetTester tester) async {
  // Find the "Create a Server" widget by the icon
  final createServer = find.byIcon(Icons.add_circle_rounded);

  // look for the text "Create a Server"
  expect(createServer, findsOneWidget);

  // tap the widget
  await tester.tap(createServer);

  // wait for the widget to rebuild
  await tester.pumpAndSettle();

  // run through creating the server
  await _createServer(tester);

  // now find the "Create Server" button
  final createServerButton = find.text("Create Server");

  expect(createServerButton, findsOneWidget);

  // tap the button
  await tester.tap(createServerButton);

  // wait for the widget to rebuild
  await tester.pumpAndSettle();

  // now create another server
  await _createServer(tester, name: "Test2", port: "8081");
}

Future<void> _mobileTest(WidgetTester tester,
    {reset = false, Size? orignalSize}) async {
  // Find the "Create Server" floating action button
  final createServer = getScreenSize(tester).width > 767
      ? find.text("Create Server")
      : find.ancestor(
          of: find.byTooltip("Create Server"),
          matching: find.byType(FloatingActionButton));

  expect(createServer, findsOneWidget);

  // tap the widget
  await tester.tap(createServer);

  // wait for the widget to rebuild
  await tester.pumpAndSettle();

  // run through creating the server
  await _createServer(tester,
      name: reset ? "Test 3" : "Test", port: reset ? "8083" : "8080");

  if (reset) {
    setDesktopSize(width: orignalSize!.width, height: orignalSize.height);
    await tester.pumpAndSettle();
  }
}

Future<void> createServerTest() async {
  testWidgets('Create Server Smoke Test', (WidgetTester tester) async {
    // load the app (needs to be called from each testWidgets)
    await loadApp(tester, firstRun: true);

    int expected = 1;
    Size? originalSize;
    if (getScreenSize(tester).width > 767 && !isMobile()) {
      expected = 3;
      await _desktopTest(tester);
      originalSize = tester.view.physicalSize;
      setMobileSize();
      await tester.pumpAndSettle();
    }

    await _mobileTest(tester, reset: expected > 1, orignalSize: originalSize);

    // now make sure there are two servers
    final serverList = find.byType(ServerNameDisplay);

    expect(serverList, findsNWidgets(expected));

    await tester.pumpAndSettle();
  });
}
