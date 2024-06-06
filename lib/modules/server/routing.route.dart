import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mockerize/core/models/routing.abstract.dart';
import 'package:mockerize/core/models/routing.model.dart';
import 'package:mockerize/modules/server/scaffolds/server-form.scaffold.dart';
import './screens/add-route.screen.dart';
import './screens/add-server.screen.dart';
import './screens/edit-route.screen.dart';
import './screens/edit-server.screen.dart';
import './screens/routes.screen.dart';
import './screens/servers.screen.dart';
import './scaffolds/route-form.scaffold.dart';
import './screens/server.screen.dart';

class Routing extends MockerizeRouting {
  /// Servers
  final serversScreen = const ServersScreen(null);
  final editServerScreen = const EditServerScreen(null);
  final addServerScreen = const AddServerScreen(null);
  final serverScreen = const ServerScreen(null);

  /// Routes
  final routesScreen = const RoutesScreen(null);
  final addRouteScreen = const AddRouteScreen(null);
  final editRouteScreen = const EditRouteScreen(null);

  @override
  MockerizeScaffoldedRoutes get availableRoutes => MockerizeScaffoldedRoutes(
        scaffoldWidget: null,
        children: [
          MockerizeRoute(
            routePath: serversScreen.routePath,
            title: serversScreen.title,
            icons: serversScreen.icons,
            enabledInMenu: serversScreen.enabledInMenu,
            widget: (GoRouterState state) => ServersScreen(
              state,
              activeServers: false,
            ),
            children: MockerizeScaffoldedRoutes(
              scaffoldWidget: (Widget child, GoRouterState state) =>
                  ServerFormScaffold(child, state),
              children: [
                MockerizeRoute(
                  routePath: addServerScreen.routePath,
                  title: addServerScreen.title,
                  enabledInMenu: addServerScreen.enabledInMenu,
                  widget: (GoRouterState state) => AddServerScreen(state),
                ),
                MockerizeRoute(
                  routePath: editServerScreen.routePath,
                  title: editServerScreen.title,
                  enabledInMenu: editServerScreen.enabledInMenu,
                  widget: (GoRouterState state) => EditServerScreen(state),
                ),
              ],
            ),
          ),
          MockerizeRoute(
            routePath: serverScreen.routePath,
            title: serverScreen.title,
            enabledInMenu: serverScreen.enabledInMenu,
            widget: (GoRouterState state) => ServerScreen(state),
            children: MockerizeScaffoldedRoutes(
              scaffoldWidget: (Widget child, GoRouterState state) =>
                  RouteFormScaffold(child, state),
              children: [
                MockerizeRoute(
                  routePath: routesScreen.routePath,
                  title: routesScreen.title,
                  enabledInMenu: routesScreen.enabledInMenu,
                  widget: (GoRouterState state) => RoutesScreen(state),
                ),
                MockerizeRoute(
                  routePath: editRouteScreen.routePath,
                  title: editRouteScreen.title,
                  enabledInMenu: editRouteScreen.enabledInMenu,
                  widget: (GoRouterState state) => EditRouteScreen(state),
                ),
                MockerizeRoute(
                  routePath: addRouteScreen.routePath,
                  title: addRouteScreen.title,
                  enabledInMenu: addRouteScreen.enabledInMenu,
                  widget: (GoRouterState state) => AddRouteScreen(state),
                ),
              ],
            ),
          ),
        ],
      );
}
