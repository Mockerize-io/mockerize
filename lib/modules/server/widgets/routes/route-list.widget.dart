import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockerize/modules/server/providers/routers.provider.dart';
import 'package:mockerize/modules/server/widgets/routes/route-overview.widget.dart';
import 'package:mockerize/theme/breakpoint.widget.dart';

class RouteList extends ConsumerStatefulWidget {
  final String serverId;
  const RouteList({
    super.key,
    required this.serverId,
  });

  @override
  ConsumerState<RouteList> createState() => _RouteListState();
}

class _RouteListState extends ConsumerState<RouteList> {
  final GlobalKey columnKey = GlobalKey(debugLabel: 'column-key');
  bool loaded = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        loaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(routersProvider);
    final router =
        ref.read(routersProvider.notifier).getByServerID(widget.serverId);
    router!.routes.sort((a, b) => a.path.compareTo(b.path));

    /// We need shrinkWrap, however the object is not ready on first render.
    /// Once rendered we want updates from build on size changes.
    BreakPointDetails localSize = loaded
        ? mockerizeObjectSizes(columnKey)
        : BreakPointDetails(width: 0, height: 0, breakPoints: []);

    return ListView.builder(
      key: columnKey,
      itemCount: router.routes.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final route = router.routes[index];

        return Padding(
          padding: const EdgeInsets.only(
            bottom: 16,
          ),
          child: RouteOverview(
            serverId: widget.serverId,
            route: route,
            size: localSize,
          ),
        );
      },
    );
  }
}
