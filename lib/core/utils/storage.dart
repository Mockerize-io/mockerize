import 'dart:convert';
import 'dart:io';

import 'package:mockerize/core/models/storage.dart';
import 'package:path_provider/path_provider.dart';
// TODO clean filenames;

Future<void> save(String filename, StorageType type, dynamic data) async {
  try {
    // get our storage directory
    final String storageDir = (await getApplicationSupportDirectory()).path;
    print('[Storage location] $storageDir');
    // Create a file based on the provided name and storage type extension
    final File file = File("$storageDir/$filename${type.extension}");
    // Save the file (data should implement toJson)
    await file.writeAsString(jsonEncode(data), flush: true);
  } catch (e) {
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      print("failed to save $e");
    }
  }
}

Future<void> delete(String filename, StorageType type) async {
  try {
    final String storageDir = (await getApplicationSupportDirectory()).path;

    final File file = File("$storageDir/$filename${type.extension}");

    await file.delete();
  } catch (e) {
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      print("failed to delete $e");
    }
  }
}

Future<dynamic> load<Model>(StorageType type) async {
  try {
    final Directory storageDir = await getApplicationSupportDirectory();
    print('[Storage location] $storageDir');

    List<String> filesToLoad = await storageDir
        .list()
        .where((file) => file.path.endsWith(type.extension))
        .map((file) => file.path)
        .toList();

    if (filesToLoad.isEmpty) {
      // No files? Just return empty.
      return type.loadsMultiple ? List<Model>.empty() : null;
    }

    // If we're returning multiple, we'll create a list of the provided
    // model type
    List<Model> data = [];

    for (String path in filesToLoad) {
      File file = File(path);

      if (!type.loadsMultiple) {
        // If it's just a single item we can return once we have it
        return type.fromJson(jsonDecode(await file.readAsString()));
      }

      data.add(type.fromJson(jsonDecode(await file.readAsString())));
    }

    return data;
  } catch (e) {
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      print('failed to load data $e');
    }
  }
  return type.loadsMultiple ? [] : {};
}
