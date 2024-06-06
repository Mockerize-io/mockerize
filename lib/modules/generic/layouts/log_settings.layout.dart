import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockerize/core/models/controller.dart';
import 'package:mockerize/core/models/mockerize_globals.model.dart';
import 'package:mockerize/core/providers/mockerize.provider.dart';
import 'package:mockerize/modules/generic/widgets/log_count.widget.dart';

class LogsSettings extends ConsumerStatefulWidget {
  const LogsSettings({super.key});

  @override
  ConsumerState<LogsSettings> createState() => _LogsSettingsState();
}

class _LogsSettingsState extends ConsumerState<LogsSettings> {
  bool hasChanges = false;

  LogSettings localLogSettings =
      LogSettings(load: false, save: false, maxLogsPerServer: 0);

  MockerizeTextController? logsPerServerController;

  @override
  void initState() {
    localLogSettings = ref.read(mockerizeProvider).logSettings;

    logsPerServerController = MockerizeTextController(
      controller: TextEditingController(
          text: localLogSettings.maxLogsPerServer.toString()),
      validation: (value) {
        if (value == null || value.isEmpty) {
          return "input is required";
        }

        int? port = int.tryParse(value);
        if (port == null) {
          return "input must be an actual number";
        }

        setLocalState();

        return null;
      },
    );

    super.initState();
  }

  void setLocalState(
      {bool? save, bool? load, int? logsPerServer, bool saved = false}) {
    setState(() {
      localLogSettings = LogSettings(
        load: load ?? localLogSettings.load,
        save: save ?? localLogSettings.save,
        maxLogsPerServer: logsPerServer ?? localLogSettings.maxLogsPerServer,
      );
      hasChanges = !saved;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Text('Save Logs'),
                  const Spacer(),
                  Switch(
                    // thumbIcon: thumbIcon,
                    value: localLogSettings.save,
                    onChanged: (bool value) {
                      setLocalState(save: value);
                      ref
                          .read(mockerizeProvider.notifier)
                          .applyLogSettings(saveLogs: value);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  const Text('Load Logs on Launch'),
                  const Spacer(),
                  Switch(
                      // thumbIcon: thumbIcon,
                      value: localLogSettings.load,
                      onChanged: (bool value) {
                        setLocalState(load: value);
                        ref
                            .read(mockerizeProvider.notifier)
                            .applyLogSettings(loadLogs: value);
                      }),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Max Logs Per Server'),
                  Flexible(child: LogCount()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
