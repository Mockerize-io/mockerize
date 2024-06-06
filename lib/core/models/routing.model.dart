import 'package:flutter/material.dart';
import 'package:mockerize/core/models/floating-action.model.dart';
import 'package:mockerize/core/models/route-icons.model.dart';

class MockerizeScaffoldedRoutes {
  final Function? scaffoldWidget;
  final List<MockerizeRoute> children;

  MockerizeScaffoldedRoutes({
    this.scaffoldWidget,
    required this.children,
  });
}

class MockerizeRoute {
  final String routePath;
  final String title;
  final Map<RouteIconType, IconData>? icons;
  final bool enabledInMenu;
  final FloatingAction? floatingAction;
  final MockerizeScaffoldedRoutes? children;
  final Function widget;

  MockerizeRoute({
    required this.routePath,
    required this.title,
    this.icons,
    required this.enabledInMenu,
    this.floatingAction,
    this.children,
    required this.widget,
  });
}
