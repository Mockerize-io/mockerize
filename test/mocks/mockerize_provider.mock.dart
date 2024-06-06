import 'package:flutter/material.dart';
import 'package:mockerize/core/models/mockerize_globals.model.dart';
import 'package:mockerize/core/providers/mockerize.provider.dart';

class MockMockerizeProvider extends MockerizeProvider {
  MockMockerizeProvider(super.ref);

  @override
  final state = MockerizeGlobalParameters(
      themeMode: ThemeMode.system,
      loading: false,
      logSettings: LogSettings(
        maxLogsPerServer: 5,
        save: false,
        load: false,
      ));
}
