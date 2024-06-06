import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mockerize/modules/server/components/mockerize-router.dart';
import 'package:mockerize/modules/server/models/header.dart';

@immutable
class MockerizeServer {
  final String serverID;
  final dynamic address;
  final int port;
  final String name;
  final String? description;
  final String routerId;
  final HttpServer? server;
  final List<Header> headers;
  final bool newLogs;

  const MockerizeServer({
    required this.serverID,
    required this.address,
    required this.port,
    required this.name,
    required this.routerId,
    required this.server,
    required this.headers,
    this.newLogs = false,
    this.description,
  });

  MockerizeServer.fromJson(Map<String, dynamic> json)
      : serverID = json['id'],
        address = json['address'],
        port = json['port'],
        name = json['name'],
        routerId = json['routerId'],
        headers = ((json['headers'] ?? []) as List)
            .map((header) => Header.fromJson(header))
            .toList(),
        server = null,
        description = json['description'],
        newLogs = false;

  Map<String, dynamic> toJson() => {
        'id': serverID,
        'address': address.toString(),
        'port': port,
        'name': name,
        'headers': headers,
        'routerId': routerId,
        'description': description
      };
}

class ServerStorage {
  final MockerizeRouter router;
  final MockerizeServer server;

  ServerStorage({required this.router, required this.server});

  ServerStorage.fromJson(Map json)
      : server = MockerizeServer.fromJson(json['server']),
        router = MockerizeRouter.fromJson(json['router']);

  Map<String, dynamic> toJson() => {
        'server': server,
        'router': router,
      };
}
