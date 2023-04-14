import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import '../arrows.dart';
import '../enums.dart';

class ArrowPainter extends CustomPainter {
  /// Target widget's render box
  final RenderBox targetRenderBox;

  /// Tooltip's render box
  final RenderBox sourceRenderBox;

  final Animation<double> animation;

  /// Where on the source Widget the arrow should start
  final AlignmentGeometry sourceAnchor;

  /// Where on the target Widget the arrow should end
  final AlignmentGeometry targetAnchor;

  /// Whether the arrow should be pointed both ways
  final bool doubleSided;

  /// Arrow color
  final Color color;

  /// Arrow width
  final double width;

  /// Length of arrow tip
  final double tipLength;

  /// Outwards angle of arrow tip, in radians
  final double tipAngleOutwards;

  /// A value representing the natural bow of the arrow.
  /// At 0, all lines will be straight.
  final double bow;

  /// The length of the arrow where the line should be most stretched. Shorter
  /// distances than 0 will have no additional effect on the bow of the arrow.
  final double stretchMin;

  /// The length of the arrow at which the stretch should have no effect.
  final double stretchMax;

  /// The effect that the arrow's length will have, relative to its minStretch
  /// and maxStretch, on the bow of the arrow. At 0, the stretch will have no effect.
  final double stretch;

  /// How far the arrow's starting point should be from the provided start point.
  final double padStart;

  /// How far the arrow's ending point should be from the provided end point.
  final double padEnd;

  /// Whether to reflect the arrow's bow angle.
  /// Only used if [arcRotation] is [ArcDirection.Auto]
  final bool flip;

  /// Whether to use straight lines at 45 degree angles.
  final bool straights;

  /// If arrow is not straight, which direction the arc should follow
  final ArcDirection arcDirection;

