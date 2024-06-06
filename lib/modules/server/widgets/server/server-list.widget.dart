import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mockerize/modules/server/providers/servers.provider.dart';
import 'package:mockerize/modules/server/widgets/server/sever-overview.widget.dart';
import 'package:mockerize/theme/breakpoint.widget.dart';
import 'package:mockerize/theme/dotted_border/dotted_border.dart';
import 'package:mockerize/theme/mockerize_toggle_button.widget.dart';

class ServerList extends ConsumerStatefulWidget {
  const ServerList({
    super.key,
  });

  @override
  ConsumerState<ServerList> createState() => _ServerListState();
}

class _ServerListState extends ConsumerState<ServerList> {
  bool activeServers = false;
  bool sortServersReverse = false;
  TextEditingController search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ref.watch(serversProvider);

    final finalServers = ref.read(serversProvider.notifier).search(
          query: search.text,
          reverseSort: sortServersReverse,
          active: activeServers,
        );

    List<BreakPoint> size = mockerizeBreakSizes(context).breakPoints;

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            // padding: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: MockerizeToggleButton.icon(
                    selected: sortServersReverse,
                    onPressed: () => setState(() {
                      sortServersReverse = !sortServersReverse;
                    }),
                    icon: const Icon(Icons.sort_by_alpha),
                    fixedSize: WidgetStateProperty.resolveWith(
                      (state) => const Size(60, 60),
                    ),
                    shape: WidgetStateProperty.resolveWith(
                      (states) => const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: TextField(
                    enabled: !activeServers,
                    controller: search,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: search.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                setState(() {
                                  search.clear();
                                });
                              },
                              icon: const Icon(Icons.close),
                            ),
                      // border: InputBorder.none,
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.7),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.2),
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: size.contains(BreakPoint.sm)
                      ? MockerizeToggleButton(
                          selected: activeServers,
                          onPressed: () => setState(() {
                            activeServers = !activeServers;
                          }),
                          icon: const Icon(Icons.power_settings_new),
                          fixedSize: WidgetStateProperty.resolveWith(
                            (state) => const Size(170, 60),
                          ),
                          shape: WidgetStateProperty.resolveWith(
                            (states) => const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                          ),
                          child: const Text('Active Servers'),
                        )
                      : MockerizeToggleButton.icon(
                          selected: activeServers,
                          onPressed: () => setState(() {
                            activeServers = !activeServers;
                          }),
                          icon: const Icon(Icons.power_settings_new),
                          fixedSize: WidgetStateProperty.resolveWith(
                            (state) => const Size(60, 60),
                          ),
                          shape: WidgetStateProperty.resolveWith(
                            (states) => const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: finalServers.isNotEmpty
                ? GridView.builder(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      maxCrossAxisExtent: 800,
                      childAspectRatio: size.contains(BreakPoint.xl)
                          ? 2.8
                          : size.contains(BreakPoint.lg)
                              ? 2.6
                              : size.contains(BreakPoint.md)
                                  ? 2.4
                                  : size.contains(BreakPoint.sm)
                                      ? 2.5
                                      : 1.9,
                    ),
                    // itemCount: serverKeys.length,
                    itemCount: finalServers.length,
                    itemBuilder: (context, index) {
                      final server = finalServers[index];

                      return ServerOverview(
                        server: server,
                        isListItem: true,
                      );
                      // return finalServers.map((server) {
                      //   return ServerOverview(
                      //     server: server!,
                      //     isListItem: true,
                      //   );
                      // }).toList();
                    },
                  )
                : Center(
                    child: activeServers
                        ? const NoActiveServers()
                        : const NoServers(),
                  ),
          ),
        ),
      ],
    );
  }
}

class NoActiveServers extends StatelessWidget {
  const NoActiveServers({super.key});

  @override
  Widget build(BuildContext context) {
    List<BreakPoint> size = mockerizeBreakSizes(context).breakPoints;
    ThemeData themeScheme = Theme.of(context);
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return DottedBorder(
      color: colorScheme.onSurface.withOpacity(0.2),
      borderType: BorderType.RRect,
      dashPattern: const [16, 16],
      strokeWidth: 4,
      strokeCap: StrokeCap.round,
      radius: const Radius.circular(12),
      padding: const EdgeInsets.all(6),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Container(
          color: themeScheme.scaffoldBackgroundColor.withOpacity(0),
          padding: const EdgeInsets.all(24),
          child: Stack(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.dns,
                    size: 120,
                  ),
                  size.contains(BreakPoint.md)
                      ? Container(
                          padding: const EdgeInsets.only(
                            left: 16,
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'No Active Servers',
                                style: TextStyle(
                                  fontSize: 48,
                                ),
                              )
                            ],
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 80,
                child: Container(
                  width: 40,
                  height: 40,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: themeScheme.scaffoldBackgroundColor,
                  ),
                  child: Icon(
                    Icons.do_disturb,
                    size: 40,
                    color: themeScheme.scaffoldBackgroundColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoServers extends StatefulWidget {
  const NoServers({
    super.key,
  });

  @override
  State<NoServers> createState() => _NoServersState();
}

class _NoServersState extends State<NoServers> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    List<BreakPoint> size = mockerizeBreakSizes(context).breakPoints;
    ThemeData themeScheme = Theme.of(context);
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: isHovered ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (event) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (event) {
        setState(() {
          isHovered = false;
        });
      },
      child: DottedBorder(
        color: colorScheme.onSurface.withOpacity(isHovered ? 1 : 0.2),
        borderType: BorderType.RRect,
        dashPattern: const [16, 16],
        strokeWidth: 4,
        strokeCap: StrokeCap.round,
        radius: const Radius.circular(12),
        padding: const EdgeInsets.all(6),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: Container(
            color: colorScheme.onSurface.withOpacity(isHovered ? 0.1 : 0),
            padding: const EdgeInsets.all(24),
            child: GestureDetector(
              onTap: () => context.go(
                '/servers/add',
              ),
              child: Stack(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.dns,
                        size: 120,
                      ),
                      size.contains(BreakPoint.md)
                          ? Container(
                              padding: const EdgeInsets.only(
                                left: 16,
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Create a Server',
                                    style: TextStyle(
                                      fontSize: 48,
                                    ),
                                  )
                                ],
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    left: 80,
                    child: Container(
                      width: 40,
                      height: 40,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: themeScheme.scaffoldBackgroundColor,
                      ),
                      child: Icon(
                        Icons.add_circle_rounded,
                        size: 40,
                        color: isHovered
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
