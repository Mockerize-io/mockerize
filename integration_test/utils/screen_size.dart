import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:window_size/window_size.dart';

void setMobileSize({double width = 600, double height = 800}) {
  setWindowFrame(Rect.fromLTWH(0, 0, width, height));
}

void setDesktopSize({double width = 800, double height = 600}) {
  setWindowFrame(Rect.fromLTWH(0, 0, width, height));
}

Size getScreenSize(WidgetTester tester) {
  // This gets us the actual rendered size as the physical size is
  // reported by the hardware and is not reflective of the actual
  // rendered size.
  return tester.view.physicalSize / tester.view.devicePixelRatio;
}
