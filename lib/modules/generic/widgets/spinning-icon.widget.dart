import 'package:flutter/material.dart';

class SpinningContainer extends AnimatedWidget {
  final AnimationController controller;
  final IconData icon;
  final double size;
  final Color color;

  const SpinningContainer({
    super.key,
    required this.controller,
    required this.icon,
    required this.size,
    required this.color,
  }) : super(listenable: controller);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Curves.linear,
    );

    return RotationTransition(
      turns: animation,
      child: Icon(
        icon,
        size: size,
        color: color,
      ),
    );
  }
}

class SpinningIcon extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color color;
  const SpinningIcon({
    super.key,
    required this.icon,
    required this.size,
    required this.color,
  });

  @override
  State<SpinningIcon> createState() => _SpinningIconState();
}

/// [AnimationController]s can be created with `vsync: this` because of
/// [TickerProviderStateMixin].
class _SpinningIconState extends State<SpinningIcon>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 10),
    vsync: this,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SpinningContainer(
      controller: _controller,
      icon: widget.icon,
      size: widget.size,
      color: widget.color,
    );
  }
}
