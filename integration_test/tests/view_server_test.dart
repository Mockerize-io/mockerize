import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../shared/menu_option.dart';
import '../utils/load_app.dart';
import '../utils/misc.dart';
import '../utils/screen_size.dart';

Future<void> viewServerTest() async {
  testWidgets('View Server Smoke Test', (WidgetTester tester) async {
    await loadApp(tester);

    // Find our updated server
    final server = find.text("Updated Name");

    expect(server, findsOneWidget);

    // tap the widget
    await tester.tap(server);

    // wait for the widget to rebuild
    await tester.pumpAndSettle();

    // should be at the top bar and on the overview
    expect(find.text("Updated Name"), findsNWidgets(2));

    // Find the description panel
    final descriptionPanel = find.text("Description");

    expect(descriptionPanel, findsOneWidget);

    // tap the widget
    await tester.tap(descriptionPanel);

    // wait for the widget to rebuild
    await tester.pumpAndSettle();

    // find the text
    expect(find.text("Updated Description"), findsOneWidget);

    // Find the Server Headers panel
    final headersPanel = find.text("Server Headers");

    expect(headersPanel, findsOneWidget);

    // tap the widget
    await tester.tap(headersPanel);

    // wait for the widget to rebuild
    await tester.pumpAndSettle();

    // find the text
    expect(find.text("Test-Header-Updated"), findsOneWidget);
    expect(find.text("Test Value Updated"), findsOneWidget);

    // Find the Server Routes panel
    final routesPanel = find.text("Routes");

    expect(routesPanel, findsOneWidget);

// scroll it into view
    await tester.scrollUntilVisible(routesPanel, 10.0,
        scrollable: find.byType(Scrollable).last);

    // tap the widget
    await tester.tap(routesPanel);

    // wait for the widget to rebuild
    await tester.pumpAndSettle();

    // find the default route
    expect(find.text("/"), findsOneWidget);
    expect(find.text("Default response"), findsOneWidget);
    if (getScreenSize(tester).width > 767 && !isMobile()) {
      // check for the logs panel
      expect(find.text("Logs"), findsOneWidget);
    } else {
      // Click the logs menu option
      await findMenuAndPressOption(tester, "Logs");

      // find the text
      expect(find.text("Logs"), findsOneWidget);

      // Find the close icon
      final closeIcon = find.byIcon(Icons.close);

      expect(closeIcon, findsOneWidget);

      // tap the widget

      await tester.tap(closeIcon);

      // wait for the widget to rebuild
      await tester.pumpAndSettle();
    }

    // resize test
    if (!isMobile()) {
      var originalSize = tester.view.physicalSize;

      setMobileSize();

      await tester.pumpAndSettle();

      // the description should be collapsed
      expect(find.text("Updated Description"), findsNothing);

      // the headers should be collapsed
      expect(find.text("Test-Header-Updated"), findsNothing);

      // restore the size
      setDesktopSize(width: originalSize.width, height: originalSize.height);
      await tester.pumpAndSettle();
    }
  });
}
