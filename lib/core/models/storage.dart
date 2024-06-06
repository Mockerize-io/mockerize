import 'package:mockerize/core/models/settings.dart';
import 'package:mockerize/modules/server/models/log.dart';
import 'package:mockerize/modules/server/models/server.dart';

enum StorageType {
  server(
    extension: '.server.json',
    loadsMultiple: true,
    fromJson: ServerStorage.fromJson,
  ),
  settings(
    extension: '.settings.json',
    loadsMultiple: false,
    fromJson: Settings.fromJson,
  ),
  log(
    extension: '.log.json',
    loadsMultiple: true,
    fromJson: LogStorage.fromJson,
  );

  final String extension;
  final bool loadsMultiple;
  final Function(Map<dynamic, dynamic>) fromJson;

  const StorageType({
    required this.extension,
    required this.loadsMultiple,
    required this.fromJson,
  });
}
