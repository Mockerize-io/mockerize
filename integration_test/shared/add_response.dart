import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockerize/modules/server/models/endpoint.dart';
import 'package:mockerize/modules/server/widgets/routes/status-selector.widget.dart';
import 'package:mockerize/theme/mockerize-input.widget.dart';

import 'add_header.dart';
import 'submit_btn.dart';

Future<void> addResponse(
  WidgetTester tester, {
  String name = "test response",
  int status = 200,
  ResponseType type = ResponseType.text,
  String body = 'hello world',
  String headerName = 'Response-Header',
  String headerValue = 'Test 123',
}) async {
  // Find the "Add Response" button
  final addResponse = find.text("Add Response");

  expect(addResponse, findsOneWidget);

  await tester.scrollUntilVisible(addResponse, 10.0,
      scrollable: find.byType(Scrollable).last);

  // tap the button
  await tester.tap(addResponse);

  await tester.pumpAndSettle();

  // find the name input
  final nameInput = find.ancestor(
      of: find.text("Name"), matching: find.byType(MockerizeTextFormField));

  expect(nameInput, findsOneWidget);

  // enter the name

  await tester.enterText(nameInput, name);

  await tester.pumpAndSettle();

  // find the status input
  final statusInput = find.ancestor(
      of: find.text("Status"), matching: find.byType(StatusSelector));

  expect(statusInput, findsOneWidget);

  // select the status
  await tester.tap(statusInput);

  await tester.pumpAndSettle();

  await tester.tap(find.textContaining(status.toString()).last);

  await tester.pumpAndSettle();

  // add a header
  await addHeader(tester, headerName: headerName, headerValue: headerValue);

  // find the response type input

  final typeInput = find.ancestor(
      of: find.text("Response Type"),
      matching: find.byType(DropdownButtonFormField<ResponseType>));

  expect(typeInput, findsOneWidget);

  // scroll to the type input
  await tester.scrollUntilVisible(typeInput, 10.0,
      scrollable: find.byType(Scrollable).last);

  await tester.tap(typeInput);

  await tester.pumpAndSettle();

  await tester.tap(find.text(type.name.toLowerCase()).last);

  await tester.pumpAndSettle();

  // find the body input

  final bodyInput = find.ancestor(
      of: find.text("Response"), matching: find.byType(MockerizeTextFormField));

  expect(bodyInput, findsOneWidget);

  // enter the body

  await tester.enterText(bodyInput, body);

  await tester.pumpAndSettle();

  await findAndPressSubmitButton(tester, text: "Save Response");
}
