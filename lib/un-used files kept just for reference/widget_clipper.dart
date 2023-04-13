import 'package:flutter/material.dart';

class WidgetClipper extends CustomClipper<Path> {
  final Rect? rect;
  final double radius;

  WidgetClipper({
    required this.rect,
    required this.radius,
  });

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.fillType = PathFillType.evenOdd;
    path.addRect(Offset.zero & size);

    if (rect != null) {
      path.addRRect(RRect.fromRectAndRadius(rect!, Radius.circular(radius)));
    }
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return true;
  }
}
