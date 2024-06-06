import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mockerize/core/models/floating-action.model.dart';
import 'package:mockerize/core/models/is-screen.abstract.dart';
import 'package:mockerize/core/models/mockerize_globals.model.dart';
import 'package:mockerize/core/models/route-icons.model.dart';
import 'package:mockerize/core/providers/mockerize.provider.dart';
import 'package:mockerize/modules/server/widgets/server/server-list.widget.dart';
import 'package:mockerize/modules/generic/widgets/title.widget.dart';

class ServersScreen extends ConsumerWidget implements IsScreen {
  @override
  final GoRouterState? goRouterState;
  final bool activeServers;

  const ServersScreen(
    this.goRouterState, {
    super.key,
    this.activeServers = false,
  });

  @override
  bool get enabledInMenu => true;

  @override
  FloatingAction get floatingAction => FloatingAction(
        title: 'Create Server',
        target: '/servers/add',
        icon: const Icon(Icons.add),
      );

  @override
  Map<RouteIconType, IconData> get icons => {
        RouteIconType.off: Icons.dns_outlined,
        RouteIconType.on: Icons.dns,
      };

  @override
  String get routePath => 'servers';

  @override
  String get title => 'Servers';

  @override
  String get uniqueName => 'servers';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch(mockerizeProvider.select((value) => value.globalAction));
    // final mockerize = ref.read(mockerizeProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // We check the current route because addPostFrameCallback seems to
      // also run when the page is left.
      if ((ModalRoute.of(context)?.isCurrent ?? false)) {
        ref.read(mockerizeProvider.notifier).setGlobalAction(
              activeServers
                  ? null
                  : MockerizeActionModel(
                      action: () => context.go('/servers/add', extra: 'home'),
                      icon: Icons.add,
                      title: 'Create Server',
                    ),
            );
      }
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: MockerizeTitleWidget(
            title: activeServers ? 'Active Servers' : 'Servers'),
        actions: <Widget>[
          MediaQuery.of(context).size.width > 650 && !activeServers
              ? TextButton.icon(
                  onPressed: () => context.go('/servers/add', extra: 'home'),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Server'),
                )
              : const SizedBox(),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: ServerList(),
        ),
      ),
    );
  }
}
