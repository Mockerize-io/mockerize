import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mockerize/core/utils/color-tools.dart';
import 'package:mockerize/modules/server/components/mockerize-router.dart';
import 'package:mockerize/modules/server/models/endpoint.dart';
import 'package:mockerize/modules/server/models/header.dart';
import 'package:mockerize/modules/server/providers/routers.provider.dart';
import 'package:mockerize/modules/server/providers/servers.provider.dart';
import 'package:mockerize/modules/server/widgets/header/header-list.widget.dart';
import 'package:mockerize/theme/breakpoint.widget.dart';

class RouteOverview extends ConsumerStatefulWidget {
  final String serverId;
  final ServerRoute route;
  final BreakPointDetails size;
  const RouteOverview({
    super.key,
    required this.serverId,
    required this.route,
    required this.size,
  });

  @override
  ConsumerState<RouteOverview> createState() => _RouteOverviewState();
}

class _RouteOverviewState extends ConsumerState<RouteOverview> {
  bool cardHovered = false;

  Map<String, Header> constructHeadersList(List<Header> serverHeaders) {
    var headers = {for (var header in serverHeaders) header.key: header};

    headers = {
      ...headers,
      ...{for (var header in widget.route.headers) header.key: header},
      ...{
        for (var header in widget.route.responses
            .firstWhere((element) => element.id == widget.route.activeResponse)
            .headers)
          header.key: header
      },
    };

    return headers;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(routersProvider);
    final router =
        ref.read(routersProvider.notifier).getByServerID(widget.serverId)!;
    final colorScheme = Theme.of(context).colorScheme;

    final headers = constructHeadersList(
        ref.read(serversProvider)[widget.serverId]!.headers);

    widget.route.responses
        .sort((a, b) => a.status.code.compareTo(b.status.code));

    // final size = mockerizeBreakSizes(context);
    final size = widget.size;

    return MouseRegion(
      onEnter: (PointerEvent details) => setState(() {
        cardHovered = true;
      }),
      onExit: (PointerEvent details) => setState(() {
        cardHovered = false;
      }),
      child: Card(
        color: Theme.of(context).colorScheme.surface,
        elevation: cardHovered ? 8 : 0,
        surfaceTintColor: cardHovered
            ? Theme.of(context).colorScheme.onSurface
            : const Color.fromARGB(0, 255, 255, 255),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: size.breakPoints.contains(BreakPoint.xl)
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 5,
                            child: NameAndRoute(
                              colorScheme: colorScheme,
                              widget: widget,
                              size: size,
                            ),
                          ),
                          // const Spacer(),
                          Expanded(
                            flex: 5,
                            child: Row(
                              children: [
                                Flexible(
                                  child: ResponseSelection(
                                    size: size,
                                    widget: widget,
                                    ref: ref,
                                    router: router,
                                    colorScheme: colorScheme,
                                  ),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Actions(
                                    ref: ref,
                                    router: router,
                                    widget: widget,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ExpansionTile(
                      backgroundColor: Colors.black.withOpacity(0.0),
                      collapsedBackgroundColor: Colors.black.withOpacity(0.0),
                      shape: const Border(),
                      title: const Text('Active Headers'),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          child: HeaderList(
                            headers: [...headers.values],
                            noMenu: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                            child: NameAndRoute(
                              colorScheme: colorScheme,
                              widget: widget,
                              size: size,
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: Actions(
                              ref: ref,
                              router: router,
                              widget: widget,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 8.0,
                      ),
                      child: ResponseSelection(
                        size: size,
                        widget: widget,
                        ref: ref,
                        router: router,
                        colorScheme: colorScheme,
                      ),
                    ),
                    ExpansionTile(
                      shape: const Border(),
                      title: const Text('Active Headers'),
                      backgroundColor: Colors.black.withOpacity(0.0),
                      collapsedBackgroundColor: Colors.black.withOpacity(0.0),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          child: HeaderList(
                            headers: [...headers.values],
                            noMenu: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class Actions extends StatelessWidget {
  const Actions({
    super.key,
    required this.ref,
    required this.router,
    required this.widget,
  });

  final WidgetRef ref;
  final MockerizeRouter router;
  final RouteOverview widget;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: (String value) {
        switch (value) {
          case 'Delete':
            ref.read(routersProvider.notifier).deleteRoute(
                  router.id,
                  widget.route.id,
                );
            break;
          default:
            context.push(
                '/server/${widget.serverId}/route/${widget.route.id}/edit',
                extra: 'edit-route');
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return {'Edit', 'Delete'}.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(choice),
          );
        }).toList();
      },
    );
  }
}

class ResponseSelection extends StatelessWidget {
  const ResponseSelection({
    super.key,
    required this.size,
    required this.widget,
    required this.ref,
    required this.router,
    required this.colorScheme,
  });

  final BreakPointDetails size;
  final RouteOverview widget;
  final WidgetRef ref;
  final MockerizeRouter router;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    const statusWidth = 350; // Largest badge with text
    const chevronOffset = 64; // menu chevron width
    final halfWidth = size.width / 2;
    final statusNameVisible = size.breakPoints.contains(BreakPoint.xl)
        ? halfWidth / 2 - chevronOffset > statusWidth
        : halfWidth - chevronOffset > statusWidth;

    return Container(
      padding: const EdgeInsets.only(
        right: 8,
        left: 8,
      ),
      child: DropdownButton(
        isDense: true,
        isExpanded: true,
        underline: const SizedBox(),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        value: widget.route.activeResponse,
        hint: const Text('Active Response'),
        onChanged: (String? newValue) {
          ref.read(routersProvider.notifier).setActiveResponse(
                router.id,
                widget.route.id,
                newValue!,
              );
        },
        items: widget.route.responses
            .map<DropdownMenuItem<String>>((Response response) {
          return DropdownMenuItem<String>(
            value: response.id,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    child: Text(
                      response.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                    ),
                    child: Badge(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 0,
                      ),
                      backgroundColor: response.status.color,
                      textColor: colorScheme.onPrimary,
                      label: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              response.status.code.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          statusNameVisible
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: lighten(response.status.color),
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        bottomLeft: Radius.circular(8)),
                                  ),
                                  child: Text(
                                    response.status.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            child: Text(
                              response.responseType.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class NameAndRoute extends StatelessWidget {
  final ColorScheme colorScheme;
  final RouteOverview widget;
  final BreakPointDetails size;
  const NameAndRoute({
    super.key,
    required this.colorScheme,
    required this.widget,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Badge(
            backgroundColor: Theme.of(context).primaryColor,
            textColor: colorScheme.onPrimary,
            label: Text(
              widget.route.method.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Flexible(
          child: Text(
            widget.route.path,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
