import 'package:flutter/material.dart';
import 'package:mockerize/core/models/controller.dart';

enum SampleItem { itemOne, itemTwo, itemThree }

class Typeahead extends StatefulWidget {
  final GlobalKey<FormFieldState> fieldKey;
  final MockerizeTextController controller;
  final String label;
  final String? hint;
  final List<String> options;

  const Typeahead({
    super.key,
    required this.fieldKey,
    required this.controller,
    required this.label,
    this.hint,
    required this.options,
  });

  @override
  State<Typeahead> createState() => _TypeaheadState();
}

class _TypeaheadState extends State<Typeahead> {
  final GlobalKey _instanceKey = GlobalKey();
  List<String> filteredList = [];

  final menuState = MenuController();
  String? selectedMenu;

  Future<void> filterList() async {
    final List<String> tmpList = widget.options
        .where((item) =>
            item
                .toLowerCase()
                .startsWith(widget.controller.controller.text.toLowerCase()) ||
            item
                .toLowerCase()
                .contains(widget.controller.controller.text.toLowerCase()))
        .toList();
    setState(() {
      filteredList = tmpList;
    });
    menuState.open();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 96,
      key: _instanceKey,
      child: Focus(
        child: MenuAnchor(
          controller: menuState,
          // alignmentOffset: Offset.fromDirection(0, 4),
          alignmentOffset: const Offset(4, -40),
          style: MenuStyle(
            maximumSize: WidgetStateProperty.resolveWith(
              (size) => Size(
                (_instanceKey.currentContext!.findRenderObject() as RenderBox)
                    .size
                    .width,
                200,
              ),
            ),
          ),

          ///#region-begin Menu
          menuChildren: List<MenuItemButton>.generate(
            filteredList.length,
            (int index) => MenuItemButton(
              style: ButtonStyle(
                minimumSize: WidgetStateProperty.resolveWith(
                  (size) => Size(
                    (_instanceKey.currentContext!.findRenderObject()
                            as RenderBox)
                        .size
                        .width,
                    double.minPositive,
                  ),
                ),
              ),
              onPressed: () => setState(() {
                widget.controller.controller.text = filteredList[index];
                selectedMenu = filteredList[index];
              }),
              child: Padding(
                padding: const EdgeInsets.all(16),
                // width: double.maxFinite,
                child: Text(filteredList[index]),
              ),
            ),
          ),

          ///#region-end Menu
          child: TextFormField(
            key: widget.fieldKey,
            controller: widget.controller.controller,
            validator: widget.controller.validation,
            onChanged: (_) {
              filterList();
              widget.fieldKey.currentState?.validate();
            },
            decoration: InputDecoration(
              label: Text(widget.label),
              hintText: widget.hint,
              errorText: widget.controller.error,
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: colorScheme.primary.withOpacity(0.7),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                  width: 2.0,
                ),
              ),
              suffixIcon: IconButton(
                // isSelected: menuState.isOpen,
                onPressed: () {
                  if (menuState.isOpen == true) {
                    menuState.close();
                    return;
                  }
                  filterList();
                  menuState.open();
                  return;
                },
                selectedIcon: const Icon(Icons.expand_less),
                icon: const Icon(Icons.expand_more),
              ),
            ),
          ),
        ),
        onFocusChange: (isFocused) {
          if (!isFocused && widget.controller.validation != null) {
            widget.fieldKey.currentState?.validate();
          }

          if (!isFocused) {
            menuState.close();
            return;
          }

          // menuState.open();
        },
      ),
    );
  }
}
