import 'package:flutter/material.dart';

/// Interactive wrapper providing a tactile "jumping bubble" tap feedback.
///
/// On touch down, the child compresses smoothly with a subtle scale.
/// On release, it springs back with an overshooting elastic bounce curve,
/// delivering a modern, responsive feel.
class AppBouncyTap extends StatefulWidget {
  const AppBouncyTap({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleDown = 0.90,
    this.duration = const Duration(milliseconds: 140),
    this.reverseDuration = const Duration(milliseconds: 260),
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleDown;
  final Duration duration;
  final Duration reverseDuration;
  final bool enabled;

  @override
  State<AppBouncyTap> createState() => _AppBouncyTapState();
}

class _AppBouncyTapState extends State<AppBouncyTap> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.reverseDuration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (!widget.enabled) return;
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    if (!widget.enabled) return;
    _controller.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    if (!widget.enabled) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || (widget.onTap == null && widget.onLongPress == null)) {
      return widget.child;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
