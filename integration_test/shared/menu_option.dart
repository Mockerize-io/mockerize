import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> findMenuAndPressOption(WidgetTester tester, String menuOption,
    {String tooltip = "Show menu", int index = 0, IconData? icon}) async {
  final menu = icon != null ? find.byIcon(icon) : find.byTooltip(tooltip);

  expect(menu, findsAtLeast(1));

  await tester.scrollUntilVisible(menu.at(index), 10.0,
      scrollable: find.byType(Scrollable).last);

  await tester.tap(menu.at(index));

  await tester.pumpAndSettle();

  final option = find.text(menuOption);

  expect(option, findsOneWidget);

  await tester.tap(option);

  await tester.pumpAndSettle();
}
