import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mockerize/modules/generic/widgets/spinning-icon.widget.dart';
import 'package:mockerize/modules/server/models/server.dart';
import 'package:mockerize/modules/server/providers/routers.provider.dart';
import 'package:mockerize/modules/server/providers/servers.provider.dart';
import 'package:mockerize/modules/server/widgets/header/header-list.widget.dart';
import 'package:mockerize/modules/server/widgets/server/logs_heatmap.widget.dart';
import 'package:mockerize/modules/server/widgets/server/server-logs.widget.dart';
import 'package:mockerize/theme/breakpoint.widget.dart';
import 'package:mockerize/theme/mockerize.theme.dart';
import 'package:markdown_editor/widgets/markdown_parse.dart';
import 'package:uuid/uuid.dart';

import './address-port-badge.widget.dart';

class ServerOverview extends ConsumerStatefulWidget {
  final MockerizeServer server;
  final bool? isListItem;
  const ServerOverview({
    super.key,
    required this.server,
    this.isListItem,
  });

  @override
  ConsumerState<ServerOverview> createState() => _ServerOverviewState();
}

class _ServerOverviewState extends ConsumerState<ServerOverview> {
  final GlobalKey overviewKey = GlobalKey(debugLabel: 'server-overview');
  bool loaded = false;
  bool actionHovered = false;
  bool cardHovered = false;
  ScrollController descriptionScroll = ScrollController();

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
  void dispose() {
    // Clean up the controller when the widget is disposed.
    descriptionScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref
        .read(routersProvider.notifier)
        .getByServerID(widget.server.serverID);
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = widget.server.server != null ? true : false;

    List<Color> colorPalette = Theme.of(context).brightness == Brightness.dark
        ? heatMapColorPaletteDark
        : heatMapColorPaletteLight;

    BreakPointDetails size = mockerizeBreakSizes(context);
    BreakPointDetails localSize = loaded
        ? mockerizeObjectSizes(overviewKey)
        : BreakPointDetails(width: 0, height: 0, breakPoints: []);

    return MouseRegion(
      onEnter: (PointerEvent details) => setState(() {
        if (widget.isListItem != null) {
          cardHovered = true;
        }
      }),
      onExit: (PointerEvent details) => setState(() {
        if (widget.isListItem != null) {
          cardHovered = false;
        }
      }),
      child: Card(
        elevation: cardHovered ? 8 : 0,
        surfaceTintColor: widget.isListItem != null
            ? cardHovered
                ? colorScheme.surface
                : null
            : null,
        color: widget.isListItem != null
            ? !isActive & !cardHovered
                ? Theme.of(context).colorScheme.surface.withOpacity(0.6)
                : Theme.of(context).colorScheme.surface
            : Theme.of(context).colorScheme.surface,
        margin: EdgeInsets.zero,
        // clipBehavior: Clip.none,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () {
                if (widget.isListItem != null) {
                  context.push(
                    "/server/${widget.server.serverID}",
                    extra: 'server',
                  );
                }
              },
              child: MouseRegion(
                cursor: widget.isListItem != null
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.basic,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      key: overviewKey,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? colorScheme.primary
                            : Colors.black.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: !size.breakPoints.contains(BreakPoint.xs)
                          ? Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: ServerNameDisplay(
                                    name: widget.server!.name,
                                    isActive: isActive,
                                    size: size,
                                    localSize: localSize,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: 156,
                                      child: AddressPortBadge(
                                        address:
                                            widget.server.address.toString(),
                                        port: widget.server.port.toString(),
                                        active: isActive,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 40,
                                      child: LocalMenuWidget(
                                        serverID: widget.server.serverID,
                                        isActive: isActive,
                                        isListItem: widget.isListItem,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Flexible(
                                      child: ServerNameDisplay(
                                        name: widget.server.name,
                                        isActive: isActive,
                                        size: size,
                                        localSize: localSize,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 40,
                                      child: LocalMenuWidget(
                                        serverID: widget.server.serverID,
                                        isActive: isActive,
                                        isListItem: widget.isListItem,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    AddressPortBadge(
                                      address: widget.server.address.toString(),
                                      port: widget.server.port.toString(),
                                      active: isActive,
                                      alignment: Alignment.bottomLeft,
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                              ],
                            ),
                    ),
                    widget.isListItem == null &&
                            widget.server.description != null
                        ? ExpansionTile(
                            shape: const Border(),
                            title: const Text('Description'),
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                child: MarkdownParse(
                                  controller: descriptionScroll,
                                  selectable: true,
                                  data: widget.server.description!,
                                  shrinkWrap: true,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                    widget.isListItem == null &&
                            widget.server.description != null
                        ? ExpansionTile(
                            shape: const Border(),
                            title: const Text('Server Headers'),
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                child: HeaderList(
                                  headers: widget.server.headers,
                                  noMenu: true,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                    widget.isListItem != null
                        ? Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(
                                top: 8,
                              ),
                              width: double.infinity,
                              height: double.infinity,
                              child: SingleChildScrollView(
                                child: Opacity(
                                  opacity: isActive ? 1 : 0.3,
                                  child: LogsHeatmap(
                                    colorPalette: !isActive &&
                                            colorScheme.brightness ==
                                                Brightness.light
                                        ? heatMapColorPaletteMonochrome
                                        : colorPalette,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
            widget.isListItem != null
                ? Positioned(
                    bottom: 16,
                    left: 16,
                    child: Transform.scale(
                      scale: 1.3,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colorScheme.surface.withOpacity(0.5),
                            width: 4,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Badge(
                          backgroundColor: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          padding: const EdgeInsets.only(
                            left: 8,
                            right: 0,
                          ),
                          label: Row(
                            children: [
                              const Text('Routes '),
                              Badge(
                                backgroundColor: colorScheme.onSurface,
                                textColor: colorScheme.onPrimary,
                                label: Text(
                                    router?.routes.length.toString() ?? "0"),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
            Positioned(
              bottom: -20,
              right: -4,
              child: isActive
                  ? SpinningIcon(
                      icon: Icons.settings,
                      size: 80,
                      color: actionHovered == true
                          ? Colors.red
                          : Theme.of(context).colorScheme.onSurface,
                    )
                  : const SizedBox(),
            ),
            Positioned(
              bottom: -8,
              right: 8,
              child: MouseRegion(
                onEnter: (PointerEvent details) => setState(() {
                  actionHovered = true;
                }),
                onExit: (PointerEvent details) => setState(() {
                  actionHovered = false;
                }),
                child: FloatingActionButton(
                  // This shuts flutter up about having multiple null
                  // hero tags.
                  elevation: 0,
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  hoverColor:
                      isActive ? Colors.red : Theme.of(context).primaryColor,
                  heroTag: "start-stop-${const Uuid().v4()}",
                  shape: const CircleBorder(
                    side: BorderSide.none,
                  ),
                  child: Icon(
                    isActive ? Icons.stop : Icons.play_arrow,
                    size: 40,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  onPressed: () => {
                    widget.server.server != null
                        ? ref
                            .read(serversProvider.notifier)
                            .stopServer(widget.server.serverID)
                        : ref
                            .read(serversProvider.notifier)
                            .startServer(widget.server.serverID)
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServerNameDisplay extends StatelessWidget {
  final String name;
  final bool isActive;
  final BreakPointDetails size;
  final BreakPointDetails localSize;
  const ServerNameDisplay({
    super.key,
    required this.name,
    required this.isActive,
    required this.size,
    required this.localSize,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: isActive
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
          ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class LocalMenuWidget extends ConsumerStatefulWidget {
  final String serverID;
  final bool isActive;
  final bool? isListItem;
  const LocalMenuWidget({
    super.key,
    required this.serverID,
    this.isActive = false,
    this.isListItem = false,
  });

  @override
  ConsumerState<LocalMenuWidget> createState() => _LocalMenuWidgetState();
}

class _LocalMenuWidgetState extends ConsumerState<LocalMenuWidget> {
  void showLogs(BuildContext context, String id) {
    BreakPointDetails size = mockerizeBreakSizes(context);

    if (size.breakPoints.contains(BreakPoint.md)) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog.fullscreen(
            backgroundColor: Colors.white.withOpacity(0.0),
            // contentPadding: const EdgeInsets.all(0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  color: Theme.of(context).colorScheme.surface,
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: ServerLogs(
                    serverId: id,
                    callback: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            color: Theme.of(context).colorScheme.surface,
            width: double.infinity,
            child: ServerLogs(
              serverId: id,
              callback: () => Navigator.pop(context),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    List<BreakPoint> size = mockerizeBreakSizes(context).breakPoints;
    return SizedBox(
      width: 40,
      child: PopupMenuButton(
        iconColor: widget.isActive ? Colors.white : colorScheme.onSurface,
        onSelected: (String value) {
          switch (value) {
            case 'Logs':
              showLogs(context, widget.serverID);
              break;
            case 'Delete':
              ref.read(serversProvider.notifier).deleteServer(widget.serverID);
              if (ModalRoute.of(context)?.settings.name != "servers" &&
                  context.canPop()) {
                context.pop();
              } else {
                context.go("/");
              }
              break;
            default:
              context.push("/servers/${widget.serverID}/edit",
                  extra: ModalRoute.of(context)?.settings.name == '/'
                      ? 'home'
                      : 'server');
              break;
          }
        },
        itemBuilder: (BuildContext context) {
          List<String> menuItems = [
            'Edit',
            'Delete',
          ];

          if (widget.isListItem == true || !size.contains(BreakPoint.xl)) {
            menuItems.add('Logs');
          }

          return menuItems.map((String choice) {
            return PopupMenuItem<String>(
              value: choice,
              child: Text(choice),
            );
          }).toList();
        },
      ),
    );
  }
}
