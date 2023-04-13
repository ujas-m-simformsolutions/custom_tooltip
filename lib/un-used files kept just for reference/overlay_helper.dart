import 'package:flutter/material.dart';
import 'package:genopets_tooltip/un-used%20files%20kept%20just%20for%20reference/widget_arrow.dart';

import '../core/enums.dart';

class OverlayHelper {
  OverlayEntry? _entry;
  VerticalPosition _verticalPosition = VerticalPosition.unknown;
  HorizontalPosition _horizontalPosition = HorizontalPosition.unknown;

  void addOverlay({
    required BuildContext context,
    required Offset widgetPosition,
  }) {
    if (MediaQuery.of(context).size.height / 2 > widgetPosition.dy) {
      _verticalPosition = VerticalPosition.top;
    } else {
      _verticalPosition = VerticalPosition.bottom;
    }
    if (MediaQuery.of(context).size.width / 2 > widgetPosition.dx) {
      _horizontalPosition = HorizontalPosition.left;
    } else {
      _horizontalPosition = HorizontalPosition.right;
    }
    _entry = OverlayEntry(
      builder: (_) {
        return ArrowElement(
          id: 'id2',
          child: Positioned(
            top: _verticalPosition == VerticalPosition.top ? 200 : null,
            bottom: _verticalPosition == VerticalPosition.bottom ? 200 : null,
            right: _horizontalPosition == HorizontalPosition.right ? 200 : null,
            left: _horizontalPosition == HorizontalPosition.left ? 200 : null,
            child: Container(
              height: 100,
              width: 100,
              color: Colors.red,
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_entry!);
  }

  void remove() {
    _entry?.remove();
  }
}
