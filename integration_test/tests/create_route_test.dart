import 'package:flutter_test/flutter_test.dart';
import 'package:mockerize/theme/mockerize-input.widget.dart';

import '../shared/add_header.dart';
import '../shared/add_response.dart';
import '../shared/add_route_btn.dart';
import '../shared/submit_btn.dart';
import '../utils/load_app.dart';

Future<void> createRouteTest() async {
  testWidgets('Create Route Smoke Test', (WidgetTester tester) async {
    await loadApp(tester);

    await findAndPressAddRouteBtn(tester);

    // find the Path field and enter a new path
    final pathInput = find.ancestor(
        of: find.text("Path"), matching: find.byType(MockerizeTextFormField));

    expect(pathInput, findsOneWidget);

    await tester.enterText(pathInput, "/test");

    await tester.pumpAndSettle();

    // add a header
    await addHeader(tester, headerName: "Route-Header", headerValue: "Test123");

    // add a response
    await addResponse(tester);

    // find the submit button and tap it
    await findAndPressSubmitButton(tester);

    // find the routes list
    // Find the Server Routes panel
    final routesPanel = find.text("Routes");

    expect(routesPanel, findsOneWidget);

    // tap the widget
    await tester.tap(routesPanel);

    await tester.pumpAndSettle();

    // find the route
    expect(find.text("/test"), findsOneWidget);
  });
}
