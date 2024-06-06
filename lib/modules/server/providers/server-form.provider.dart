import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockerize/core/models/controller.dart';
import 'package:mockerize/modules/server/models/header.dart';
import 'package:mockerize/modules/server/models/server.dart';
import 'package:uuid/uuid.dart';

@immutable
class ServerForm {
  final String ip;
  final MockerizeTextController name;
  final MockerizeTextController description;
  final MockerizeTextController port;
  final List<Header> headers;

  const ServerForm({
    required this.ip,
    required this.name,
    required this.description,
    required this.port,
    required this.headers,
  });
}

class ServerFormProvider extends StateNotifier<ServerForm> {
  ServerFormProvider(MockerizeServer? server)
      : super(
          ServerForm(
            ip: server?.address.toString() ?? '127.0.0.1',
            name: MockerizeTextController(
              controller: TextEditingController(text: server?.name),
              value: server?.name,
              error: null,
              required: true,
              validation: (value) {
                if (value == null || value.isEmpty || value.trim().isEmpty) {
                  return "name is required";
                }
                return null;
              },
            ),
            description: MockerizeTextController(
              controller: TextEditingController(text: server?.description),
              value: server?.description,
              error: null,
              required: false,
              validation: null,
            ),
            port: MockerizeTextController(
              controller: TextEditingController(text: server?.port.toString()),
              value: server?.port.toString(),
              error: null,
              required: true,
              validation: (value) {
                if (value == null || value.isEmpty) {
                  return "port is required";
                }

                int? port = int.tryParse(value);
                if (port == null) {
                  return "port must be an actual number";
                }

                if (port < 1 || port > 65535) {
                  return "port must be between 1-65535";
                }
                return null;
              },
            ),
            // headers: MockerizeHeadersController(
            //   value: server?.headers.toList() ?? [],
            //   errors: List.generate(server?.headers.length ?? 0, (_) => null),
            //   error: null,
            //   required: false,
            //   validator: (List<Header>? value) {
            //     if (value == null) {
            //       return null;
            //     }

            //     if (value
            //         .groupListsBy((element) => element.key)
            //         .values
            //         .where((element) => element.length > 1)
            //         .isNotEmpty) {
            //       return 'Duplicates detected';
            //     }
            //     // ;

            //     // for (Header header in value) {
            //     //   if (header.key == '' || header.value == '') {
            //     //     return "Empty key or value detected";
            //     //   }
            //     // }
            //     // TODO
            //   },
            // ),
            headers: server?.headers.toList() ?? [],
          ),
        );

  Future<void> setState({
    String? ip,
    MockerizeTextController? name,
    MockerizeTextController? description,
    MockerizeTextController? port,
    List<Header>? headers,
  }) async {
    state = ServerForm(
      ip: ip ?? state.ip,
      name: name ?? state.name,
      description: description ?? state.description,
      port: port ?? state.port,
      headers: headers ?? state.headers,
    );
  }

  Future<void> changeAddress(String address) async {
    await setState(ip: address);
  }

  Future<void> upsertHeader(String key, String value, bool active,
      {String? id}) async {
    final tmpHeaders = state.headers;

    final index = state.headers.indexWhere((header) => header.id == id);

    if (index != -1) {
      tmpHeaders[index] = Header(
        id: id!,
        key: key,
        value: value,
        active: active,
      );
    } else {
      tmpHeaders.add(Header(
        id: const Uuid().v4(),
        key: key,
        value: value,
        active: active,
      ));
    }

    setState(headers: tmpHeaders);
  }

  Future<void> deleteHeader(String id) async {
    final tmpHeaders = state.headers;

    tmpHeaders.removeWhere((header) => header.id == id);
    setState(headers: tmpHeaders);
  }
}

final serverFormProvider =
    StateNotifierProvider.autoDispose<ServerFormProvider, ServerForm>(
  (ref) => ServerFormProvider(null),
);
