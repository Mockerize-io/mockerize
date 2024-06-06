import 'dart:io';

Future<List<String>> getAdapterIPs() async {
  List<String> ips = ['127.0.0.1', '0.0.0.0'];
  for (var interface in await NetworkInterface.list()) {
    for (var addr in interface.addresses) {
      ips.add(addr.address.toString());
    }
  }

  return ips;
}
