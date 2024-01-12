import 'package:animated_dot_stepper/src/animated_dot_stepper_painter.dart';
import 'package:flutter/material.dart';

class AnimatedDotStepper extends StatefulWidget {
  const AnimatedDotStepper({
    super.key,
    required int steps,
    required int currentStep,
    required Color activeColor,
    required Color inactiveColor,
    double width = 142,
    double height = 24,
    int animationDuration = 200,
  })  : _animationDuration = animationDuration,
        _height = height,
        _width = width,
        _inactiveColor = inactiveColor,
        _activeColor = activeColor,
        _currentStep = currentStep,
        _steps = steps,
        assert(steps >= 2 && steps <= 5),
        assert(currentStep >= 0 && currentStep < steps),
        assert(width >= height * steps),
        assert(width >= 24 && height >= 12);

  /// Number of steps. Can be from 2 to 5.
  final int _steps;

  /// Current step of the widget.
  final int _currentStep;

  /// Color of [_currentStep] and previous steps.
  final Color _activeColor;

  /// Color, when step is less than [_currentStep].
  final Color _inactiveColor;

  /// Width of the widget.
  final double _width;

  /// Height of the widget and hence the diameter of the dot.
  final double _height;

  /// Duration of the animation in milliseconds.
  final int _animationDuration;

  @override
  State<AnimatedDotStepper> createState() => _AnimatedDotStepperState();
}

class _AnimatedDotStepperState extends State<AnimatedDotStepper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _oldStep;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget._animationDuration),
      vsync: this,
    )..addListener(() => setState(() {}));
    _oldStep = widget._currentStep;
  }

  @override
  void didUpdateWidget(covariant AnimatedDotStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget._currentStep == widget._currentStep) {
      return;
    }
    _oldStep = oldWidget._currentStep;
    if (oldWidget._currentStep < widget._currentStep) {
      _controller.forward(from: 0);
    } else {
      _controller.reverse(from: 1);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints(
          minWidth: widget._width,
          minHeight: widget._height,
        ),
        child: CustomPaint(
          painter: AnimatedDotStepperPainter(
            steps: widget._steps,
            currentStep: widget._currentStep,
            oldStep: _oldStep,
            activeColor: widget._activeColor,
            inactiveColor: widget._inactiveColor,
            animationValue: _controller.value,
          ),
        ),
      );
}
