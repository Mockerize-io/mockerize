import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String workingPath;

  MockPathProviderPlatform({this.workingPath = '.'});

  @override
  Future<String?> getTemporaryPath() async {
    return '$workingPath/.tmp_storage';
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    return '$workingPath/.tmp_storage';
  }

  @override
  Future<String?> getLibraryPath() async {
    return '$workingPath/.tmp_storage';
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '$workingPath/.tmp_storage';
  }

  @override
  Future<String?> getExternalStoragePath() async {
    return '$workingPath/.tmp_storage';
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    return <String>['$workingPath/.tmp_storage'];
  }

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    return <String>['$workingPath/.tmp_storage'];
  }

  @override
  Future<String?> getDownloadsPath() async {
    return '$workingPath/.tmp_storage';
  }
}
