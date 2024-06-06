import 'package:flutter/material.dart';

class MockerizeActionModel {
  final VoidCallback action;
  final IconData icon;
  final String title;
  final bool disabled;

  MockerizeActionModel({
    required this.action,
    required this.icon,
    required this.title,
    this.disabled = false,
  });

  MockerizeActionModel.fromJson(Map<String, dynamic> json)
      : action = json['action'],
        icon = json['icon'],
        title = json['title'],
        disabled = false;

  Map<String, dynamic> toJson() => {
        'action': action,
        'icon': icon,
        'title': title,
      };
}

class LogSettings {
  final bool load;
  final bool save;
  final int maxLogsPerServer;

  LogSettings({
    required this.load,
    required this.save,
    required this.maxLogsPerServer,
  });
}

class MockerizeGlobalParameters {
  final MockerizeActionModel? globalAction;
  final ThemeMode themeMode;
  final bool loading;
  final LogSettings logSettings;

  MockerizeGlobalParameters({
    this.globalAction,
    required this.themeMode,
    required this.loading,
    required this.logSettings,
  });
}
