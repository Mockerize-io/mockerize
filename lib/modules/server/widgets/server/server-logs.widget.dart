import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockerize/modules/server/models/log.dart';
import 'package:mockerize/modules/server/providers/log.provider.dart';
import 'package:mockerize/modules/server/widgets/server/log-title-badge.widget.dart';
import 'package:mockerize/modules/server/widgets/server/server-log.widget.dart';

class ServerLogs extends ConsumerStatefulWidget {
  const ServerLogs({
    super.key,
    required this.serverId,
    this.callback,
  });

  final String serverId;
  final VoidCallback? callback;

  @override
  createState() => _ServerLogsState();
}

class _ServerLogsState extends ConsumerState<ServerLogs> {
  final ScrollController sc = ScrollController(keepScrollOffset: true);
  bool autoScroll = false;

  @override
  void initState() {
    sc.addListener(() {
      if (sc.offset == sc.position.maxScrollExtent) {
        setState(() {
          autoScroll = true;
        });
      } else {
        setState(() {
          autoScroll = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<ResponseLog> logs = ref.watch(logProvider)[widget.serverId] ?? [];
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (autoScroll) {
        sc.jumpTo(sc.position.maxScrollExtent);
      }
    });

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 32,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Logs',
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              widget.callback != null
                  ? IconButton(
                      onPressed: widget.callback,
                      icon: const Icon(Icons.close),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: logs.isNotEmpty
                ? ListView.builder(
                    controller: sc,
                    itemCount: logs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 16),
                        surfaceTintColor: const Color.fromARGB(0, 0, 0, 0),
                        clipBehavior: Clip.hardEdge,
                        child: ExpansionTile(
                          backgroundColor: Colors.black.withOpacity(0.1),
                          collapsedBackgroundColor:
                              Colors.black.withOpacity(0.1),
                          dense: true,
                          shape: const Border(),
                          title: Row(
                            children: [
                              SelectionArea(
                                child: LogTitleBadge(
                                  date: logs[index].date,
                                  method: logs[index].request.method,
                                ),
                              ),
                              Expanded(
                                child: SelectionArea(
                                  child: Text(
                                    logs[index].request.path,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () async {
                                  await Clipboard.setData(
                                    ClipboardData(
                                      text: jsonEncode(logs[index]),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.copy,
                                ),
                                color: colorScheme.onSurface,
                              ),
                            ],
                          ),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              child: ServerLog(log: logs[index]),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : Center(
                    child: Icon(
                      Icons.description_outlined,
                      size: 400,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.15),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
