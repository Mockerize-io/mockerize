import 'package:mockerize/modules/server/models/endpoint.dart';
import 'package:mockerize/modules/server/models/header.dart';
import 'package:mockerize/modules/server/models/log.dart';
import 'package:uuid/uuid.dart';

Header createHeader(
    {String? id, String? key, String? value, bool active = true}) {
  return Header(
    key: key ?? 'Test Key',
    value: 'Test Value',
    active: active,
    id: id ?? const Uuid().v4(),
  );
}

Response createResponse({
  String? id,
  String? name,
  String? response,
  Status status = Status.ok,
  ResponseType responseType = ResponseType.text,
  List<Header> headers = const [],
}) {
  return Response(
    id: id ?? const Uuid().v4(),
    name: name ?? 'Test Response',
    status: status,
    response: response ?? 'test response',
    responseType: responseType,
    headers: headers,
    active: false,
  );
}

ServerRoute createRoute({
  String? id,
  String? path,
  String? activeResponse,
  List<Response>? responses,
  List<Header>? headers,
  Method method = Method.get,
}) {
  final response = (responses == null || responses.isEmpty)
      ? createResponse()
      : responses[0];

  return ServerRoute(
    routeId: id ?? const Uuid().v4(),
    path: path ?? '/testing-path',
    activeResponse: response.id,
    responses: responses ?? [response],
    method: method,
    headers: headers ?? [createHeader()],
  );
}

Request createRequest({
  String? ip,
  Method? method,
  Map<String, dynamic>? headers,
  String? userAgent,
  dynamic body,
  String? path,
  int? size,
}) {
  return Request(
    ip: ip ?? '127.0.0.1',
    method: method ?? Method.get,
    headers: headers ?? {},
    userAgent: userAgent ?? 'Test User Agent',
    body: body ?? 'Test Body',
    path: path ?? '/test-path',
    size: size ?? 0,
  );
}

ResponseLog createLog({
  String? routeId,
  String? responseId,
  Duration? responseTime,
  int? status,
  Request? request,
  DateTime? date,
}) {
  return ResponseLog(
    date: date ?? DateTime.now(),
    status: status ?? 200,
    responseTime: responseTime ?? Duration.zero,
    request: request ?? createRequest(),
    routeId: routeId,
    responseId: responseId,
  );
}
