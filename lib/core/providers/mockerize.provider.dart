import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockerize/core/models/mockerize_globals.model.dart';
import 'package:mockerize/core/models/settings.dart';
import 'package:mockerize/core/models/storage.dart';
import 'package:mockerize/core/utils/storage.dart';
import 'package:mockerize/modules/server/providers/log.provider.dart';

class MockerizeProvider extends StateNotifier<MockerizeGlobalParameters> {
  final Ref ref;

  MockerizeProvider(
    this.ref, {
    Settings initialSettings = const Settings(),
  }) : super(
          MockerizeGlobalParameters(
            globalAction: null,
            themeMode: initialSettings.theme,
            loading: true,
            logSettings: LogSettings(
              load: initialSettings.loadLogs,
              save: initialSettings.saveLogs,
              maxLogsPerServer: initialSettings.logsPerServer,
            ),
          ),
        ) {
    initialize();
  }

  void initialize() async {
    state = MockerizeGlobalParameters(
      globalAction: state.globalAction,
      themeMode: state.themeMode,
      logSettings: state.logSettings,
      loading: false,
    );

    if (state.logSettings.save) {
      ref.read(logProvider.notifier).startTimer();
    }
  }

  void setGlobalTheme(ThemeMode themeMode) {
    state = MockerizeGlobalParameters(
      globalAction: state.globalAction,
      themeMode: themeMode,
      logSettings: state.logSettings,
      loading: false,
    );

    save("mockerize", StorageType.settings, Settings(theme: themeMode));
  }

  void setGlobalLogSettings(LogSettings logSettings) {
    state = MockerizeGlobalParameters(
      themeMode: state.themeMode,
      globalAction: state.globalAction,
      loading: false,
      logSettings: logSettings,
    );

    if (logSettings.save) {
      // Start the log saving timer
      ref.read(logProvider.notifier).startTimer();
    } else {
      // Stop the log saving timer.
      ref.read(logProvider.notifier).stopTimer();
    }

    save(
      "mockerize",
      StorageType.settings,
      Settings(
        theme: state.themeMode,
        loadLogs: logSettings.load,
        saveLogs: logSettings.save,
        logsPerServer: logSettings.maxLogsPerServer,
      ),
    );
  }

  void applyLogSettings({bool? loadLogs, bool? saveLogs, int? logCount}) {
    LogSettings newLogSettings = LogSettings(
      load: loadLogs ?? state.logSettings.load,
      save: saveLogs ?? state.logSettings.save,
      maxLogsPerServer: logCount ?? state.logSettings.maxLogsPerServer,
    );

    state = MockerizeGlobalParameters(
      globalAction: state.globalAction,
      themeMode: state.themeMode,
      logSettings: newLogSettings,
      loading: false,
    );

    if (saveLogs != null) {
      // Start the log saving timer
      ref.read(logProvider.notifier).startTimer();
    } else {
      // Stop the log saving timer.
      ref.read(logProvider.notifier).stopTimer();
    }

    save(
      "mockerize",
      StorageType.settings,
      Settings(
        theme: state.themeMode,
        loadLogs: newLogSettings.load,
        saveLogs: newLogSettings.save,
        logsPerServer: newLogSettings.maxLogsPerServer,
      ),
    );
  }

  void setGlobalAction(MockerizeActionModel? action) {
    if (state.loading) {
      // print('no change occurred');
      return;
    }

    state = MockerizeGlobalParameters(
      globalAction: action,
      themeMode: state.themeMode,
      logSettings: state.logSettings,
      loading: false,
    );
    // print('change occurred');
    return;
  }

  void setGlobalActionDisabled(bool disabled) {
    if (state.loading || state.globalAction == null) {
      return;
    }

    state = MockerizeGlobalParameters(
      globalAction: MockerizeActionModel(
        action: state.globalAction!.action,
        icon: state.globalAction!.icon,
        title: state.globalAction!.title,
        disabled: disabled,
      ),
      themeMode: state.themeMode,
      logSettings: state.logSettings,
      loading: false,
    );

    return;
  }
}

final mockerizeProvider = StateNotifierProvider.autoDispose<MockerizeProvider,
    MockerizeGlobalParameters>(
  (ref) => MockerizeProvider(ref),
);
