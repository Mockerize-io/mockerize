import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../shared/cancel_btn.dart';
import '../utils/load_app.dart';
import '../utils/screen_size.dart';

Future<void> createServerErrorTest() async {
  testWidgets('Create Server Errors Smoke Test', (WidgetTester tester) async {
    await loadApp(tester);

    final createServer = getScreenSize(tester).width > 767
        ? find.text("Create Server")
        : find.ancestor(
            of: find.byTooltip("Create Server"),
            matching: find.byType(FloatingActionButton));

    expect(createServer, findsOneWidget);

    await tester.tap(createServer);
    await tester.pumpAndSettle();

    // Click the save button without entering any data
    final saveButton = find.text("Submit");

    expect(saveButton, findsOneWidget);

    await tester.tap(saveButton);

    // should show error messages
    await tester.pumpAndSettle();

    expect(find.text("name is required"), findsOneWidget);
    expect(find.text("port is required"), findsOneWidget);

    if (!Platform.isWindows) {
      // fill in the name
      final nameInput = find.ancestor(
          of: find.text("Name"), matching: find.byType(TextFormField));

      expect(nameInput, findsOneWidget);

      await tester.enterText(nameInput, "Test");

      await tester.pumpAndSettle();
      // test the port error when using a port below 1023
      final portInput = find.ancestor(
          of: find.text("Port"), matching: find.byType(TextFormField));

      expect(portInput, findsOneWidget);

      await tester.enterText(portInput, "80");

      await tester.pumpAndSettle();
      await tester.tap(saveButton);

      await tester.pumpAndSettle();

      expect(find.text("Can't use ports between 1-1023 if not root"),
          findsOneWidget);

      // click the add header button

      final addHeaderButton = find.text("Add Header");

      expect(addHeaderButton, findsOneWidget);

      await tester.scrollUntilVisible(addHeaderButton, 10.0,
          scrollable: find.byType(Scrollable).last);

      await tester.tap(addHeaderButton);

      await tester.pumpAndSettle();

      // click the save header button

      final saveHeaderButton = find.text("Save Header");

      expect(saveHeaderButton, findsOneWidget);

      await tester.tap(saveHeaderButton);

      await tester.pumpAndSettle();

      // should show error messages
      expect(find.text("A header key is required"), findsOneWidget);
      expect(find.text("A header value is required"), findsOneWidget);

      // click the cancel button

      await findAndPressCancelButton(tester);
      // now cancel the server creation
      await findAndPressCancelButton(tester);
      await tester.pumpAndSettle();
    }
  });
}
