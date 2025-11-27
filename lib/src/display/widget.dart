import 'package:flutter/widgets.dart';

import '../context/coordinate_context.dart';
import '../context/transform_context.dart';
import '../math.dart';
import '../vec.dart';

/// A widget that positions any Flutter widget at math coordinates.
///
/// This provides a generic way to place arbitrary widgets (images, custom
/// widgets, complex layouts, etc.) within the Mafs coordinate system.
///
/// ## Sizing Modes
///
/// The [width] and [height] parameters control how the widget is sized:
///
/// - **Both provided**: Widget is sized in math units and scales with zoom.
///   Useful for images and diagrams that should be part of the coordinate space.
///
/// - **Neither provided**: Widget uses its intrinsic pixel size and does NOT
///   scale with zoom. Useful for labels, buttons, and UI elements.
///
/// - **One provided**: That dimension is in math units (scales), the other
///   uses intrinsic size (fixed).
///
/// ## Anchoring
///
/// The [anchor] parameter determines which point of the widget is placed at
/// the (x, y) coordinate:
///
/// - [Anchor.tl] - top-left corner at (x, y)
/// - [Anchor.cc] - center at (x, y) (default)
/// - [Anchor.br] - bottom-right corner at (x, y)
/// - etc.
///
/// ## Example
///
/// ```dart
/// // Image sized in math units (scales with zoom)
/// MafsWidget(
///   x: 1,
///   y: 2,
///   width: 2,
///   height: 1,
///   child: Image.asset('diagram.png'),
/// )
///
/// // Fixed-size label (doesn't scale with zoom)
/// MafsWidget(
///   x: 1,
///   y: 2,
///   anchor: Anchor.tl,
///   child: Text('Label', style: TextStyle(fontSize: 14)),
/// )
///
/// // Custom widget at origin
/// MafsWidget(
///   x: 0,
///   y: 0,
///   child: Container(
///     width: 100,
///     height: 50,
///     color: Colors.blue,
///     child: Text('Custom'),
///   ),
/// )
/// ```
class MafsWidget extends StatelessWidget {
  /// Creates a widget positioned at math coordinates.
  ///
  /// If [width] and [height] are provided, the widget is sized in math units
  /// and will scale with zoom. If omitted, the child uses its intrinsic
  /// pixel size (fixed, doesn't scale).
  const MafsWidget({
    super.key,
    required this.x,
    required this.y,
    required this.child,
    this.width,
    this.height,
    this.anchor = Anchor.cc,
  });

  /// The x-coordinate in math space.
  final double x;

  /// The y-coordinate in math space.
  final double y;

  /// The width in math units.
  ///
  /// If null, uses the child's intrinsic width in pixels.
  /// When provided, the widget scales with zoom.
  final double? width;

  /// The height in math units.
  ///
  /// If null, uses the child's intrinsic height in pixels.
  /// When provided, the widget scales with zoom.
  final double? height;

  /// The anchor point for positioning.
  ///
  /// Determines which point of the widget is placed at (x, y).
  /// Defaults to [Anchor.cc] (center-center).
  final Anchor anchor;

  /// The child widget to position.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final coordData = CoordinateContext.of(context);
    final transformData = TransformContext.of(context);

    // Transform math point through user transform
    final mathPoint = Offset(x, y);
    final transformed = mathPoint.transform(transformData.userTransform);

    // Convert to screen coordinates
    final xSpan = coordData.xMax - coordData.xMin;
    final ySpan = coordData.yMax - coordData.yMin;
    final screenX = (transformed.dx - coordData.xMin) / xSpan * coordData.width;
    final screenY =
        (1 - (transformed.dy - coordData.yMin) / ySpan) * coordData.height;

    // Calculate pixel dimensions if provided in math units
    final pixelWidth = width != null ? width! / xSpan * coordData.width : null;
    final pixelHeight =
        height != null ? height! / ySpan * coordData.height : null;

    return CustomSingleChildLayout(
      delegate: _MafsWidgetDelegate(
        screenX: screenX,
        screenY: screenY,
        pixelWidth: pixelWidth,
        pixelHeight: pixelHeight,
        anchor: anchor,
      ),
      child: pixelWidth != null || pixelHeight != null
          ? SizedBox(
              width: pixelWidth,
              height: pixelHeight,
              child: child,
            )
          : child,
    );
  }
}

class _MafsWidgetDelegate extends SingleChildLayoutDelegate {
  _MafsWidgetDelegate({
    required this.screenX,
    required this.screenY,
    this.pixelWidth,
    this.pixelHeight,
    required this.anchor,
  });

  final double screenX;
  final double screenY;
  final double? pixelWidth;
  final double? pixelHeight;
  final Anchor anchor;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    if (pixelWidth != null && pixelHeight != null) {
      return BoxConstraints.tight(Size(pixelWidth!, pixelHeight!));
    } else if (pixelWidth != null) {
      return BoxConstraints(
        minWidth: pixelWidth!,
        maxWidth: pixelWidth!,
        maxHeight: constraints.maxHeight,
      );
    } else if (pixelHeight != null) {
      return BoxConstraints(
        maxWidth: constraints.maxWidth,
        minHeight: pixelHeight!,
        maxHeight: pixelHeight!,
      );
    }
    return constraints.loosen();
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // Calculate position based on anchor
    // Anchor determines which point of the widget is at (screenX, screenY)
    double actualX = screenX;
    double actualY = screenY;

    // Horizontal alignment
    switch (anchor) {
      case Anchor.tl:
      case Anchor.cl:
      case Anchor.bl:
        // Left anchor - left edge at screenX
        break;
      case Anchor.tc:
      case Anchor.cc:
      case Anchor.bc:
        // Center anchor - center at screenX
        actualX = screenX - childSize.width / 2;
      case Anchor.tr:
      case Anchor.cr:
      case Anchor.br:
        // Right anchor - right edge at screenX
        actualX = screenX - childSize.width;
    }

    // Vertical alignment (screen coordinates, y increases downward)
    switch (anchor) {
      case Anchor.tl:
      case Anchor.tc:
      case Anchor.tr:
        // Top anchor - top edge at screenY
        break;
      case Anchor.cl:
      case Anchor.cc:
      case Anchor.cr:
        // Center anchor - center at screenY
        actualY = screenY - childSize.height / 2;
      case Anchor.bl:
      case Anchor.bc:
      case Anchor.br:
        // Bottom anchor - bottom edge at screenY
        actualY = screenY - childSize.height;
    }

    return Offset(actualX, actualY);
  }

  @override
  bool shouldRelayout(_MafsWidgetDelegate oldDelegate) {
    return screenX != oldDelegate.screenX ||
        screenY != oldDelegate.screenY ||
        pixelWidth != oldDelegate.pixelWidth ||
        pixelHeight != oldDelegate.pixelHeight ||
        anchor != oldDelegate.anchor;
  }

  @override
  Size getSize(BoxConstraints constraints) => constraints.biggest;
}
