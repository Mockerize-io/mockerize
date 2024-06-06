import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockerize/core/models/controller.dart';
import 'package:mockerize/modules/server/models/header.dart';
import 'package:uuid/uuid.dart';

import 'package:mockerize/modules/server/models/endpoint.dart';

@immutable
class RouteForm {
  final MockerizeTextController path;
  final List<Response> responses;
  final Method method;
  final String? activeResponse;
  final List<Header> headers;

  const RouteForm({
    required this.path,
    required this.responses,
    required this.method,
    required this.activeResponse,
    required this.headers,
  });
}

class RouteFormProvider extends StateNotifier<RouteForm> {
  RouteFormProvider(ServerRoute? route)
      : super(RouteForm(
          path: MockerizeTextController(
            controller: TextEditingController(text: route?.path ?? ''),
            value: route?.path,
            error: null,
            required: true,
            validation: (value) {
              if (value == null || value.isEmpty || value.trim().isEmpty) {
                return "path is required";
              }
              return null;
            },
          ),
          // path: TextEditingController(text: route?.path ?? ''),
          // ignore: prefer_const_literals_to_create_immutables
          responses: route?.responses ?? [],
          method: route?.method ?? Method.get,
          activeResponse: route?.activeResponse,
          headers: route?.headers.toList() ?? [],
        ));

  void setState({
    MockerizeTextController? path,
    List<Response>? responses,
    Method? method,
    String? activeResponse,
    List<Header>? headers,
  }) {
    state = RouteForm(
      path: path ?? state.path,
      responses: responses ?? state.responses,
      method: method ?? state.method,
      activeResponse: activeResponse == "null"
          ? null
          : activeResponse ?? state.activeResponse,
      headers: headers ?? state.headers,
    );
  }

  void setMethod(Method method) {
    setState(method: method);
  }

  void upsertResponse({
    String? id,
    required String name,
    required Status status,
    required String response,
    required ResponseType responseType,
    required List<Header> headers,
    bool? active,
  }) {
    /// Cleaner way to update existing response rather than delete and re-add

    List<Response> tmpResponses = [...state.responses];

    // Search for the response's ID to see if it exists
    final responseIndex = state.responses.indexWhere((r) => r.id == id);

    final responseID = id ?? const Uuid().v4();

    final tmpResponse = Response(
      id: responseID,
      name: name,
      status: status,
      response: response,
      responseType: responseType,
      headers: headers,
    );

    String? activeResponse;

    if (responseIndex == -1) {
      // Adding
      tmpResponse.active = tmpResponses.isEmpty;
      tmpResponses.add(tmpResponse);
    } else {
      // Updating
      tmpResponse.active =
          tmpResponses.length == 1 ? true : tmpResponses[responseIndex].active;
      tmpResponses[responseIndex] = tmpResponse;
    }

    if (tmpResponse.active) {
      activeResponse = responseID;
    }

    setState(responses: tmpResponses, activeResponse: activeResponse);
  }

  void removeResponse(String id) {
    final responses = state.responses;
    var activeResponse = state.activeResponse;

    responses.removeWhere((resp) => resp.id == id);

    if (id == state.activeResponse && responses.isNotEmpty) {
      activeResponse = responses.first.id;
      responses[0].active = true;
    } else {
      activeResponse = "null";
    }

    setState(
      responses: responses,
      activeResponse: activeResponse,
    );
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

final routeFormProvider =
    StateNotifierProvider.autoDispose<RouteFormProvider, RouteForm>(
  (ref) => RouteFormProvider(null),
);
