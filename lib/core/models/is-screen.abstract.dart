import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mockerize/core/models/floating-action.model.dart';
import 'package:mockerize/core/models/route-icons.model.dart';

abstract class IsScreen {
  final GoRouterState? goRouterState;

  IsScreen({this.goRouterState});

  String get uniqueName;
  String get routePath;
  String get title;
  bool get enabledInMenu;
  FloatingAction? get floatingAction;
  Map<RouteIconType, IconData>? get icons;
}
