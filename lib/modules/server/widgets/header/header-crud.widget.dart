import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockerize/core/models/controller.dart';
import 'package:mockerize/modules/server/models/header.dart';
import 'package:mockerize/theme/breakpoint.widget.dart';
import 'package:mockerize/theme/mockerize-input.widget.dart';
import 'package:mockerize/theme/typeahead.widget.dart';

class HeaderCrud extends ConsumerStatefulWidget {
  final String? id;
  final VoidCallback closeAction;
  final Function(String key, String value, bool active, {String? id}) saveFunc;
  final List<Header> headers;

  const HeaderCrud(
    this.id, {
    super.key,
    required this.closeAction,
    required this.saveFunc,
    required this.headers,
  });

  @override
  createState() => _HeaderCrudState();
}

class _HeaderCrudState extends ConsumerState<HeaderCrud> {
  final GlobalKey<FormFieldState> _keyForm = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _valueForm = GlobalKey<FormFieldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool active = false;

  final List<String> options = [
    'Authorization',
    'Cache-Control',
    'Content-ID',
    'Content-Length',
    'Content-Range',
    'Content-Type',
    'Content-Transfer-Encoding',
    'Date',
    'ETag',
    'Expires',
    'Host',
    'If-Match',
    'If-None-Match',
    'Location',
    'Range',
  ];

  String? keyValidation(String? value) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return "A header key is required";
    }

    if (widget.headers.firstWhereOrNull(
          (header) =>
              header.key == value &&
              header.active &&
              header.id != widget.id &&
              active,
        ) !=
        null) {
      return "This header is already used";
    }

    return null;
  }

  late final MockerizeTextController key;
  final MockerizeTextController value = MockerizeTextController(
    value: null,
    controller: TextEditingController(),
    error: null,
    required: true,
    validation: (value) {
      if (value == null || value.isEmpty || value.trim().isEmpty) {
        return "A header value is required";
      }

      return null;
    },
  );

  @override
  void initState() {
    // To have access to widget.headers we need to do the declaration of
    // the key controller in here
    Header? header =
        widget.headers.firstWhereOrNull((item) => item.id == widget.id);
    if (header != null) {
      value.controller.value = TextEditingValue(text: header.value);
      active = header.active;
    }
    key = MockerizeTextController(
      controller: TextEditingController(text: header?.key),
      error: null,
      required: true,
      validation: keyValidation,
    );

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
                  widget.id != null ? 'Edit Header' : 'New Header',
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
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 24,
                left: 16,
                right: 16,
              ),
              child: Flex(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                direction: size.contains(BreakPoint.md)
                    ? Axis.horizontal
                    : Axis.vertical,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Switch(
                            value: active,
                            onChanged: (bool value) {
                              setState(() {
                                active = value;
                              });
                            },
                          ),
                        ),
                        Flexible(
                          child: Typeahead(
                            fieldKey: _keyForm,
                            controller: key,
                            label: 'Key',
                            options: options,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                      ),
                      child: MockerizeTextFormField(
                        fieldKey: _valueForm,
                        controller: value,
                        label: "value",
                      ),
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

                    widget.saveFunc(
                      key.controller.text,
                      value.controller.text,
                      active,
                      id: widget.id,
                    );

                    widget.closeAction();
                  },
                  child: const Text('Save Header'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
