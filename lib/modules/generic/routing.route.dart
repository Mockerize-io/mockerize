import 'package:go_router/go_router.dart';
import 'package:mockerize/core/models/routing.abstract.dart';
import 'package:mockerize/core/models/routing.model.dart';
import './screens/settings.screen.dart';

class Routing extends MockerizeRouting {
  final settingsScreen = const SettingsScreen(null);
  @override
  MockerizeScaffoldedRoutes get availableRoutes => MockerizeScaffoldedRoutes(
        scaffoldWidget: null,
        children: [
          MockerizeRoute(
            routePath: settingsScreen.routePath,
            title: settingsScreen.title,
            icons: settingsScreen.icons,
            enabledInMenu: settingsScreen.enabledInMenu,
            widget: (GoRouterState state) => SettingsScreen(state),
          )
        ],
      );
}
