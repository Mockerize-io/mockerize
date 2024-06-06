/// cleans up a URL path
String sanitizePath(Uri path) {
  String newPath =
      path.normalizePath().path.trim().replaceAll(RegExp("[/]{2,}"), "/");

  if (newPath.endsWith("/") && newPath.length > 1) {
    // remove ending slash
    newPath = newPath.substring(0, newPath.length - 1);
  }

  return newPath;
}
