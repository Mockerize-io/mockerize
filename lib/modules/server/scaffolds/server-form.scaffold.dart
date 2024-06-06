import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mockerize/modules/server/providers/server-form.provider.dart';
import 'package:mockerize/modules/server/providers/servers.provider.dart';

class ServerFormScaffold extends ConsumerWidget {
  final Widget child;
  final GoRouterState? state;
  const ServerFormScaffold(this.child, this.state, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(serverFormProvider);

    final serverId = state!.pathParameters['serverId'];

    final server = ref.read(serversProvider)[serverId];

    return ProviderScope(
      // overriding allows a provider to be initized with existing data
      // this makes it easier to handle stuff like editing existing data without
      // needing to do stuff like postframe callback.
      overrides: [
        serverFormProvider.overrideWith((ref) => ServerFormProvider(server))
      ],
      child: child,
    );
  }
}
