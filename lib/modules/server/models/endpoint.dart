import 'package:mockerize/modules/server/models/header.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

enum Method {
  get("GET"),
  put("PUT"),
  post("POST"),
  options("OPTIONS"),
  delete("DELETE"),
  connect("CONNECT"),
  trace("TRACE"),
  patch("PATCH"),
  head("HEAD"),
  unknown("UNKNOWN");

  final String name;
  const Method(this.name);
}

enum Status {
  continue_(
    code: 100,
    name: "Continue",
    color: Colors.green,
  ),
  switchingProtocols(
    code: 101,
    name: "Switching Protocols",
    color: Colors.green,
  ),
  ok(
    code: 200,
    name: "OK",
    color: Colors.green,
  ),
  created(
    code: 201,
    name: "Created",
    color: Colors.green,
  ),
  accepted(
    code: 202,
    name: "Accepted",
    color: Colors.green,
  ),
  nonAuthoritativeInformation(
    code: 203,
    name: "Non-Authoritative Information",
    color: Colors.green,
  ),
  noContent(
    code: 204,
    name: "No Content",
    color: Colors.green,
  ),
  resetContent(
    code: 205,
    name: "Reset Content",
    color: Colors.green,
  ),
  partialContent(
    code: 206,
    name: "Partial Content",
    color: Colors.green,
  ),
  multiStatus(
    code: 207,
    name: "Multi-Status",
    color: Colors.green,
  ),
  alreadyReported(
    code: 208,
    name: "Already Reported",
    color: Colors.green,
  ),
  imUsed(
    code: 226,
    name: "IM Used",
    color: Colors.green,
  ),
  multipleChoices(
    code: 300,
    name: "Multiple Choices",
    color: Colors.yellow,
  ),
  movedPermanently(
    code: 301,
    name: "Moved Permanently",
    color: Colors.yellow,
  ),
  found(
    code: 302,
    name: "Found",
    color: Colors.yellow,
  ),
  seeOther(
    code: 303,
    name: "See Other",
    color: Colors.yellow,
  ),
  notModified(
    code: 304,
    name: "Not Modified",
    color: Colors.yellow,
  ),
  useProxy(
    code: 305,
    name: "Use Proxy",
    color: Colors.yellow,
  ),
  temporaryRedirect(
    code: 307,
    name: "Temporary Redirect",
    color: Colors.yellow,
  ),
  permanentRedirect(
    code: 308,
    name: "Permanent Redirect",
    color: Colors.yellow,
  ),
  badRequest(
    code: 400,
    name: "Bad Request",
    color: Colors.orange,
  ),
  unauthorized(
    code: 401,
    name: "Unauthorized",
    color: Colors.orange,
  ),
  paymentRequired(
    code: 402,
    name: "Payment Required",
    color: Colors.orange,
  ),
  forbidden(
    code: 403,
    name: "Forbidden",
    color: Colors.orange,
  ),
  notFound(
    code: 404,
    name: "Not Found",
    color: Colors.orange,
  ),
  methodNotAllowed(
    code: 405,
    name: "Method Not Allowed",
    color: Colors.orange,
  ),
  notAcceptable(
    code: 406,
    name: "Not Acceptable",
    color: Colors.orange,
  ),
  proxyAuthenticationRequired(
    code: 407,
    name: "Proxy Authentication Required",
    color: Colors.orange,
  ),
  requestTimeout(
    code: 408,
    name: "Request Timeout",
    color: Colors.orange,
  ),
  conflict(
    code: 409,
    name: "Conflict",
    color: Colors.orange,
  ),
  gone(
    code: 410,
    name: "Gone",
    color: Colors.orange,
  ),
  lengthRequired(
    code: 411,
    name: "Length Required",
    color: Colors.orange,
  ),
  preconditionFailed(
    code: 412,
    name: "Precondition Failed",
    color: Colors.orange,
  ),
  payloadTooLarge(
    code: 413,
    name: "Payload Too Large",
    color: Colors.orange,
  ),
  uriTooLong(
    code: 414,
    name: "URI Too Long",
    color: Colors.orange,
  ),
  unsupportedMediaType(
    code: 415,
    name: "Unsupported Media Type",
    color: Colors.orange,
  ),
  rangeNotSatisfiable(
    code: 416,
    name: "Range Not Satisfiable",
    color: Colors.orange,
  ),
  expectationFailed(
    code: 417,
    name: "Expectation Failed",
    color: Colors.orange,
  ),
  imATeapot(
    code: 418,
    name: "I'm a teapot",
    color: Colors.orange,
  ),
  misdirectedRequest(
    code: 421,
    name: "Misdirected Request",
    color: Colors.orange,
  ),
  unprocessableEntity(
    code: 422,
    name: "Unprocessable Entity",
    color: Colors.orange,
  ),
  locked(
    code: 423,
    name: "Locked",
    color: Colors.orange,
  ),
  failedDependency(
    code: 424,
    name: "Failed Dependency",
    color: Colors.orange,
  ),
  tooEarly(
    code: 425,
    name: "Too Early",
    color: Colors.orange,
  ),
  upgradeRequired(
    code: 426,
    name: "Upgrade Required",
    color: Colors.orange,
  ),
  preconditionRequired(
    code: 428,
    name: "Precondition Required",
    color: Colors.orange,
  ),
  tooManyRequests(
    code: 429,
    name: "Too Many Requests",
    color: Colors.orange,
  ),
  requestHeaderFieldsTooLarge(
    code: 431,
    name: "Request Header Fields Too Large",
    color: Colors.orange,
  ),
  unavailableForLegalReasons(
    code: 451,
    name: "Unavailable For Legal Reasons",
    color: Colors.orange,
  ),
  internalServerError(
    code: 500,
    name: "Internal Server Error",
    color: Colors.red,
  ),
  notImplemented(
    code: 501,
    name: "Not Implemented",
    color: Colors.red,
  ),
  badGateway(
    code: 502,
    name: "Bad Gateway",
    color: Colors.red,
  ),
  serviceUnavailable(
    code: 503,
    name: "Service Unavailable",
    color: Colors.red,
  ),
  gatewayTimeout(
    code: 504,
    name: "Gateway Timeout",
    color: Colors.red,
  ),
  httpVersionNotSupported(
    code: 505,
    name: "HTTP Version Not Supported",
    color: Colors.red,
  ),
  variantAlsoNegotiates(
    code: 506,
    name: "Variant Also Negotiates",
    color: Colors.red,
  ),
  insufficientStorage(
    code: 507,
    name: "Insufficient Storage",
    color: Colors.red,
  ),
  loopDetected(
    code: 508,
    name: "Loop Detected",
    color: Colors.red,
  ),
  notExtended(
    code: 510,
    name: "Not Extended",
    color: Colors.red,
  ),
  networkAuthenticationRequired(
    code: 511,
    name: "Network Authentication Required",
    color: Colors.red,
  );

