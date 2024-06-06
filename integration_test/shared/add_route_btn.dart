import 'package:flutter_test/flutter_test.dart';

import '../utils/screen_size.dart';

Future<void> findAndPressAddRouteBtn(WidgetTester tester) async {
  if (getScreenSize(tester).width > 767) {
    // find the "Create Route" widget by text
    final createRoute = find.text("Create Route");

    expect(createRoute, findsOneWidget);

    // tap the widget
    await tester.tap(createRoute);
  } else {
    // find the "Create Route" widget by tooltip
    final createRoute = find.byTooltip("Create Route");

    expect(createRoute, findsOneWidget);

    // tap the widget
    await tester.tap(createRoute);
  }

  // wait for the widget to rebuild
  await tester.pumpAndSettle();
}
