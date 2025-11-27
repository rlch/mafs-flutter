import 'package:flutter/widgets.dart';

import '../context/coordinate_context.dart';
import '../context/transform_context.dart';
import '../vec.dart';
import 'theme.dart';

/// Cardinal directions for positioning text relative to a point.
///
/// These directions determine how the text is anchored and aligned
/// relative to the specified (x, y) coordinate.
enum CardinalDirection {
  /// North - text is positioned above the point, horizontally centered.
  n,

  /// Northeast - text is positioned above and to the right of the point.
  ne,

  /// East - text is positioned to the right of the point, vertically centered.
  e,

  /// Southeast - text is positioned below and to the right of the point.
  se,

  /// South - text is positioned below the point, horizontally centered.
  s,

  /// Southwest - text is positioned below and to the left of the point.
  sw,

  /// West - text is positioned to the left of the point, vertically centered.
  w,

  /// Northwest - text is positioned above and to the left of the point.
  nw,
}

/// Text displayed at a specific coordinate.
///
/// This widget displays text at the given (x, y) position in math coordinates.
/// The position is transformed using the current [TransformContext] to map
/// from math space to screen space.
///
/// The [attach] property controls how the text is positioned relative to the
/// point - for example, `CardinalDirection.n` places the text above the point.
///
/// Example:
/// ```dart
/// Mafs(
///   children: [
///     MafsPoint(x: 1, y: 2),
///     MafsText(x: 1, y: 2, text: 'Point A', attach: CardinalDirection.n),
///   ],
/// )
/// ```
class MafsText extends LeafRenderObjectWidget {
  /// Creates text at the specified coordinates.
  const MafsText({
    super.key,
    required this.x,
    required this.y,
    required this.text,
    this.color,
    this.size = 30,
    this.attach,
    this.attachDistance = 0,
  });

  /// The x-coordinate in math space.
  final double x;

  /// The y-coordinate in math space.
  final double y;

  /// The text string to display.
  final String text;

  /// The text color.
  ///
  /// If null, uses [MafsThemeData.foreground] from the nearest [MafsTheme].
  final Color? color;

  /// The font size in pixels.
  ///
  /// Defaults to 30.
  final double size;

  /// The direction to position the text relative to the point.
  ///
  /// If null, the text is centered on the point.
  final CardinalDirection? attach;

  /// The distance in pixels to offset the text from the point.
  ///
  /// This offset is applied in the direction specified by [attach].
  /// Defaults to 0.
  final double attachDistance;

  @override
  RenderMafsText createRenderObject(BuildContext context) {
    final transformData = TransformContext.of(context);
    final coordData = CoordinateContext.of(context);

    return RenderMafsText(
      x: x,
      y: y,
      text: text,
      color: color ?? MafsTheme.of(context).foreground,
      fontSize: size,
      attachDirection: attach,
      attachDistance: attachDistance,
      userTransform: transformData.userTransform,
      xMin: coordData.xMin,
      xMax: coordData.xMax,
      yMin: coordData.yMin,
      yMax: coordData.yMax,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderMafsText renderObject) {
    final transformData = TransformContext.of(context);
    final coordData = CoordinateContext.of(context);

    renderObject
      ..x = x
      ..y = y
      ..text = text
      ..color = color ?? MafsTheme.of(context).foreground
      ..fontSize = size
      ..attachDirection = attach
      ..attachDistance = attachDistance
      ..userTransform = transformData.userTransform
      ..xMin = coordData.xMin
      ..xMax = coordData.xMax
      ..yMin = coordData.yMin
      ..yMax = coordData.yMax;
  }
}

/// The render object for [MafsText].
///
/// Paints text at the transformed position using Flutter's [TextPainter].
class RenderMafsText extends RenderBox {
  /// Creates a render object for painting text.
  RenderMafsText({
    required double x,
    required double y,
    required String text,
    required Color color,
    required double fontSize,
    required CardinalDirection? attachDirection,
    required double attachDistance,
    required Matrix2D userTransform,
    required double xMin,
    required double xMax,
    required double yMin,
    required double yMax,
  })  : _x = x,
        _y = y,
        _text = text,
        _color = color,
        _fontSize = fontSize,
        _attachDirection = attachDirection,
        _attachDistance = attachDistance,
        _userTransform = userTransform,
        _xMin = xMin,
        _xMax = xMax,
        _yMin = yMin,
        _yMax = yMax {
    _updateTextPainter();
  }