  final int code;
  final String name;
  final Color color;
  const Status({required this.code, required this.name, required this.color});

  static Status fromJson(int code) =>
      values.firstWhere((element) => element.code == code);

  int toJson() => code;

  @override
  toString() {
    return '$code: $name';
  }
}

enum ResponseType {
  json(name: 'json'),
  text(name: 'text');

  final String name;

  const ResponseType({required this.name});
}

class Response {
  final String id;
  final String name;
  final Status status;
  final String response;
  final ResponseType responseType;
  final List<Header> headers;

  bool active;

  Response({
    required this.id,
    required this.name,
    required this.status,
    required this.response,
    required this.responseType,
    required this.headers,
    this.active = false,
  });

  Response.fromJson(Map json)
      : id = json['id'],
        name = json['name'],
        status = Status.fromJson(json['status']),
        response = json['response'],
        responseType = ResponseType.values.byName(json['responseType']),
        headers = ((json['headers'] ?? []) as List)
            .map((header) => Header.fromJson(header))
            .toList(),
        active = json['active'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status,
        'response': response,
        'responseType': responseType.name,
        'active': active,
        'headers': headers,
      };
}

class ServerRoute {
  final String id;
  final Method method;
  final String path;
  String? activeResponse;
  final List<Response> responses;
  int hitCount;
  final List<Header> headers;

  ServerRoute({
    String? routeId,
    required this.path,
    required this.responses,
    this.activeResponse,
    required this.method,
    this.hitCount = 0,
    required this.headers,
  }) : id = routeId ?? const Uuid().v4();

  ServerRoute.fromJson(Map json)
      : id = json['id'],
        path = json['path'],
        activeResponse = json['activeResponse'],
        method = Method.values.byName(json['method'].toString().toLowerCase()),
        hitCount = 0,
        responses = (json['responses'] as List)
            .map((route) => Response.fromJson(route))
            .toList(),
        headers = ((json['headers'] ?? []) as List)
            .map((header) => Header.fromJson(header))
            .toList();

  Map<String, dynamic> toJson() => {
        'id': id,
        'path': path,
        'responses': responses,
        'activeResponse': activeResponse,
        'method': method.name,
        'headers': headers,
      };
}
