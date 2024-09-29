import 'dart:io';

Future<bool> isPortInUse(int port, {dynamic address}) async {
  bool isInUse = false;
  ServerSocket? serverSocket;

  try {
    // Try to bind the port
    serverSocket = await ServerSocket.bind(
      address ?? InternetAddress.anyIPv4,
      port,
    );
  } on SocketException {
    // If an exception occurs, it's likely because the port is in use (or the port is privileged and thus wouldn't really be usable anyway)
    isInUse = true;
  } finally {
    // Close the socket if it was successfully created
    await serverSocket?.close();
  }

  return isInUse;
}

// Checks to see if a port is usable
Future<bool> canUsePort(int port) async {
  if (Platform.isWindows) {
    // AFAIK Windows doesn't restrict ports by default
    return true;
  } else {
    if (port > 1023) {
      return true;
    }
    try {
      // try to bind it, if it returns an err with err code of 13, no root
      ServerSocket serverSocket =
          await ServerSocket.bind(InternetAddress.anyIPv4, port);
      serverSocket.close();
    } on SocketException catch (e) {
      if (e.osError?.errorCode == 13) {
        return false;
      }
      // port may be in use, but if it's not error 13, it isn't a permission error
    }
    return true;
  }
}
