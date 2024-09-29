import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockerize/modules/server/models/server.dart';
import 'package:mockerize/modules/server/providers/servers.provider.dart';
import 'package:mockerize/modules/server/widgets/routes/route-list.widget.dart';
import 'package:mockerize/modules/server/widgets/server/server-logs.widget.dart';
import 'package:mockerize/modules/server/widgets/server/sever-overview.widget.dart';
import 'package:mockerize/theme/breakpoint.widget.dart';

class ServerDetails extends ConsumerStatefulWidget {
  final String serverId;
  const ServerDetails({
    super.key,
    required this.serverId,
  });

  @override
  ConsumerState<ServerDetails> createState() => _ServerDetailsState();
}

class _ServerDetailsState extends ConsumerState<ServerDetails> {
  @override
  Widget build(BuildContext context) {
    final servers = ref.watch(serversProvider);
    final server = servers[widget.serverId];

    List<BreakPoint> size = mockerizeBreakSizes(context).breakPoints;

    return server != null
        ? size.contains(BreakPoint.xl)
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: size.contains(BreakPoint.xl)
                        ? MediaQuery.of(context).size.width * 0.60
                        : double.infinity,
                    child: Details(server: server, serverId: widget.serverId),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                        bottom: 8.0,
                        right: 8.0,
                      ),
                      child: Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.surface,
                        child: ServerLogs(serverId: widget.serverId),
                      ),
                    ),
                  ),
                ],
              )
            : Details(
                server: server,
                serverId: widget.serverId,
              )
        : const SizedBox();
  }
}

class Details extends StatefulWidget {
  const Details({
    super.key,
    this.server,
    required this.serverId,
  });

  final MockerizeServer? server;
  final String serverId;

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  final ExpansionTileController headerCardController =
      ExpansionTileController();
  final ExpansionTileController routeCardController = ExpansionTileController();

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    // Sort headers list
    widget.server!.headers.sort((a, b) => a.key.compareTo(b.key));

    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.only(
          top: 12,
          right: 12, // 12,
          bottom: 8,
          left: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              // height: 150,
              padding: const EdgeInsets.only(bottom: 16),
              child: widget.server != null
                  ? ServerOverview(server: widget.server!)
                  : const SizedBox(),
            ),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.only(
                bottom: 16,
              ),
              color: Theme.of(context).colorScheme.surface,
              child: ExpansionTile(
                shape: const Border(),
                controller: routeCardController,
                title: const Text(
                  'Routes',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
                tilePadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
                backgroundColor: Colors.black.withOpacity(0.1),
                collapsedBackgroundColor: colorScheme.surface,
                children: [
                  Container(
                    color: colorScheme.surface,
                    padding: const EdgeInsets.all(16.0),
                    child: RouteList(
                      serverId: widget.serverId,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
