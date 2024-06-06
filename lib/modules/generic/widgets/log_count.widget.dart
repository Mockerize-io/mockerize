import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockerize/core/models/mockerize_globals.model.dart';
import 'package:mockerize/core/providers/mockerize.provider.dart';

class LogOption {
  final int count;
  final String label;

  LogOption({
    required this.count,
    required this.label,
  });
}

List<LogOption> list = <LogOption>[
  LogOption(
    count: 0,
    label: 'None',
  ),
  LogOption(
    count: 10,
    label: '10',
  ),
  LogOption(
    count: 20,
    label: '20',
  ),
  LogOption(
    count: 50,
    label: '50',
  ),
  LogOption(
    count: 100,
    label: '100',
  ),
];

class LogCount extends ConsumerStatefulWidget {
  const LogCount({super.key});

  @override
  ConsumerState<LogCount> createState() => _LogCountState();
}

class _LogCountState extends ConsumerState<LogCount> {
  LogOption dropdownValue = list.first;

  @override
  void initState() {
    LogSettings storedSettings = ref.read(mockerizeProvider).logSettings;

    setState(() {
      // Select the matching item or use the first item in the list
      dropdownValue = list.firstWhereOrNull(
              (item) => item.count == storedSettings.maxLogsPerServer) ??
          list.first;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 8,
      ),
      child: DropdownButton<LogOption>(
        underline: const SizedBox(),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        value: dropdownValue,
        onChanged: (LogOption? value) {
          // This is called when the user selects an item.
          setState(() {
            dropdownValue = value!;
          });

          ref
              .read(mockerizeProvider.notifier)
              .applyLogSettings(logCount: value?.count ?? 0);
        },
        items: list.map<DropdownMenuItem<LogOption>>((LogOption value) {
          return DropdownMenuItem<LogOption>(
            value: value,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 0,
              ),
              child: Text(value.label),
            ),
          );
        }).toList(),
      ),
    );
  }
}
