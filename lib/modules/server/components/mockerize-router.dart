import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:mockerize/core/utils/sanitize.dart';
import 'package:mockerize/modules/server/models/endpoint.dart';
import 'package:mockerize/modules/server/models/header.dart';
import 'package:mockerize/modules/server/models/log.dart';

class MockerizeRouter {
  final String id;
  final HttpServer? server;
  final String serverId;
  final List<ServerRoute> routes;
  final Function(String serverId, String routerId, ResponseLog log)? logger;
  final Function? restarter; // Used to restart the server if an error occurs
  final List<Header> serverHeaders;

  const MockerizeRouter({
    required this.id,
    this.server,
    required this.serverId,
    required this.routes,
    required this.logger,
    required this.restarter,
    required this.serverHeaders,
  });

  MockerizeRouter.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        server = null,
        serverId = json['serverId'],
        logger = null,
        restarter = null,
        routes = (json['routes'] as List)
            .map((route) => ServerRoute.fromJson(route))
            .toList(),
        serverHeaders = [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'serverId': serverId,
        'routes': routes,
      };

  ResponseLog _generateLog(
    HttpRequest request,
    DateTime startTime,
    int status,
    String path,
    Method method,
    dynamic body, {
    String? responseId,
    String? routeId,
  }) {
    final finishTime = DateTime.now();
    final Map<String, String> headers = {};

    request.headers.forEach((key, values) {
      headers[key] = values.join(", ");
    });

    // final body = await utf8.decodeStream(request);
    // print(body);

    return ResponseLog(
      date: finishTime,
      status: status,
      responseTime: finishTime.difference(startTime),
      responseId: responseId,
      routeId: routeId,
      request: Request(
        ip: request.connectionInfo?.remoteAddress.address ?? 'UNKNOWN IP',
        method: method,
        headers: headers, // TODO  request.headers
        userAgent: request.headers.value('User-Agent') ?? 'N/A',
        path: path,
        size: request.contentLength,
        body: body, // TODO
      ),
    );
  }

  void _handle404(HttpRequest request, DateTime startTime, dynamic body) {
    request.response.statusCode = 404;
    request.response.write("Not Found\n");
    request.response.close();

    logger!(
      serverId,
      id,
      _generateLog(
        request,
        startTime,
        404,
        sanitizePath(request.uri),
        Method.values.firstWhereOrNull(
              (method) => method.name == request.method.toUpperCase(),
            ) ??
            Method.unknown,
        body,
      ),
    );
    return;
  }

  void _handleError(HttpRequest request, DateTime startTime, {dynamic body}) {
    try {
      request.response.statusCode = 500;
      request.response.write("Mockerize Server Error\n");
      request.response.close();

      logger!(
        serverId,
        id,
        _generateLog(
          request,
          startTime,
          500,
          sanitizePath(request.uri),
          Method.values.firstWhereOrNull(
                (method) => method.name == request.method.toUpperCase(),
              ) ??
              Method.unknown,
          body,
        ),
      );
    } catch (_) {
      if (restarter != null) {
        // If an error occurs above, we'll need to restart the server
        // otherwise no future requests will be responded to.
        restarter!(serverId, false);
      }
    }

    return;
  }

  Future<dynamic> _decodeBody(HttpRequest request) async {
    // Check the length
    // TODO change this to user setting
    if (request.contentLength > 5000000) {
      return "Content Execeeded Limit";
    }

    if (request.headers.contentType?.mimeType == null) {
      return "No Data";
    }

    // TODO clean this up later.
    try {
      switch (request.headers.contentType?.mimeType) {
        case "multipart/form-data":
          // multi-part might not contain a file all the time, but we can't know
          // for certain.
          return "Multipart Data";
        case "application/json":
        case "text/plain":
        case "application/javascript":
        case "text/html":
        case "application/xml":
        case "application/x-www-form-urlencoded":
          final data = await utf8.decoder.bind(request).join();
          return data;
        case "application/octet-stream":
        default:
          print(request.headers.contentType?.mimeType);
          return "Binary Data";
      }
    } catch (_) {
      return "Bad Data";
    }
  }

