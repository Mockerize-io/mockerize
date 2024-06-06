import 'package:flutter/material.dart';

class MockerizeToggleButton extends StatefulWidget {
  const MockerizeToggleButton({
    super.key,
    required this.selected,
    required this.onPressed,
    required this.child,
    this.icon,
    this.iconOnly = false,
    this.shape,
    this.fixedSize,
  });

  const MockerizeToggleButton.icon({
    super.key,
    required this.selected,
    required this.onPressed,
    this.child,
    required this.icon,
    this.iconOnly = true,
    this.shape,
    this.fixedSize,
  });

  final bool selected;
  final VoidCallback? onPressed;
  final Widget? child;
  final Icon? icon;
  final bool? iconOnly;
  final WidgetStateProperty<OutlinedBorder?>? shape;
  final WidgetStateProperty<Size?>? fixedSize;

  @override
  State<MockerizeToggleButton> createState() => _MockerizeToggleButtonState();
}

class _MockerizeToggleButtonState extends State<MockerizeToggleButton> {
  late final WidgetStatesController statesController;

  @override
  void initState() {
    super.initState();
    statesController = WidgetStatesController(
        <WidgetState>{if (widget.selected) WidgetState.selected});
  }

  @override
  void didUpdateWidget(MockerizeToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      statesController.update(WidgetState.selected, widget.selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle localIconButtonStyle = ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (widget.selected) {
            return Theme.of(context).colorScheme.onPrimary;
          }
          return null; // defer to the defaults
        },
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (widget.selected) {
            return Theme.of(context).colorScheme.primary;
          }
          return null; // defer to the defaults
        },
      ),
    );

    ButtonStyle localButtonStyle = ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return Theme.of(context).colorScheme.onPrimary;
          }
          return Theme.of(context)
              .colorScheme
              .onSurface; // defer to the defaults
        },
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return Theme.of(context).colorScheme.primary;
          }
          return null; // defer to the defaults
        },
      ),
    );

    return widget.iconOnly == true
        ? IconButton(
            style: localIconButtonStyle.copyWith(
                fixedSize: widget.fixedSize, shape: widget.shape),
            onPressed: widget.onPressed,
            icon: widget.icon ?? const Icon(Icons.abc),
          )
        : widget.icon != null
            ? TextButton.icon(
                statesController: statesController,
                style: localButtonStyle.copyWith(
                    fixedSize: widget.fixedSize, shape: widget.shape),
                onPressed: widget.onPressed,
                icon: widget.icon,
                label: widget.child ?? const SizedBox(),
              )
            : TextButton(
                statesController: statesController,
                style: localButtonStyle.copyWith(
                    fixedSize: widget.fixedSize, shape: widget.shape),
                onPressed: widget.onPressed,
                child: widget.child ?? const SizedBox(),
              );
  }
}