  TextPainter? _textPainter;

  void _updateTextPainter() {
    _textPainter = TextPainter(
      text: TextSpan(
        text: _text,
        style: TextStyle(
          color: _color,
          fontSize: _fontSize,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  double _x;

  /// The x-coordinate in math space.
  double get x => _x;
  set x(double value) {
    if (_x == value) return;
    _x = value;
    markNeedsPaint();
  }

  double _y;

  /// The y-coordinate in math space.
  double get y => _y;
  set y(double value) {
    if (_y == value) return;
    _y = value;
    markNeedsPaint();
  }

  String _text;

  /// The text to display.
  String get text => _text;
  set text(String value) {
    if (_text == value) return;
    _text = value;
    _updateTextPainter();
    markNeedsPaint();
  }

  Color _color;

  /// The text color.
  Color get color => _color;
  set color(Color value) {
    if (_color == value) return;
    _color = value;
    _updateTextPainter();
    markNeedsPaint();
  }

  double _fontSize;

  /// The font size in pixels.
  double get fontSize => _fontSize;
  set fontSize(double value) {
    if (_fontSize == value) return;
    _fontSize = value;
    _updateTextPainter();
    markNeedsPaint();
  }

  CardinalDirection? _attachDirection;

  /// The direction to position text relative to the point.
  CardinalDirection? get attachDirection => _attachDirection;
  set attachDirection(CardinalDirection? value) {
    if (_attachDirection == value) return;
    _attachDirection = value;
    markNeedsPaint();
  }

  double _attachDistance;

  /// The offset distance in pixels.
  double get attachDistance => _attachDistance;
  set attachDistance(double value) {
    if (_attachDistance == value) return;
    _attachDistance = value;
    markNeedsPaint();
  }

  Matrix2D _userTransform;

  /// The user transform (for nested Transform widgets).
  Matrix2D get userTransform => _userTransform;
  set userTransform(Matrix2D value) {
    if (_userTransform == value) return;
    _userTransform = value;
    markNeedsPaint();
  }

  double _xMin;

  /// The minimum x-coordinate of the viewport.
  double get xMin => _xMin;
  set xMin(double value) {
    if (_xMin == value) return;
    _xMin = value;
    markNeedsPaint();
  }

  double _xMax;

  /// The maximum x-coordinate of the viewport.
  double get xMax => _xMax;
  set xMax(double value) {
    if (_xMax == value) return;
    _xMax = value;
    markNeedsPaint();
  }

  double _yMin;

  /// The minimum y-coordinate of the viewport.
  double get yMin => _yMin;
  set yMin(double value) {
    if (_yMin == value) return;
    _yMin = value;
    markNeedsPaint();
  }

  double _yMax;

  /// The maximum y-coordinate of the viewport.
  double get yMax => _yMax;
  set yMax(double value) {
    if (_yMax == value) return;
    _yMax = value;
    markNeedsPaint();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  void performResize() {
    size = computeDryLayout(constraints);
  }

  @override
  void performLayout() {
    // Size is set in performResize since sizedByParent is true.
    // No additional layout work needed.
  }

  /// Calculate the horizontal alignment offset based on the attach direction.
  ///
  /// Returns:
  /// - 0.0 for start alignment (text starts at point): e, ne, se
  /// - 0.5 for center alignment (text centered on point): n, s, or null
  /// - 1.0 for end alignment (text ends at point): w, nw, sw
  double _getHorizontalAlignment() {
    switch (_attachDirection) {
      case CardinalDirection.e:
      case CardinalDirection.ne:
      case CardinalDirection.se:
        return 0.0; // Text starts at point (anchor at start)
      case CardinalDirection.w:
      case CardinalDirection.nw:
      case CardinalDirection.sw:
        return 1.0; // Text ends at point (anchor at end)
      case CardinalDirection.n:
      case CardinalDirection.s:
      case null:
        return 0.5; // Text centered on point
    }
  }

  /// Calculate the vertical alignment offset based on the attach direction.
  ///
  /// Returns:
  /// - 0.0 for top alignment (text below point): s, se, sw
  /// - 0.5 for middle alignment (text centered on point): e, w, or null
  /// - 1.0 for bottom alignment (text above point): n, ne, nw
  double _getVerticalAlignment() {
    switch (_attachDirection) {
      case CardinalDirection.s:
      case CardinalDirection.se:
      case CardinalDirection.sw:
        return 0.0; // Baseline at top (text below point)
      case CardinalDirection.n:
      case CardinalDirection.ne:
      case CardinalDirection.nw:
        return 1.0; // Baseline at bottom (text above point)
      case CardinalDirection.e:
      case CardinalDirection.w:
      case null:
        return 0.5; // Text centered vertically
    }
  }

  /// Calculate the pixel offset based on the attach direction and distance.
  Offset _getAttachOffset() {
    if (_attachDirection == null || _attachDistance == 0) {
      return Offset.zero;
    }

    switch (_attachDirection!) {
      case CardinalDirection.n:
        return Offset(0, -_attachDistance);
      case CardinalDirection.ne:
        return Offset(_attachDistance, -_attachDistance);
      case CardinalDirection.e:
        return Offset(_attachDistance, 0);
      case CardinalDirection.se:
        return Offset(_attachDistance, _attachDistance);
      case CardinalDirection.s:
        return Offset(0, _attachDistance);
      case CardinalDirection.sw:
        return Offset(-_attachDistance, _attachDistance);
      case CardinalDirection.w:
        return Offset(-_attachDistance, 0);
      case CardinalDirection.nw:
        return Offset(-_attachDistance, -_attachDistance);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_textPainter == null) return;

    final canvas = context.canvas;

    // Use our laid-out size for calculations
    final width = size.width;
    final height = size.height;

    // Calculate spans from coordinate bounds
    final xSpan = _xMax - _xMin;
    final ySpan = _yMax - _yMin;

    // Apply userTransform to the point (for nested transforms)
    final mathPoint = Offset(_x, _y);
    final userTransformedPoint = mathPoint.transform(_userTransform);

    // Calculate position in screen coordinates
    // Same formula as point: screenX = (x - xMin) / xSpan * width
    final screenX =
        (userTransformedPoint.dx - _xMin) / xSpan * width + offset.dx;
    final screenY =
        (1 - (userTransformedPoint.dy - _yMin) / ySpan) * height + offset.dy;

    // Get text dimensions
    final textWidth = _textPainter!.width;
    final textHeight = _textPainter!.height;

    // Calculate horizontal and vertical alignment
    final hAlign = _getHorizontalAlignment();
    final vAlign = _getVerticalAlignment();

    // Calculate attachment offset
    final attachOffset = _getAttachOffset();

    // Calculate final text position
    // hAlign: 0 = text starts at point, 0.5 = centered, 1 = text ends at point
    // vAlign: 0 = text below point, 0.5 = centered, 1 = text above point
    final textX = screenX - textWidth * hAlign + attachOffset.dx;
    final textY = screenY - textHeight * vAlign + attachOffset.dy;

    // Paint the text
    _textPainter!.paint(canvas, Offset(textX, textY));
  }

  @override
  bool hitTestSelf(Offset position) {
    if (_textPainter == null) return false;

    // Use same formula as paint
    final width = size.width;
    final height = size.height;
    final xSpan = _xMax - _xMin;
    final ySpan = _yMax - _yMin;

    // Apply userTransform to the point
    final mathPoint = Offset(_x, _y);
    final userTransformedPoint = mathPoint.transform(_userTransform);

    // Calculate position in screen coordinates (relative to this render object)
    final screenX = (userTransformedPoint.dx - _xMin) / xSpan * width;
    final screenY = (1 - (userTransformedPoint.dy - _yMin) / ySpan) * height;

    // Get text dimensions
    final textWidth = _textPainter!.width;
    final textHeight = _textPainter!.height;

    // Calculate horizontal and vertical alignment
    final hAlign = _getHorizontalAlignment();
    final vAlign = _getVerticalAlignment();

    // Calculate attachment offset
    final attachOffset = _getAttachOffset();

    // Calculate final text position
    final textX = screenX - textWidth * hAlign + attachOffset.dx;
    final textY = screenY - textHeight * vAlign + attachOffset.dy;

    // Check if the position is within the text bounds
    final textRect = Rect.fromLTWH(textX, textY, textWidth, textHeight);
    return textRect.contains(position);
  }
}
