import 'package:mockerize/modules/server/models/endpoint.dart';

class Request {
  final String ip;
  final Method method;
  final Map<String, dynamic> headers;
  final String userAgent;
  final dynamic body;
  final String path;
  final int size;

  Request({
    required this.ip,
    required this.method,
    required this.headers,
    required this.userAgent,
    required this.body,
    required this.path,
    required this.size,
  });

  Map<String, dynamic> toJson() => {
        'ip': ip,
        'method': method.name,
        'headers': headers,
        'user_agent': userAgent,
        'body': body.toString(),
        'path': path,
        'size': size,
      };

  Request.fromJson(Map json)
      : ip = json['ip'],
        method = Method.values.byName(json['method'].toString().toLowerCase()),
        headers = json['headers'],
        userAgent = json['user_agent'],
        body = json['body'],
        path = json['path'],
        size = json['size'];
}

class ResponseLog {
  final DateTime date;
  final Duration responseTime;
  final int status;
  final Request request;

  // Optional because we log actual 404s as well.
  final String? routeId;
  final String? responseId;

  ResponseLog({
    required this.date,
    required this.status,
    required this.responseTime,
    required this.request,
    this.routeId,
    this.responseId,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'status': status,
        'response_time': responseTime.inMicroseconds,
        'request': request.toJson(),
        'route_id': routeId,
        'response_id': responseId,
      };

  ResponseLog.fromJson(Map json)
      : date = DateTime.parse(json['date']),
        status = json['status'],
        responseTime = Duration(microseconds: json['response_time']),
        request = Request.fromJson(json['request']),
        routeId = json['route_id'],
        responseId = json['response_id'];
}

class LogStorage {
  final List<ResponseLog> logs;
  final String serverId;

  LogStorage({required this.logs, required this.serverId});

  LogStorage.fromJson(Map json)
      : logs = ((json['logs'] ?? []) as List)
            .map((header) => ResponseLog.fromJson(header))
            .toList(),
        serverId = json['server_id'];

  Map<String, dynamic> toJson() => {
        'logs': logs,
        'server_id': serverId,
      };
}
