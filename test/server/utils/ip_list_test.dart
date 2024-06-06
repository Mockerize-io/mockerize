import 'dart:io';

import 'package:mockerize/modules/server/utils/ip-list.dart';
import 'package:test/test.dart';

void main() {
  test("getAdapterIPs should contain 127.0.0.1 and 0.0.0.0", () async {
    expect((await getAdapterIPs()), containsAll(["127.0.0.1", "0.0.0.0"]));
  });
}
