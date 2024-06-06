import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockerize/theme/typeahead.widget.dart';

import 'submit_btn.dart';

Future<void> addHeader(
  WidgetTester tester, {
  String headerName = 'Test-Header',
  String headerValue = 'Test Value',
}) async {
  // find the add header button
  final addHeader = find.text("Add Header");

  expect(addHeader, findsAtLeast(1));

  // This is done to ensure that if the height of the device is too small
  // that it will bring the button into view to not cause an error
  await tester.scrollUntilVisible(addHeader.last, 10.0,
      scrollable: find.byType(Scrollable).last);

  // tap the button
  await tester.tap(addHeader.last);

  // wait for the widget to rebuild
  await tester.pumpAndSettle();

  // Find the Key input
  final keyInput =
      find.ancestor(of: find.text("Key"), matching: find.byType(Typeahead));

  expect(keyInput, findsOneWidget);

  // enter the key
  await tester.enterText(keyInput, headerName);

  await tester.pumpAndSettle();

  // Find the Value input
  final valueInput = find.ancestor(
      of: find.text("value"), matching: find.byType(TextFormField));

  expect(valueInput, findsOneWidget);

  // enter the value

  await tester.enterText(valueInput, headerValue);

  await tester.pumpAndSettle();

  // find the enable switch
  final enableSwitch = find.byType(Switch);

  expect(enableSwitch, findsOneWidget);

  // tap the switch

  await tester.tap(enableSwitch);

  await tester.pumpAndSettle();

  // hit the save button

  await findAndPressSubmitButton(tester, text: "Save Header");

  await tester.pumpAndSettle();
}
