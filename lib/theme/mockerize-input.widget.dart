import 'package:flutter/material.dart';
import 'package:mockerize/core/models/controller.dart';
import 'package:markdown_editor/widgets/markdown_form_field.dart';

class MockerizeTextFormField extends StatelessWidget {
  final MockerizeTextController controller;
  final String label;
  final String? hint;
  final bool? isTextArea;
  final GlobalKey<FormFieldState> fieldKey;

  const MockerizeTextFormField({
    super.key,
    required this.fieldKey,
    required this.controller,
    required this.label,
    this.hint,
    this.isTextArea,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isTextArea != null ? 192 : 96,
      child: Focus(
        child: TextFormField(
          key: fieldKey,
          controller: controller.controller,
          minLines: isTextArea != null ? 5 : null,
          maxLines: null,
          textAlignVertical: TextAlignVertical.top,
          validator: controller.validation,
          onChanged: (_) => fieldKey.currentState?.validate(),
          decoration: InputDecoration(
            label: Text(label),
            hintText: hint,
            errorText: controller.error,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                width: 2.0,
              ),
            ),
          ),
        ),
        onFocusChange: (isFocused) {
          if (!isFocused && controller.validation != null) {
            fieldKey.currentState?.validate();
          }
        },
      ),
    );
  }
}

class MockerizeMarkdownFormField extends StatefulWidget {
  final MockerizeTextController controller;
  final String label;
  final String? hint;
  final GlobalKey<FormFieldState> fieldKey;

  const MockerizeMarkdownFormField({
    super.key,
    required this.fieldKey,
    required this.controller,
    required this.label,
    this.hint,
  });

  @override
  State<MockerizeMarkdownFormField> createState() =>
      _MockerizeMarkdownFormFieldState();
}

class _MockerizeMarkdownFormFieldState
    extends State<MockerizeMarkdownFormField> {
  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 48),
      // height: 192,
      child: Focus(
        child: MarkdownFormField(
          controller: widget.controller.controller,
          scrollController: scrollController,
          emojiConvert: true,
          autoCloseAfterSelectEmoji: false,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(
              top: 120,
              bottom: 16,
              left: 16,
              right: 16,
            ),
            label: const Text('Description'),
            hintText: "Type here. . .",
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                width: 2.0,
              ),
            ),
          ),
        ),
        onFocusChange: (isFocused) {
          if (!isFocused && widget.controller.validation != null) {
            widget.fieldKey.currentState?.validate();
          }
        },
      ),
    );
  }
}
