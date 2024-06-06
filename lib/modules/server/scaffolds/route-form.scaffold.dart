import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mockerize/modules/server/providers/route-form.provider.dart';
import 'package:mockerize/modules/server/providers/routers.provider.dart';

class RouteFormScaffold extends ConsumerWidget {
  final Widget child;
  final GoRouterState? state;
  const RouteFormScaffold(this.child, this.state, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(routeFormProvider);

    final serverId = state!.pathParameters['serverId'];
    final routeId = state!.pathParameters['routeId'];

    final route = routeId != null
        ? ref
            .read(routersProvider.notifier)
            .getByServerID(serverId!)!
            .getByID(routeId)
        : null;

    return ProviderScope(
      // overriding allows a provider to be initized with existing data
      // this makes it easier to handle stuff like editing existing data without
      // needing to do stuff like postframe callback.
      overrides: [
        routeFormProvider.overrideWith((ref) => RouteFormProvider(route))
      ],
      child: child,
    );
  }
}
