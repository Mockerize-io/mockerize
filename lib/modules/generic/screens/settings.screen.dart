import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mockerize/core/models/floating-action.model.dart';
import 'package:mockerize/core/models/is-screen.abstract.dart';
import 'package:mockerize/core/models/route-icons.model.dart';
import 'package:mockerize/core/providers/mockerize.provider.dart';
import 'package:mockerize/modules/generic/widgets/settings.widget.dart';
import 'package:mockerize/modules/generic/widgets/title.widget.dart';

class SettingsScreen extends ConsumerWidget implements IsScreen {
  @override
  final GoRouterState? goRouterState;

  const SettingsScreen(this.goRouterState, {super.key});

  @override
  bool get enabledInMenu => true;

  @override
  FloatingAction? get floatingAction => null;

  @override
  Map<RouteIconType, IconData> get icons => {
        RouteIconType.off: Icons.settings_outlined,
        RouteIconType.on: Icons.settings,
      };

  @override
  String get routePath => 'settings';

  @override
  String get title => 'Settings';

  @override
  String get uniqueName => 'settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (goRouterState?.extra == uniqueName) {
        ref.read(mockerizeProvider.notifier).setGlobalAction(null);
      }
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const MockerizeTitleWidget(title: 'Settings'),
      ),
      body: const SettingsWidget(),
    );
  }
}
