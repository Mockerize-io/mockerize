import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockerize/modules/server/models/log.dart';

class ServerLog extends ConsumerWidget {
  final ResponseLog log;

  const ServerLog({
    super.key,
    required this.log,
  });

  String formatDuration(Duration time) {
    if (time.inMilliseconds == 0) {
      // we're dealing with microseconds
      return "${time.inMicroseconds} μs";
    } else if (time.inSeconds == 0) {
      // we're dealing with milliseconds
      return "${time.inMilliseconds} ms";
    } else if (time.inMinutes == 0) {
      // we're dealing with seconds
      return "${time.inSeconds} s";
    }

    return "";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Path: ${log.request.path}"),
          Text("Method: ${log.request.method.name}"),
          const Divider(),
          const Text(
            "Headers",
            style: TextStyle(fontSize: 25),
          ),
          Text(log.request.headers.entries
              .map((e) => "${e.key}: ${e.value}")
              .toList()
              .join(",\n")),
          const Divider(),
          const Text(
            "Body",
            style: TextStyle(fontSize: 25),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            log.request.body.toString(),
            overflow: TextOverflow.ellipsis,
          ),
          const Divider(),
          const Text(
            "Response",
            style: TextStyle(fontSize: 25),
          ),
          Text("IP: ${log.request.ip}"),
          Text("Status: ${log.status}"),
          Text("Response Time: ${formatDuration(log.responseTime)}"),
        ],
      ),
    );
  }
}
