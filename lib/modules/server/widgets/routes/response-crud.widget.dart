import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockerize/core/models/controller.dart';
import 'package:mockerize/modules/server/models/endpoint.dart';
import 'package:mockerize/modules/server/models/header.dart';
import 'package:mockerize/modules/server/providers/route-form.provider.dart';
import 'package:collection/collection.dart';
import 'package:mockerize/modules/server/utils/show-modal.dart';
import 'package:mockerize/modules/server/widgets/header/header-list.widget.dart';
import 'package:mockerize/modules/server/widgets/routes/status-selector.widget.dart';
import 'package:mockerize/theme/breakpoint.widget.dart';
import 'package:mockerize/theme/mockerize-input.widget.dart';
import 'package:uuid/uuid.dart';

class ResponseCrud extends ConsumerStatefulWidget {
  final String? id;
  final VoidCallback closeAction;
  final WidgetRef? widgetRef;
  const ResponseCrud(this.id,
      {super.key, required this.closeAction, this.widgetRef});

  @override
  createState() => _ResponseCrudState();
}

class _ResponseCrudState extends ConsumerState<ResponseCrud> {
  final _formKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<FormFieldState>();
  final _responseKey = GlobalKey<FormFieldState>();

  bool inlineAddHeader = false;

  void toggleInlineAddHeader() {
    setState(() {
      inlineAddHeader = false;
    });
  }

  final MockerizeTextController name = MockerizeTextController(
    value: null,
    controller: TextEditingController(),
    error: null,
    required: true,
    validation: (value) {
      if (value == null || value.isEmpty || value.trim().isEmpty) {
        return "A name is required";
      }
      return null;
    },
  );

  // This needs to be marked as late so that we can access the response type
  late MockerizeTextController response = MockerizeTextController(
    value: null,
    controller: TextEditingController(),
    error: null,
    required: true,
    validation: (value) {
      if (value == null || value.isEmpty || value.trim().isEmpty) {
        return "A response value is required";
      }

      if (responseType == ResponseType.json) {
        try {
          jsonDecode(value);
        } on FormatException catch (_) {
          return "Invalid JSON";
        }
      }

      return null;
    },
  );

  bool active = false;
  Status status = Status.ok;
  ResponseType responseType = ResponseType.text;
  List<Header> headers = [];

  void upsertHeader(String key, String value, bool active, {String? id}) {
    final index = headers.indexWhere((header) => header.id == id);
    setState(() {
      if (index != -1) {
        headers[index] = Header(
          id: id!,
          key: key,
          value: value,
          active: active,
        );
      } else {
        headers.add(Header(
          id: const Uuid().v4(),
          key: key,
          value: value,
          active: active,
        ));
      }
    });
  }

  void deleteHeader(String id) {
    setState(() {
      headers.removeWhere((header) => header.id == id);
    });
  }

  void setStatus(Status newStatus) {
    setState(() {
      status = newStatus;
    });
  }

  @override
  void initState() {
    if (widget.id != null && widget.widgetRef != null) {
      final form =
          widget.widgetRef!.read(routeFormProvider); // this is missing data.

      var currentWidget = form.responses
          .firstWhereOrNull((response) => response.id == widget.id);
      if (currentWidget != null) {
        active = currentWidget.active;
        name.controller.text = currentWidget.name;
        status = currentWidget.status;
        responseType = currentWidget.responseType;
        response.controller.text = currentWidget.response;
        headers = currentWidget.headers;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<BreakPoint> size = mockerizeBreakSizes(context).breakPoints;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 32,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.id != null ? 'Edit Response' : 'New Response',
                  style: const TextStyle(
                    fontSize: 24,
                  ),
                ),
                IconButton(
                  onPressed: widget.closeAction,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 24,
                      left: 16,
                      right: 16,
                    ),
                    child: Column(
                      children: [
                        Flex(
                          // Use Row to place name input and status dropdown on the same line
                          // crossAxisAlignment: CrossAxisAlignment
                          //     .center, // Align the Row children vertically
                          direction: size.contains(BreakPoint.md)
                              ? Axis.horizontal
                              : Axis.vertical,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    right:
                                        size.contains(BreakPoint.md) ? 8 : 0),
                                child: MockerizeTextFormField(
                                  fieldKey: _nameKey,
                                  controller: name,
                                  label: 'Name',
                                  hint:
                                      'A descriptive name to identify your response',
                                ),
                              ),
                            ),
                            StatusSelector(
                              status: status,
                              callback: (Status newStatus) =>
                                  setStatus(newStatus),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    // height: 65,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Headers',
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            showHeaderModal(
                              context,
                              saveFunc: upsertHeader,
                              headers: headers,
                            );
                          },
                          child: const Text("Add Header"),
                        ),
                      ],
                    ),
                  ),

                  ///#region-begin Headers
                  Container(
                    padding: const EdgeInsets.only(
                      top: 24,
                      left: 16,
                      right: 16,
                    ),
                    child: HeaderList(
                      headers: headers,
                      // inlineAddHeader: inlineAddHeader,
                      // toggleInlineAddHeader: toggleInlineAddHeader,
                      deleteFunc: deleteHeader,
                      saveFunc: upsertHeader,
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Response Value',
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: DropdownButtonFormField<ResponseType>(
                            decoration: InputDecoration(
                              label: const Text('Response Type'),
                              border: const OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.7),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.2),
                                  width: 2.0,
                                ),
                              ),
                            ),
                            value: responseType,
                            hint: const Text('Response Type'),
                            onChanged: (ResponseType? newValue) {
                              setState(() {
                                responseType = newValue!;
                              });
                            },
                            items: ResponseType.values
                                .map<DropdownMenuItem<ResponseType>>(
                                    (ResponseType type) {
                              return DropdownMenuItem<ResponseType>(
                                value: type,
                                child: Text(
                                  type.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      ],
                    ),
                  ),
                  // Provide some spacing before the next Row
                  Container(
                    padding: const EdgeInsets.only(
                      top: 24,
                      left: 16,
                      right: 16,
                    ),
                    child: MockerizeTextFormField(
                      fieldKey: _responseKey,
                      controller: response,
                      label: 'Response',
                      hint: 'A response',
                      isTextArea:
                          responseType == ResponseType.json ? true : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            alignment: AlignmentDirectional.bottomCenter,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: size.contains(BreakPoint.md)
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.spaceBetween,
              crossAxisAlignment:
                  CrossAxisAlignment.end, // Center the buttons horizontally
              children: [
                // Provide some spacing between the buttons
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    // onPressed: () => Navigator.pop(context), // Close the modal
                    onPressed: widget.closeAction,
                    child: const Text('Cancel'),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll<Color>(
                      Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ),
                    overlayColor: WidgetStatePropertyAll<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                    foregroundColor: WidgetStatePropertyAll<Color>(
                      Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    widget.widgetRef
                        ?.read(routeFormProvider.notifier)
                        .upsertResponse(
                          id: widget.id,
                          name: name.controller.text,
                          status: status,
                          response: response.controller.text,
                          responseType: responseType,
                          active: active,
                          headers: headers,
                        );

                    widget.closeAction();
                  },
                  child: const Text('Save Response'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
