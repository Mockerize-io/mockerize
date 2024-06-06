import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mockerize/core/models/floating-action.model.dart';
import 'package:mockerize/core/models/is-screen.abstract.dart';
import 'package:mockerize/core/models/mockerize_globals.model.dart';
import 'package:mockerize/core/models/route-icons.model.dart';
import 'package:mockerize/core/providers/mockerize.provider.dart';
import 'package:mockerize/modules/generic/widgets/title.widget.dart';

class RoutesScreen extends ConsumerWidget implements IsScreen {
  @override
  final GoRouterState? goRouterState;

  const RoutesScreen(
    this.goRouterState, {
    super.key,
  });

  @override
  bool get enabledInMenu => false;

  @override
  FloatingAction get floatingAction => FloatingAction(
        title: 'Create Route',
        target:
            '/servers/${goRouterState?.pathParameters['serverId']!}/routes/add',
        icon: const Icon(Icons.add),
      );

  @override
  Map<RouteIconType, IconData>? get icons => null;

  @override
  String get routePath => ":serverId/routes";

  @override
  String get title => "Routes";

  @override
  String get uniqueName => 'routes';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if ((ModalRoute.of(context)?.isCurrent ?? false)) {
        ref.read(mockerizeProvider.notifier).setGlobalAction(
              MockerizeActionModel(
                action: () => context.go(
                  '/servers/${goRouterState?.pathParameters['serverId']!}/routes/add',
                ),
                icon: Icons.add,
                title: 'Create Route',
              ),
            );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const MockerizeTitleWidget(title: 'Routes List'),
      ),
      // body: RouteList(serverId: goRouterState!.pathParameters['serverId']!),
      body: const SizedBox(),
    );
  }
}
