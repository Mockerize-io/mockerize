import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../test/mocks/path_provider_mock.dart';
import 'tests/create_route_test.dart';
import 'tests/error_field_tests.dart';
import 'tests/create_server_test.dart';
import 'tests/edit_server_test.dart';
import 'tests/live_switching_test.dart';
import 'tests/server_test.dart';
import 'tests/view_server_test.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late final String storageDir;

  setUpAll(() async {
    // create the temporary directory if it doesn't exist
    final temporaryDir = await getTemporaryDirectory();

    storageDir = temporaryDir.path;

    Directory('$storageDir/.tmp_storage').createSync();

    // mock the path
    PathProviderPlatform.instance =
        MockPathProviderPlatform(workingPath: storageDir);
  });

  tearDownAll(() {
    // delete all the JSON files
    Directory('$storageDir/.tmp_storage').listSync().forEach((file) {
      if (file.path.endsWith('.json')) {
        file.deleteSync();
      }
    });
  });

  await createServerTest();
  await createServerErrorTest();
  await editServerTest();
  await viewServerTest();
  await createRouteTest();
  await serverTest();
  await liveSwitchingTest();
}
