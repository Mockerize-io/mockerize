// xs: < 576.
// sm: >= 576.
// md: >= 768.
// lg: >= 992.
// xl: >= 1200.
// xxl: >= 1400.

import 'package:flutter/material.dart';

enum BreakPoint {
  xs(formula: '< 576'),
  sm(formula: '>= 576'),
  md(formula: '>= 768'),
  lg(formula: '>= 992'),
  xl(formula: '>= 1200'),
  xxl(formula: '>= 1400');

  final String formula;
  const BreakPoint({
    required this.formula,
  });
}

class BreakPointDetails {
  final double width;
  final double height;
  final List<BreakPoint> breakPoints;

  BreakPointDetails({
    required this.width,
    required this.height,
    required this.breakPoints,
  });
}

BreakPointDetails mockerizeBreakSizes(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;

  List<BreakPoint> breakPoints = [];

  if (width < 576) {
    breakPoints.add(BreakPoint.xs);
  }

  if (width >= 576) {
    breakPoints.add(BreakPoint.sm);
  }

  if (width >= 768) {
    breakPoints.add(BreakPoint.md);
  }

  if (width >= 992) {
    breakPoints.add(BreakPoint.lg);
  }

  if (width >= 1200) {
    breakPoints.add(BreakPoint.xl);
  }

  if (width >= 1400) {
    breakPoints.add(BreakPoint.xxl);
  }

  return BreakPointDetails(
      width: width, height: height, breakPoints: breakPoints);
}

/// Object Sizes requires a Key to reference a specific object
BreakPointDetails mockerizeObjectSizes(GlobalKey thisObject) {
  List<BreakPoint> breakPoints = [];

  if (thisObject.currentContext == null) {
    return BreakPointDetails(width: 0, height: 0, breakPoints: breakPoints);
  }

  final width =
      (thisObject.currentContext!.findRenderObject() as RenderBox).size.width;
  final height =
      (thisObject.currentContext!.findRenderObject() as RenderBox).size.height;

  if (width < 576) {
    breakPoints.add(BreakPoint.xs);
  }

  if (width >= 576) {
    breakPoints.add(BreakPoint.sm);
  }

  if (width >= 768) {
    breakPoints.add(BreakPoint.md);
  }

  if (width >= 992) {
    breakPoints.add(BreakPoint.lg);
  }

  if (width >= 1200) {
    breakPoints.add(BreakPoint.xl);
  }

  if (width >= 1400) {
    breakPoints.add(BreakPoint.xxl);
  }

  return BreakPointDetails(
      width: width, height: height, breakPoints: breakPoints);
}
