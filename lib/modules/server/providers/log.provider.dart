import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockerize/core/models/storage.dart';
import 'package:mockerize/core/providers/mockerize.provider.dart';
import 'package:mockerize/core/utils/storage.dart';
import 'package:mockerize/modules/server/models/log.dart';
import 'package:mockerize/modules/server/providers/servers.provider.dart';

class LogProvider extends StateNotifier<Map<String, List<ResponseLog>>> {
  final Ref ref;
  Timer? logSaver;

  LogProvider(this.ref, Map<String, List<ResponseLog>> data) : super(data);

  Future<void> setState(String id, {List<ResponseLog>? logs}) async {
    if (logs == null) {
      state = {
        ...Map<String, List<ResponseLog>>.fromEntries(
            state.entries.where((element) => element.key != id)),
      };
    } else {
      state = {...state, id: logs};
    }
  }

  Future<void> addLog(String serverId, ResponseLog log) async {
    final tmpLogs = state[serverId] ?? [];

    tmpLogs.add(log);

    final maxLogs = ref.read(mockerizeProvider).logSettings.maxLogsPerServer;

    if (tmpLogs.length > maxLogs) {
      // remove the first number of logs over by the list
      // e.g if we're over by 10, remove the first 10 logs and so on.
      tmpLogs.removeRange(0, tmpLogs.length - maxLogs);
    }

    await setState(serverId, logs: tmpLogs);
  }

  Future<void> deleteServer(String serverId) async {
    await setState(serverId);
    // also delete the log on disk
    await delete(serverId, StorageType.log);
  }

  Future<void> deleteLogsForServer(String serverId) async {
    await setState(serverId, logs: []);
    // also delete the log on disk
    await delete(serverId, StorageType.log);
  }

  void startTimer() {
    if (logSaver != null && logSaver!.isActive) {
      return;
    }

    logSaver = Timer.periodic(const Duration(minutes: 1), (timer) {
      ref
          .read(serversProvider)
          .entries
          .where((server) => server.value.newLogs)
          .forEach((server) async {
        final logItem = LogStorage(
          logs: state[server.key]!,
          serverId: server.key,
        );

        // save the logs
        await save(server.key, StorageType.log, logItem);
        // mark the server as clean
        await ref.read(serversProvider.notifier).markServer(server.key, false);
      });
    });
  }

  void stopTimer() {
    if (logSaver == null || !logSaver!.isActive) {
      return;
    }

    logSaver!.cancel();
  }

  @override
  void dispose() {
    // ensures that the timer is stopped when the provider is disposed.
    stopTimer();
    super.dispose();
  }
}

final logProvider = StateNotifierProvider.autoDispose<LogProvider,
    Map<String, List<ResponseLog>>>(
  (ref) => LogProvider(ref, {}),
);