  void _mainHandler() async {
    if (server == null) {
      return;
    }

    await server!.forEach((HttpRequest request) async {
      final startTime = DateTime.now();
      dynamic body = "N/A";
      try {
        body = await _decodeBody(request);
        // final body = await utf8.decodeStream(request);
        // print(request.headers.contentType);
        // check to see if we have any routes set up for this method
        var method = request.method.toLowerCase();

        var possibleRoutes = routes.where((route) =>
            route.method == Method.values.byName(method.toLowerCase()));

        if (possibleRoutes.isEmpty) {
          // Does not have it, return a 404
          _handle404(request, startTime, body);

          return;
        }

        var endpoint = request.uri;
        var endpointPath = sanitizePath(endpoint);
        ServerRoute? possibleRoute = possibleRoutes
            .firstWhereOrNull((route) => route.path == endpointPath);

        // Check for the endpoint in the filtered list
        if (possibleRoute == null) {
          // do an extended check to see if there's any routes that have a name parameter
          possibleRoutes = possibleRoutes.where((route) {
            if (!route.path.contains(":")) {
              return false;
            }

            var path = route.path;

            // Strip out the starting slash so we can make sure length checks are accurate
            if (path.startsWith("/")) {
              path = route.path.substring(1);
            }

            var pathParts = path.split("/"); // Split into parts
            var segmentParts = endpoint.pathSegments
                .whereNot((element) => element.isEmpty)
                .toList();

            // count the endpoint parts
            if (pathParts.length != segmentParts.length) {
              return false;
            }

            // Now loop through the path parts and compare them to the corrasponding segment parts

            for (final (index, part) in pathParts.indexed) {
              // Skip the parameter part
              if (part.contains(":")) {
                continue;
              }

              // Compare the current part to the index of the segment parts
              if (part != segmentParts[index]) {
                return false;
              }
            }

            return true;
          });

          if (possibleRoutes.isEmpty) {
            _handle404(request, startTime, body);
            return;
          }

          if (possibleRoutes.length == 1) {
            possibleRoute = possibleRoutes.first;
          } else {
            // loop through the results
            var finalEndpoint = possibleRoutes.first;
            for (final (index, endpoint) in possibleRoutes.indexed) {
              if (index == 0) {
                continue;
              }

              /**  
             * non named endpoints should take priority over the named ones
             * for example if you have /hello/:name/:something and /hello/:name/cool
             * if the user hits /hello/John/cool, they should hit the /home/:name/cool endpoint function
             * rather than the /hello/:name/:something endpoint function
             */

              if (":".allMatches(finalEndpoint.path).length >
                  ":".allMatches(endpoint.path).length) {
                // the current finalEndpoint is likely ending with a named parameter, and so should not take priority
                finalEndpoint = endpoint;
              }
            }
            possibleRoute = finalEndpoint;
          }
        }

        // If the endpoint exists, call the function

        final response = possibleRoute.responses
            .firstWhereOrNull((response) => response.active);

        if (response == null) {
          _handle404(request, startTime, body);
          return;
        }

        request.response.statusCode = response.status.code;
        // If this header is set within the user defined headers, then this
        // will get overriden.
        request.response.headers.contentType =
            response.responseType == ResponseType.json
                ? ContentType.json
                : ContentType.text;

        /// With this setup, it acts like a reverse ACL
        /// The response has the highest priority
        /// The route has the second highest priority
        /// The server has the lowest priority
        for (var header in [
          ...serverHeaders, // server
          ...possibleRoute.headers, // route
          ...response.headers // response
        ]) {
          if (header.active) {
            // Haven't found a way yet to add a bunch of headers all at once
            request.response.headers.set(header.key, header.value);
          }
        }
        request.response.write("${response.response}\n");
        request.response.close();

        logger!(
          serverId,
          id,
          _generateLog(
            request,
            startTime,
            response.status.code,
            endpointPath,
            possibleRoute.method,
            body,
            responseId: response.id,
            routeId: possibleRoute.id,
          ),
        );
      } catch (err) {
        print(err);
        _handleError(request, startTime, body: body);
      }

      return;
    });
  }

  ServerRoute getByID(String routeID) {
    return routes.firstWhere((route) => route.id == routeID);
  }

  void start() {
    _mainHandler();
  }
}
