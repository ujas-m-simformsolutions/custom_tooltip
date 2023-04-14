import 'package:flutter/material.dart';
import 'package:genopets_tooltip/core/painters/arrow_painter.dart';

import '../enums.dart';
import '../painters/overlay_painter.dart';

class OverlayBuilder extends StatefulWidget {
  @override
  final GlobalKey key;
  final GlobalKey toolTipKey;

  final Widget child;
  final Widget toolTip;

  const OverlayBuilder({
    required this.key,
    required this.child,
    required this.toolTip,
    required this.toolTipKey,
  }) : super(key: key);

  @override
  State<OverlayBuilder> createState() => _OverlayBuilderState();
}

class _OverlayBuilderState extends State<OverlayBuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  VerticalPosition verticalPosition = VerticalPosition.unknown;
  HorizontalPosition horizontalPosition = HorizontalPosition.unknown;

  Rect? rect;
  OverlayEntry? overlayEntry;
  Offset? widgetPosition;

  RenderBox? source;
  RenderBox? target;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _findTargetAndAddEntry();
  }

  @override
  void dispose() {
    Overlay.of(context).dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _findTargetAndAddEntry() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final box = widget.key.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        target = box;
        widgetPosition = box.localToGlobal(Offset.zero);
        // This `&` operation between offset and size gives rect object so no
        // need to do operations similar to showcase view.
        final bound = widgetPosition! & box.size;
        rect = bound;
        setState(() {});
      }
      _addEntry();
    });
  }

  void _calculateTooltipPosition() {
    if (widgetPosition != null) {
      if (MediaQuery.of(context).size.height / 2 > widgetPosition!.dy) {
        verticalPosition = VerticalPosition.top;
      } else {
        verticalPosition = VerticalPosition.bottom;
      }
      if (MediaQuery.of(context).size.width / 2 > widgetPosition!.dx) {
        horizontalPosition = HorizontalPosition.left;
      } else {
        horizontalPosition = HorizontalPosition.right;
      }
    }
  }

  void _addEntry() {
    _calculateTooltipPosition();
    overlayEntry = OverlayEntry(
      builder: (_) => _buildOverlay(),
    );
    Overlay.of(context).insert(overlayEntry!);
    WidgetsBinding.instance.endOfFrame.then((_) {
      final tooltipContext = widget.toolTipKey.currentContext;
      if (tooltipContext != null) {
        final tooltipBox = tooltipContext.findRenderObject() as RenderBox?;
        if (tooltipBox != null) {
          setState(() {
            source = tooltipBox;
          });
          controller.forward();
          // We have to call setState like this because tooltip is laid out after
          // overlay is created so we will get it's render object some time
          // later and as overlay isn't in same context we have to call
          // setState from here.
          Overlay.of(context).setState(() {});
        }
      }
    });
  }

  Widget _buildOverlay() {
    return Stack(
      children: [
        IgnorePointer(
          ignoring: true,
          child: CustomPaint(
            size: MediaQuery.of(context).size,
            painter: rect != null
                ? OverlayPainter(
                    radius: 8,
                    shadow: BoxShadow(
                      color: const Color(0xff240032).withOpacity(.85),
                      blurRadius: 8,
                    ),
                    rect: rect!,
                  )
                : null,
          ),
        ),
        Positioned(
          top: verticalPosition == VerticalPosition.top ? 200 : null,
          bottom: verticalPosition == VerticalPosition.bottom ? 200 : null,
          right: horizontalPosition == HorizontalPosition.right ? 200 : null,
          left: horizontalPosition == HorizontalPosition.left ? 200 : null,
          child: widget.toolTip,
        ),
        CustomPaint(
          painter: source != null && target != null
              ? ArrowPainter(
                  sourceRenderBox: source!,
                  targetRenderBox: target!,
                  animation: controller,
                  arcDirection: ArcDirection.right,
                  padEnd: 10,
                  sourceAnchor: Alignment.centerRight,
                  targetAnchor: Alignment.topCenter,
                )
              : null,
        ),
      ],
    );
  }
}
