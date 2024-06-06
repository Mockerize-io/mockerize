import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockerize/modules/server/widgets/server/server-list.widget.dart';

void main() {
  testWidgets("server list shows icon if empty", (tester) async {
    // By default, the surface size is 800x600
    // The physical size is being reported as 2400 x 1800 by default
    // The widget size is being reported 800x600 by default (with the above default)
    // This is causing an overflow on the right in the row of the _NoServersState by 116 pixels
    // Additionally there is an inconsistency in the size depending on how
    // tests are run, see https://github.com/flutter/flutter/issues/124071
    // if the pixel ratio is 3, it throws an overflow,
    // but 1, 2 and even 4 is fine..., need to look into this.
    tester.view.devicePixelRatio = 2;
    // Any widgets that use stuff from the material library
    // must be wrapped within a MaterialApp to be mounted
    // otherwise it will throw an error of "no directionality widget found"
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ServerList())),
    );

    final iconFinder = find.byIcon(Icons.add_circle_rounded);

    expect(iconFinder, findsOneWidget);
  });
}
