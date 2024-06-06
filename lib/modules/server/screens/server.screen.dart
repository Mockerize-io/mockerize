import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mockerize/core/models/floating-action.model.dart';
import 'package:mockerize/core/models/is-screen.abstract.dart';
import 'package:mockerize/core/models/mockerize_globals.model.dart';
import 'package:mockerize/core/models/route-icons.model.dart';
import 'package:mockerize/core/providers/mockerize.provider.dart';
import 'package:mockerize/modules/generic/widgets/title.widget.dart';
import 'package:mockerize/modules/server/providers/servers.provider.dart';
import 'package:mockerize/modules/server/widgets/server/server-details.widget.dart';
import 'package:mockerize/theme/breakpoint.widget.dart';

class ServerScreen extends ConsumerWidget implements IsScreen {
  @override
  final GoRouterState? goRouterState;

  const ServerScreen(
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
  String get routePath => "server/:serverId";

  @override
  String get title => "Server";

  @override
  String get uniqueName => 'server';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servers = ref.watch(serversProvider);
    final serverId = goRouterState!.pathParameters['serverId']!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if ((ModalRoute.of(context)?.isCurrent ?? false)) {
        ref.read(mockerizeProvider.notifier).setGlobalAction(
              MockerizeActionModel(
                action: () => context.go(
                  '/server/$serverId/routes/add',
                ),
                icon: Icons.add,
                title: 'Create Route',
              ),
            );
      }
    });

    final size = mockerizeBreakSizes(context).breakPoints;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: MockerizeTitleWidget(title: servers[serverId]?.name ?? ''),
        actions: <Widget>[
          size.contains(BreakPoint.md)
              ? TextButton.icon(
                  onPressed: () => context.go('/server/$serverId/routes/add',
                      extra: 'add-route'),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Route'),
                )
              : const SizedBox(),
        ],
      ),
      body: ServerDetails(serverId: serverId),
    );
  }
}
