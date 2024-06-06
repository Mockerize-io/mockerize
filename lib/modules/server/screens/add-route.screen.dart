import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mockerize/core/models/floating-action.model.dart';
import 'package:mockerize/core/models/is-screen.abstract.dart';
import 'package:mockerize/core/models/route-icons.model.dart';
import 'package:mockerize/core/providers/mockerize.provider.dart';
import 'package:mockerize/modules/generic/widgets/title.widget.dart';
import 'package:mockerize/modules/server/widgets/routes/route-crud.widget.dart';

class AddRouteScreen extends ConsumerWidget implements IsScreen {
  @override
  final GoRouterState? goRouterState;

  const AddRouteScreen(this.goRouterState, {super.key});

  @override
  bool get enabledInMenu => false;

  @override
  FloatingAction? get floatingAction => null;

  @override
  Map<RouteIconType, IconData>? get icons => null;

  @override
  String get routePath => "routes/add";

  @override
  String get title => "Adding Route";

  @override
  String get uniqueName => 'add-route';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if ((ModalRoute.of(context)?.isCurrent ?? false)) {
        ref.read(mockerizeProvider.notifier).setGlobalAction(null);
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: MockerizeTitleWidget(title: title),
      ),
      // body: MockerizeRouteSettings(serverId: serverId, routeId: routeId),
      body: goRouterState?.pathParameters['serverId'] != null
          ? RouteCrud(
              goRouterState!.pathParameters['serverId']!,
            )
          : const Text('No id passed'),
    );
  }
}
