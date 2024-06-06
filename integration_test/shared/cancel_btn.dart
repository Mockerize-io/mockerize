import 'package:flutter_test/flutter_test.dart';

Future<void> findAndPressCancelButton(WidgetTester tester,
    {String text = "Cancel"}) async {
  final cancelButton = find.text(text);
  expect(cancelButton, findsAtLeast(1));
  await tester.tap(cancelButton.last);
  await tester.pumpAndSettle();
}
