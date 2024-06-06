import 'package:flutter_test/flutter_test.dart';

Future<void> findAndPressSubmitButton(WidgetTester tester,
    {String text = "Submit"}) async {
  final submitButton = find.text(text);
  expect(submitButton, findsAtLeast(1));
  await tester.tap(submitButton.first);
  await tester.pumpAndSettle();
}
