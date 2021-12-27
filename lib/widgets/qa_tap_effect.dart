import 'package:flutter/material.dart';

enum QaTapEffectType {
  touchableOpacity,
  scaleDown,
}

class QaTapEffect extends StatefulWidget {
  const QaTapEffect({
    Key? key,
    required this.child,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.duration = const Duration(milliseconds: 100),
    this.vibrate = false,
    this.behavior,
    this.effects = const [
      QaTapEffectType.scaleDown,
    ],
  }) : super(key: key);

  final Widget child;
  final List<QaTapEffectType> effects;
  final void Function()? onTap;
  final Duration duration;
  final bool vibrate;
  final HitTestBehavior? behavior;

  final void Function()? onTapUp;
  final void Function()? onTapDown;

  @override
  State<QaTapEffect> createState() => _QaTapEffectState();
}

class _QaTapEffectState extends State<QaTapEffect> with SingleTickerProviderStateMixin {
  static double scaleActive = 0.98;
  static double opacityActive = 0.2;

  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void onTapDown() {
    controller.forward();
    if (widget.onTapDown != null) {
      widget.onTapDown!();
    }
  }

  void onTapUp() {
    controller.reverse();
    if (widget.onTap != null) {
      widget.onTap!();
    } else if (widget.onTapUp != null) {
      widget.onTapUp!();
    }
  }

  Animation<double> get animation => Tween<double>(begin: 1, end: scaleActive).animate(controller);
  Animation<double> get animation2 => Tween<double>(begin: 1, end: opacityActive).animate(controller);

  @override
  Widget build(BuildContext context) {
    if (widget.onTap != null) {
      assert(widget.onTapDown == null && widget.onTapUp == null);
    }

    if (widget.onTapDown != null || widget.onTapUp != null) {
      assert(widget.onTap == null);
      assert(widget.onTapDown != null);
      assert(widget.onTapUp != null);
    }

    if (widget.onTap != null || widget.onTapUp != null) {
      return GestureDetector(
        behavior: widget.behavior,
        onTapCancel: () => controller.reverse(),
        onTapDown: (detail) => onTapDown(),
        onTapUp: (detail) => onTapUp(),
        child: buildChild(animation, animation2),
      );
    } else {
      return buildChild(animation, animation2);
    }
  }

  Widget buildChild(
    Animation<double> animation,
    Animation<double> animation2,
  ) {
    return AnimatedBuilder(
      child: widget.child,
      animation: controller,
      builder: (context, child) {
        Widget result = child ?? const SizedBox();
        for (var effect in widget.effects) {
          switch (effect) {
            case QaTapEffectType.scaleDown:
              result = ScaleTransition(scale: animation, child: result);
              break;
            case QaTapEffectType.touchableOpacity:
              result = Opacity(opacity: animation2.value, child: result);
              break;
          }
        }
        return result;
      },
    );
  }
}
