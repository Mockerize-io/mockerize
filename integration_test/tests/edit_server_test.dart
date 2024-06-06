import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_editor/widgets/markdown_form_field.dart';
import 'package:mockerize/theme/typeahead.widget.dart';

import '../shared/menu_option.dart';
import '../shared/submit_btn.dart';
import '../utils/load_app.dart';

Future<void> editServerTest() async {
  testWidgets('Edit Server Smoke Test', (WidgetTester tester) async {
    await loadApp(tester);

    await findMenuAndPressOption(tester, "Edit", icon: Icons.more_vert);

    // find the name field and enter a new name
    final nameInput = find.ancestor(
        of: find.text("Name"), matching: find.byType(TextFormField));

    expect(nameInput, findsOneWidget);

    await tester.enterText(nameInput, "Updated Name");

    await tester.pumpAndSettle();

    // find the description field and enter a new description

    final descriptionInput = find.ancestor(
        of: find.text("Description"), matching: find.byType(MarkdownFormField));

    expect(descriptionInput, findsOneWidget);

    await tester.enterText(descriptionInput, "### Updated Description");

    await tester.pumpAndSettle();

    // find the port field and enter a new port

    final portInput = find.ancestor(
        of: find.text("Port"), matching: find.byType(TextFormField));

    expect(portInput, findsOneWidget);

    await tester.enterText(portInput, "8085");

    await tester.pumpAndSettle();

    // Find the dropdown button
    final dropdown = find.byType(DropdownButtonFormField<String>);

    expect(dropdown, findsOneWidget);

    // tap the dropdown

    await tester.tap(dropdown);

    await tester.pumpAndSettle();

    // find 0.0.0.0 in the dropdown

    final allAddress = find.text("0.0.0.0");

    expect(allAddress, findsOneWidget);

    // tap the address

    await tester.tap(allAddress);

    await tester.pumpAndSettle();

    await findMenuAndPressOption(tester, "Edit", icon: Icons.more_vert);

    // find the header key field

    final headerKeyInput =
        find.ancestor(of: find.text("Key"), matching: find.byType(Typeahead));

    expect(headerKeyInput, findsOneWidget);

    // enter the key

    await tester.enterText(headerKeyInput, "Test-Header-Updated");

    await tester.pumpAndSettle();

    // find the header value field

    final headerValueInput = find.ancestor(
        of: find.text("value"), matching: find.byType(TextFormField));

    expect(headerValueInput, findsOneWidget);

    // enter the value

    await tester.enterText(headerValueInput, "Test Value Updated");

    await tester.pumpAndSettle();

    // Save the header

    await findAndPressSubmitButton(tester, text: "Save Header");

    // Save the server

    await findAndPressSubmitButton(tester);

    // find the updated server name

    final updatedName = find.text("Updated Name");

    expect(updatedName, findsOneWidget);
  });
}
