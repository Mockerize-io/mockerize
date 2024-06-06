import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mockerize/core/models/controller.dart';
import 'package:mockerize/core/models/floating-action.model.dart';
import 'package:mockerize/core/models/is-screen.abstract.dart';
import 'package:mockerize/core/models/route-icons.model.dart';
import 'package:mockerize/core/providers/mockerize.provider.dart';
import 'package:mockerize/modules/generic/widgets/title.widget.dart';
import 'package:mockerize/theme/typeahead.widget.dart';

class MockerizeHome extends ConsumerWidget implements IsScreen {
  @override
  final GoRouterState? goRouterState;

  MockerizeHome(
    this.goRouterState, {
    super.key,
  });

  @override
  bool get enabledInMenu => true;

  @override
  FloatingAction? get floatingAction => null;

  @override
  Map<RouteIconType, IconData> get icons => {
        RouteIconType.off: Icons.home_outlined,
        RouteIconType.on: Icons.home,
      };

  @override
  String get routePath => '/';

  @override
  String get title => 'Mockerize';

  @override
  String get uniqueName => 'home';

  final _sampleFormKey = GlobalKey<FormState>();
  final _sampleFieldKey = GlobalKey<FormFieldState>();
  final _sampleController = TextEditingController();

  final sampleController = MockerizeTextController(
    controller: TextEditingController(),
    value: null,
    error: null,
  );

  final List<String> options = [
    'Authorization',
    'Cache-Control',
    'Content-ID',
    'Content-Length',
    'Content-Range',
    'Content-Type',
    'Content-Transfer-Encoding',
    'Date',
    'ETag',
    'Expires',
    'Host',
    'If-Match',
    'If-None-Match',
    'Location',
    'Range',
  ];

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
        title: const MockerizeTitleWidget(title: 'Mockerize'),
      ),
      body: Center(
        child: Column(
          children: [
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surface,
              margin: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Form(
                      key: _sampleFormKey,
                      child: Typeahead(
                        fieldKey: _sampleFieldKey,
                        controller: sampleController,
                        label: 'Sample Label',
                        options: options,
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
