import 'dart:math';

import 'package:flutter/material.dart';

class GradientHelper {
  GradientHelper({
    required this.screenSize,
    required this.key,
  }) {
    fractionalLocation = _findPosition();
  }

  final Size screenSize;
  final GlobalKey key;
  Offset? fractionalLocation;

  Offset? _findPosition() {
    var box = key.currentContext?.findRenderObject() as RenderBox?;
    return box?.localToGlobal(Offset.zero);
  }

  Offset getFractionLocation() {
    return Offset(screenSize.width, screenSize.height);
  }

  LocationOnScreen _findLocationOnScreen() {
    if (fractionalLocation == null) {
      return LocationOnScreen.unknown;
    } else {
      if (fractionalLocation!.dx == screenSize.width / 2 &&
          fractionalLocation!.dy == screenSize.height / 2) {
        return LocationOnScreen.center;
      } else if (fractionalLocation!.dx == screenSize.width / 2 &&
          fractionalLocation!.dy < screenSize.height) {
        return LocationOnScreen.topCenter;
      } else if (fractionalLocation!.dx == screenSize.width / 2 &&
          fractionalLocation!.dy > screenSize.height) {
        return LocationOnScreen.bottomCenter;
      } else if (fractionalLocation!.dx < screenSize.width / 2 &&
          fractionalLocation!.dy < screenSize.height / 4) {
        return LocationOnScreen.topLeft;
      } else if (fractionalLocation!.dx < screenSize.width / 2 &&
          fractionalLocation!.dy > (screenSize.height / 4) * 3) {
        return LocationOnScreen.topRight;
      } else if (fractionalLocation!.dx < screenSize.width / 2 &&
          fractionalLocation!.dy < (screenSize.height / 4) * 3 &&
          fractionalLocation!.dy > screenSize.height / 4) {
        return LocationOnScreen.topMiddle;
      } else if (fractionalLocation!.dx > screenSize.width / 2 &&
          fractionalLocation!.dy < screenSize.height / 4) {
        return LocationOnScreen.bottomLeft;
      } else if (fractionalLocation!.dx > screenSize.width / 2 &&
          fractionalLocation!.dy > (screenSize.height / 4) * 3) {
        return LocationOnScreen.bottomRight;
      } else if (fractionalLocation!.dx > screenSize.width / 2 &&
          fractionalLocation!.dy < (screenSize.height / 4) * 3 &&
          fractionalLocation!.dy > screenSize.height / 4) {
        return LocationOnScreen.bottomMiddle;
      }
      return LocationOnScreen.unknown;
    }
  }

  LinearGradient? getGradient({
    required List<Color> colors,
    Alignment begin = Alignment.topCenter,
    Alignment end = Alignment.bottomCenter,
  }) {
    final location = _findLocationOnScreen();
    if (location == LocationOnScreen.unknown) return null;
    var lg = LinearGradient(
      colors: colors,
      begin: begin,
      end: end,
      stops: getStops(colors.length, location),
      transform: getGradientRotation(location),
    );

    return lg;
  }

  List<double> getStops(int length, LocationOnScreen locationOnScreen) {
    if (length == 2) {
      return [0, 1];
    } else if (length > 9) {
      return [];
    }
    switch (locationOnScreen) {
      case LocationOnScreen.topLeft:
      case LocationOnScreen.topRight:
      case LocationOnScreen.bottomLeft:
      case LocationOnScreen.bottomRight:
      case LocationOnScreen.topCenter:
      case LocationOnScreen.bottomCenter:
      case LocationOnScreen.center:
      case LocationOnScreen.topMiddle:
      case LocationOnScreen.bottomMiddle:
      case LocationOnScreen.aroundTopLeft:
      case LocationOnScreen.aroundTopRight:
      case LocationOnScreen.aroundBottomLeft:
      case LocationOnScreen.aroundBottomRight:
        return [
          fractionalLocation!.dy / 4,
          fractionalLocation!.dy,
          ...List.generate(length - 3, (index) => fractionalLocation!.dy + .15),
          1
        ];
      case LocationOnScreen.unknown:
        return [];
    }
  }

  GradientRotation getGradientRotation(LocationOnScreen locationOnScreen) {
    switch (locationOnScreen) {
      case LocationOnScreen.topLeft:
        return const GradientRotation(2.4);
      case LocationOnScreen.topRight:
        return const GradientRotation(3.9);
      case LocationOnScreen.bottomLeft:
        return const GradientRotation(.9);
      case LocationOnScreen.bottomRight:
        return const GradientRotation(1.7 * pi);
      case LocationOnScreen.topCenter:
        // TODO: Handle this case.
        break;
      case LocationOnScreen.bottomCenter:
        // TODO: Handle this case.
        break;
      case LocationOnScreen.center:
        // TODO: Handle this case.
        break;
      case LocationOnScreen.topMiddle:
        // TODO: Handle this case.
        break;
      case LocationOnScreen.bottomMiddle:
        // TODO: Handle this case.
        break;
      case LocationOnScreen.aroundTopLeft:
        // TODO: Handle this case.
        break;
      case LocationOnScreen.aroundTopRight:
        // TODO: Handle this case.
        break;
      case LocationOnScreen.aroundBottomLeft:
        // TODO: Handle this case.
        break;
      case LocationOnScreen.aroundBottomRight:
        // TODO: Handle this case.
        break;
      case LocationOnScreen.unknown:
        return const GradientRotation(0);
    }
    return const GradientRotation(0);
  }
}

enum LocationOnScreen {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  topCenter,
  bottomCenter,
  center,
  topMiddle,
  bottomMiddle,
  aroundTopLeft,
  aroundTopRight,
  aroundBottomLeft,
  aroundBottomRight,
  unknown
}

class CoachMarkClipper extends CustomClipper<Path> {
  final Rect rect;

  CoachMarkClipper(this.rect);

  @override
  Path getClip(Size size) {
    return Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()..addOval(rect),
    );
  }

  @override
  bool shouldReclip(CoachMarkClipper oldClipper) => rect != oldClipper.rect;
}

class CoachMarkPainter extends CustomPainter {
  CoachMarkPainter({
    required this.rect,
    required this.shadow,
    required this.clipper,
  });

  final Rect rect;
  final BoxShadow shadow;
  final CoachMarkClipper clipper;

  @override
  void paint(Canvas canvas, Size size) {
    final circle = rect.inflate(shadow.spreadRadius);
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawColor(shadow.color, BlendMode.dstATop);
    canvas.drawCircle(circle.center, circle.longestSide * 0.5,
        shadow.toPaint()..blendMode = BlendMode.clear);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CoachMarkPainter oldDelegate) => oldDelegate.rect != rect;

  @override
  bool shouldRebuildSemantics(CoachMarkPainter oldDelegate) => false;
}