  ArrowPainter({
    required this.targetRenderBox,
    required this.sourceRenderBox,
    required this.animation,
    this.sourceAnchor = Alignment.centerLeft,
    this.targetAnchor = Alignment.centerLeft,
    this.doubleSided = false,
    this.color = Colors.blue,
    this.width = 3,
    this.tipLength = 15,
    this.tipAngleOutwards = pi * 0.2,
    this.bow = 0.2,
    this.stretchMin = 0,
    this.stretchMax = 420,
    this.stretch = 0.5,
    this.padStart = 0,
    this.padEnd = 0,
    this.flip = false,
    this.straights = true,
    this.arcDirection = ArcDirection.auto,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final startGlobalOffset = sourceRenderBox.localToGlobal(Offset.zero);
    final endGlobalOffset = targetRenderBox.localToGlobal(Offset.zero);

    final startPosition = sourceAnchor.resolve(TextDirection.ltr).withinRect(
        Rect.fromLTWH(startGlobalOffset.dx, startGlobalOffset.dy,
            sourceRenderBox.size.width, sourceRenderBox.size.height));
    final endPosition = targetAnchor.resolve(TextDirection.ltr).withinRect(
        Rect.fromLTWH(endGlobalOffset.dx, endGlobalOffset.dy,
            targetRenderBox.size.width, targetRenderBox.size.height));

    final arrow = getArrow(
      startPosition.dx,
      startPosition.dy,
      endPosition.dx,
      endPosition.dy,
      bow: bow,
      stretch: stretch,
      stretchMin: stretchMin,
      stretchMax: stretchMax,
      padStart: padStart,
      padEnd: padEnd,
      straights: straights,
      flip: flip,
      arcDirection: arcDirection,
    );

    final path = _createPath(arrow);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = width;

    // Below creates dashed path. without this it draw continuous path.
    final dashedPath = dashPath(
      path,
      dashArray: CircularIntervalList<double>(
        <double>[5, 10],
      ),
    );
    final animatedPath = createAnimatedPath(dashedPath, animation.value);
    canvas.drawPath(animatedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Flutter's repaint system is smart enough to know when to repaint but we can
    // be double sure by checking old != new but here I haven't done it because
    // i'm lazy.
    return true;
  }

  /// Provides part of the path so that we can animate it.
  Path createAnimatedPath(
    Path originalPath,
    double animationPercent,
  ) {
    final totalLength = originalPath
        .computeMetrics()
        .fold(0.0, (double prev, PathMetric metric) => prev + metric.length);

    final currentLength = totalLength * animationPercent;

    return extractPathUntilLength(originalPath, currentLength);
  }

  Path extractPathUntilLength(
    Path originalPath,
    double length,
  ) {
    var currentLength = 0.0;

    final path = Path();

    var metricsIterator = originalPath.computeMetrics().iterator;

    while (metricsIterator.moveNext()) {
      var metric = metricsIterator.current;

      var nextLength = currentLength + metric.length;

      final isLastSegment = nextLength > length;
      if (isLastSegment) {
        final remainingLength = length - currentLength;
        final pathSegment = metric.extractPath(0.0, remainingLength);

        path.addPath(pathSegment, Offset.zero);
        break;
      } else {
        // There might be a more efficient way of extracting an entire path
        final pathSegment = metric.extractPath(0.0, metric.length);
        path.addPath(pathSegment, Offset.zero);
      }

      currentLength = nextLength;
    }

    return path;
  }

  Path _createPath(Arrow arrow) {
    final path = Path()
      ..moveTo(arrow.sx, arrow.sy)
      ..quadraticBezierTo(arrow.cx, arrow.cy, arrow.ex, arrow.ey);

    final metrics = path.computeMetrics().toList();

    final lastPathMetric = metrics.last;
    final firstPathMetric = metrics.first;

    var tan = lastPathMetric.getTangentForOffset(lastPathMetric.length)!;
    var adjustmentAngle = 0.0;

    final tipAngleStart = tipAngleOutwards;

    final angleStart = pi - tipAngleStart;
    final originalPosition = tan.position;

    if (lastPathMetric.length > 10) {
      final tanBefore =
          lastPathMetric.getTangentForOffset(lastPathMetric.length - 5)!;
      adjustmentAngle = _getAngleBetweenVectors(tan.vector, tanBefore.vector);
    }

    Offset tipVector;

    tipVector =
        _rotateVector(tan.vector, angleStart - adjustmentAngle) * tipLength;
    path.moveTo(tan.position.dx, tan.position.dy);
    path.relativeLineTo(tipVector.dx, tipVector.dy);

    tipVector =
        _rotateVector(tan.vector, -angleStart - adjustmentAngle) * tipLength;
    path.moveTo(tan.position.dx, tan.position.dy);
    path.relativeLineTo(tipVector.dx, tipVector.dy);

    if (doubleSided) {
      tan = firstPathMetric.getTangentForOffset(0)!;
      if (firstPathMetric.length > 10) {
        final tanBefore = firstPathMetric.getTangentForOffset(5)!;
        adjustmentAngle = _getAngleBetweenVectors(tan.vector, tanBefore.vector);
      }

      tipVector =
          _rotateVector(-tan.vector, angleStart - adjustmentAngle) * tipLength;
      path.moveTo(tan.position.dx, tan.position.dy);
      path.relativeLineTo(tipVector.dx, tipVector.dy);

      tipVector =
          _rotateVector(-tan.vector, -angleStart - adjustmentAngle) * tipLength;
      path.moveTo(tan.position.dx, tan.position.dy);
      path.relativeLineTo(tipVector.dx, tipVector.dy);
    }

    path.moveTo(originalPosition.dx, originalPosition.dy);
    return path;
  }

  static Offset _rotateVector(Offset vector, double angle) => Offset(
        cos(angle) * vector.dx - sin(angle) * vector.dy,
        sin(angle) * vector.dx + cos(angle) * vector.dy,
      );

  static double _getVectorsDotProduct(Offset vector1, Offset vector2) =>
      vector1.dx * vector2.dx + vector1.dy * vector2.dy;

  // Clamp to avoid rounding issues when the 2 vectors are equal.
  static double _getAngleBetweenVectors(Offset vector1, Offset vector2) =>
      acos((_getVectorsDotProduct(vector1, vector2) /
              (vector1.distance * vector2.distance))
          .clamp(-1.0, 1.0));
}
