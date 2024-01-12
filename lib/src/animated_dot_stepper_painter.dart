import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AnimatedDotStepperPainter extends CustomPainter {
  AnimatedDotStepperPainter({
    super.repaint,
    required int steps,
    required int currentStep,
    required int oldStep,
    required Color activeColor,
    required Color inactiveColor,
    required double animationValue,
  })  : _animationValue = animationValue,
        _inactiveColor = inactiveColor,
        _activeColor = activeColor,
        _oldStep = oldStep,
        _currentStep = currentStep,
        _steps = steps;

  final int _steps;
  final int _currentStep;
  final int _oldStep;
  final Color _activeColor;
  final Color _inactiveColor;
  final double _animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = size.height / 12;
    final Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final double dotRadius = size.height / 2;
    final double availableSpaceBetweenAllDots = size.width - size.height * _steps;
    final double availableSpaceBetweenTwoDots = availableSpaceBetweenAllDots / (_steps - 1);
    final double dashLength = availableSpaceBetweenTwoDots / 5;

    final int dashesNumber = _steps - 1;
    for (int i = 0; i < dashesNumber; i++) {
      final double widthTakenByPreviousDots = dotRadius * 2 * (i + 1);
      final double widthTakenByPreviousDashes = dashLength * 5 * i;
      final bool shouldHaveAnimation =
          (_currentStep == i && _oldStep == (i + 1)) || (_currentStep == (i + 1) && _oldStep == i);
      final bool shouldHaveActiveColor = (_currentStep == (i + 1) && _oldStep != i) || _currentStep > (i + 1);

      _drawAnimatedDashes(
        startPositionX: widthTakenByPreviousDots + widthTakenByPreviousDashes,
        positionY: size.height / 2,
        dashLength: dashLength,
        initialColor: shouldHaveActiveColor //
            ? _activeColor
            : _inactiveColor,
        canvas: canvas,
        paint: paint,
        withAnimation: shouldHaveAnimation,
      );
    }
    // First dot never has an animation and always active.
    _drawDot(
      center: Offset(dotRadius, dotRadius),
      dotRadius: dotRadius,
      initialColor: _activeColor,
      canvas: canvas,
      paint: paint,
      withAnimation: false,
    );
    for (int i = 1; i < _steps; i++) {
      final double widthTakenByPreviousDots = dotRadius * (i * 2 + 1);
      final double widthTakenByPreviousDashes = dashLength * 5 * i;
      final double centerPositionX = widthTakenByPreviousDots + widthTakenByPreviousDashes;
      final bool shouldHaveAnimation =
          (_currentStep == i && _oldStep == (i - 1)) || (_currentStep == (i - 1) && _oldStep == i);
      final bool shouldHaveActiveColor = (_currentStep == i && _oldStep != (i - 1)) || _currentStep > i;

      _drawDot(
        center: Offset(centerPositionX, dotRadius),
        dotRadius: dotRadius,
        initialColor: shouldHaveActiveColor //
            ? _activeColor
            : _inactiveColor,
        canvas: canvas,
        paint: paint,
        withAnimation: shouldHaveAnimation,
      );
    }
  }

  void _drawAnimatedDashes({
    required double startPositionX,
    required double positionY,
    required double dashLength,
    required Color initialColor,
    required Canvas canvas,
    required Paint paint,
    required bool withAnimation,
  }) {
    // Const for now. Might become changeable in further versions
    const int dashNumber = 3;

    final List<Color> dashColorsList = List<Color>.filled(
      dashNumber,
      initialColor,
      growable: false,
    );

    if (withAnimation) {
      const double animationValuePerDash = 1 / (dashNumber + 1);
      final List<double> animationValues = List<double>.generate(
        dashNumber,
        (index) => index * animationValuePerDash,
        growable: false,
      );
      for (int i = 0; i < dashNumber; i++) {
        if (_animationValue > animationValues[i]) {
          dashColorsList[i] = _activeColor;
        }
      }
    }

    _drawDashes(
      dashNumber: dashNumber,
      startPositionX: startPositionX,
      positionY: positionY,
      dashLength: dashLength,
      dashColorsList: dashColorsList,
      canvas: canvas,
      paint: paint,
    );
  }

  void _drawDashes({
    required int dashNumber,
    required double startPositionX,
    required double positionY,
    required double dashLength,
    required List<Color> dashColorsList,
    required Canvas canvas,
    required Paint paint,
  }) {
    for (int i = 0; i < dashNumber; i++) {
      canvas.drawLine(
        Offset(startPositionX + dashLength * i * 2, positionY),
        Offset(startPositionX + dashLength * (i * 2 + 1), positionY),
        paint..color = dashColorsList[i],
      );
    }
  }

  void _drawDot({
    required Offset center,
    required double dotRadius,
    required Color initialColor,
    required Canvas canvas,
    required Paint paint,
    required bool withAnimation,
  }) {
    Color dotColor = initialColor;
    if (withAnimation) {
      if (_animationValue > 0.75) {
        dotColor = _activeColor;
      }
    }
    canvas.drawCircle(
      center,
      dotRadius,
      paint..color = dotColor,
    );
  }

  @override
  bool shouldRepaint(AnimatedDotStepperPainter oldDelegate) =>
      _currentStep != oldDelegate._currentStep ||
      _oldStep != oldDelegate._oldStep ||
      _activeColor != oldDelegate._activeColor ||
      _inactiveColor != oldDelegate._inactiveColor ||
      _animationValue != oldDelegate._animationValue;
}
