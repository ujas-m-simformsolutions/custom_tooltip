import 'package:flutter/material.dart';

class OverlayPainter extends CustomPainter {
  OverlayPainter({
    required this.rect,
    required this.shadow,
    required this.radius,
  });

  final Rect rect;
  final BoxShadow shadow;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    // Draws shadow
    canvas.drawColor(shadow.color, BlendMode.dstATop);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      shadow.toPaint()..blendMode = BlendMode.clear,
    );
    canvas.restore();
  }

  // TODO: update with  old != new.
  @override
  bool shouldRepaint(OverlayPainter oldDelegate) => true;
}
