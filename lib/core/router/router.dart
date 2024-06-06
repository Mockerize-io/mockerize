import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mockerize/core/models/routing.model.dart';

import 'package:mockerize/core/navigation/navigation.scaffold.dart';

import 'package:mockerize/modules/generic/routing.route.dart'
    as generic_routing;
import 'package:mockerize/modules/server/routing.route.dart' as routing_routing;
import 'package:mockerize/modules/server/screens/servers.screen.dart';

/// Base routing system
RouteBase buildRoute(MockerizeRoute mRoute) {
  GoRoute newRoute = GoRoute(
    path: mRoute.routePath,
    builder: (BuildContext context, GoRouterState state) {
      return mRoute.widget(state);
    },
    routes: mRoute.children != null ? buildShellRoute(mRoute.children!) : [],
  );

  return newRoute;
}

/// Shell Routes
List<RouteBase> buildShellRoute(MockerizeScaffoldedRoutes sRoute) {
  List<RouteBase> children = <RouteBase>[];

  // Build and Push Children into Array
  for (var childRoute in sRoute.children) {
    children.add(buildRoute(childRoute));
  }

  // Should children be wrapped in Scaffolding
  if (sRoute.scaffoldWidget != null) {
    return [
      ShellRoute(
        builder: (context, state, child) {
          return sRoute.scaffoldWidget!(child, state);
        },
        routes: children,
      )
    ];
  }

  return children;
}

List<RouteBase> allAvailableRoutes = <RouteBase>[
  ...buildShellRoute(generic_routing.Routing().availableRoutes),
  ...buildShellRoute(routing_routing.Routing().availableRoutes),
];

final GoRouter applicationRouter = GoRouter(
  routes: <RouteBase>[
    ShellRoute(
      builder: (context, state, child) {
        return MockerizeNavigationScaffold(child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            return ServersScreen(state);
          },
          routes: allAvailableRoutes,
        ),
      ],
    ),
  ],
);
