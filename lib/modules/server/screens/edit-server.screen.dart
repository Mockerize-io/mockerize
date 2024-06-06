import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mockerize/core/models/floating-action.model.dart';
import 'package:mockerize/core/models/is-screen.abstract.dart';
import 'package:mockerize/core/models/route-icons.model.dart';
import 'package:mockerize/core/providers/mockerize.provider.dart';
import 'package:mockerize/modules/generic/widgets/title.widget.dart';
import 'package:mockerize/modules/server/widgets/server/server-crud.widget.dart';

class EditServerScreen extends ConsumerWidget implements IsScreen {
  @override
  final GoRouterState? goRouterState;

  const EditServerScreen(this.goRouterState, {super.key, this.id});

  final String? id;

  @override
  bool get enabledInMenu => false;

  @override
  FloatingAction? get floatingAction => null;

  @override
  Map<RouteIconType, IconData>? get icons => null;

  @override
  String get routePath => ":serverId/edit";

  @override
  String get title => "Editing Server";

  @override
  String get uniqueName => 'edit-server';

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
          onPressed: () {
            if (GoRouterState.of(context).extra == 'home') {
              context.go("/");
            } else {
              context.pop();
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: MockerizeTitleWidget(title: title),
      ),
      body: goRouterState?.pathParameters['serverId'] != null
          ? ServerCrud(id: goRouterState?.pathParameters['serverId'])
          : const Text('no id'),
    );
  }
}
