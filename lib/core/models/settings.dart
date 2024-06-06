import 'package:flutter/material.dart';

class Settings {
  final ThemeMode theme;
  final bool saveLogs;
  final bool loadLogs;
  final int logsPerServer;

  const Settings({
    this.theme = ThemeMode.system,
    this.saveLogs = true,
    this.loadLogs = true,
    this.logsPerServer = 100,
  });

  Settings.fromJson(Map json)
      : theme = json['theme'] == 'dark' ? ThemeMode.dark : ThemeMode.light,
        saveLogs = json['save_logs'] ?? true,
        loadLogs = json['load_logs'] ?? true,
        logsPerServer = json['logs_per_server'] ?? 100;

  Map<String, dynamic> toJson() => {
        'theme': theme.name,
        'save_logs': saveLogs,
        'load_logs': loadLogs,
        'logs_per_server': logsPerServer,
      };
}
