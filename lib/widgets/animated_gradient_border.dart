import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimatedGradientBorder extends StatefulWidget {
  final RxBool animate;
  final Widget child;

  const AnimatedGradientBorder({
    super.key,
    required this.animate,
    required this.child,
  });

  @override
  State<AnimatedGradientBorder> createState() =>
      _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Worker _worker;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    if (widget.animate.value) {
      _controller.repeat();
    }

    _worker = ever<bool>(widget.animate, (value) {
      if (value) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    });
  }

  @override
  void dispose() {
    _worker.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Colors.blue,
                Colors.white,
                Colors.blue,
              ],
              stops: [
                _controller.value,
                (_controller.value + 0.3) % 1,
                (_controller.value + 0.6) % 1,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
