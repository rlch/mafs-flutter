import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../context/coordinate_context.dart';
import '../context/transform_context.dart';
import '../vec.dart';
import 'theme.dart';

/// A vector (arrow) from a tail point to a tip point.
///
/// Renders a line with an arrowhead at the tip. The arrowhead automatically
/// orients to point in the direction of the vector.
///
/// Example:
/// ```dart
/// MafsVector(
///   tip: Offset(3, 2),
///   color: MafsColors.blue,
/// )
/// ```
///
/// With a custom tail:
/// ```dart
/// MafsVector(
///   tail: Offset(1, 1),
///   tip: Offset(4, 3),
///   color: MafsColors.red,
/// )
/// ```
class MafsVector extends LeafRenderObjectWidget {
  /// Creates a vector from [tail] to [tip].
  ///
  /// If [tail] is not specified, defaults to the origin (0, 0).
  const MafsVector({
    super.key,
    this.tail = Offset.zero,
    required this.tip,
    this.color,
    this.opacity = 1.0,
    this.weight = 2,
    this.style = StrokeStyle.solid,
  }) : assert(opacity >= 0.0 && opacity <= 1.0);

  /// The starting point of the vector in math coordinates.
  ///
  /// Defaults to the origin (0, 0).
  final Offset tail;

  /// The ending point (arrowhead) of the vector in math coordinates.
  final Offset tip;

  /// The stroke and fill color.
  ///
  /// If null, uses [MafsThemeData.foreground] from the nearest [MafsTheme].
  final Color? color;

  /// The opacity of the vector (0.0 to 1.0).
  final double opacity;

  /// The stroke weight in pixels.
  final double weight;

  /// The stroke style (solid or dashed).
  final StrokeStyle style;

  @override
  RenderObject createRenderObject(BuildContext context) {
    final transformData = TransformContext.of(context);
    final coordData = CoordinateContext.of(context);

    return RenderMafsVector(
      tail: tail,
      tip: tip,
      color: color ?? MafsTheme.of(context).foreground,
      opacity: opacity,
      weight: weight,
      style: style,
      userTransform: transformData.userTransform,
      xMin: coordData.xMin,
      xMax: coordData.xMax,
      yMin: coordData.yMin,
      yMax: coordData.yMax,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderMafsVector renderObject) {
    final transformData = TransformContext.of(context);
    final coordData = CoordinateContext.of(context);

    renderObject
      ..tail = tail
      ..tip = tip
      ..color = color ?? MafsTheme.of(context).foreground
      ..opacity = opacity
      ..weight = weight
      ..style = style
      ..userTransform = transformData.userTransform
      ..xMin = coordData.xMin
      ..xMax = coordData.xMax
      ..yMin = coordData.yMin
      ..yMax = coordData.yMax;
  }
}

/// The render object for [MafsVector].
class RenderMafsVector extends RenderBox {
  /// Creates a render object for a vector.
  RenderMafsVector({
    required Offset tail,
    required Offset tip,
    required Color color,
    required double opacity,
    required double weight,
    required StrokeStyle style,
    required Matrix2D userTransform,
    required double xMin,
    required double xMax,
    required double yMin,
    required double yMax,
  })  : _tail = tail,
        _tip = tip,
        _color = color,
        _opacity = opacity,
        _weight = weight,
        _style = style,
        _userTransform = userTransform,
        _xMin = xMin,
        _xMax = xMax,
        _yMin = yMin,
        _yMax = yMax;

  /// The size of the arrowhead in pixels.
  static const double arrowSize = 8.0;

  Offset _tail;
  Offset get tail => _tail;
  set tail(Offset value) {
    if (_tail == value) return;
    _tail = value;
    markNeedsPaint();
  }

  Offset _tip;
  Offset get tip => _tip;
  set tip(Offset value) {
    if (_tip == value) return;
    _tip = value;
    markNeedsPaint();
  }

  Color _color;
  Color get color => _color;
  set color(Color value) {
    if (_color == value) return;
    _color = value;
    markNeedsPaint();
  }

  double _opacity;
  double get opacity => _opacity;
  set opacity(double value) {
    if (_opacity == value) return;
    _opacity = value;
    markNeedsPaint();
  }

  double _weight;
  double get weight => _weight;
  set weight(double value) {
    if (_weight == value) return;
    _weight = value;
    markNeedsPaint();
  }

  StrokeStyle _style;
  StrokeStyle get style => _style;
  set style(StrokeStyle value) {
    if (_style == value) return;
    _style = value;
    markNeedsPaint();
  }

  Matrix2D _userTransform;
  Matrix2D get userTransform => _userTransform;
  set userTransform(Matrix2D value) {
    if (_userTransform == value) return;
    _userTransform = value;
    markNeedsPaint();
  }

  double _xMin;
  double get xMin => _xMin;
  set xMin(double value) {
    if (_xMin == value) return;
    _xMin = value;
    markNeedsPaint();
  }

  double _xMax;
  double get xMax => _xMax;
  set xMax(double value) {
    if (_xMax == value) return;
    _xMax = value;
    markNeedsPaint();
  }

  double _yMin;
  double get yMin => _yMin;
  set yMin(double value) {
    if (_yMin == value) return;
    _yMin = value;
    markNeedsPaint();
  }

  double _yMax;
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

  /// Converts a math coordinate to screen coordinate.
  Offset _mathToScreen(Offset mathPoint) {
    final width = size.width;
    final height = size.height;
    final xSpan = _xMax - _xMin;
    final ySpan = _yMax - _yMin;

    final screenX = (mathPoint.dx - _xMin) / xSpan * width;
    final screenY = (1 - (mathPoint.dy - _yMin) / ySpan) * height;
    return Offset(screenX, screenY);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    // Apply userTransform to both points
    final transformedTail = _tail.transform(_userTransform);
    final transformedTip = _tip.transform(_userTransform);

    // Convert to screen coordinates
    final screenTail = _mathToScreen(transformedTail) + offset;
    final screenTip = _mathToScreen(transformedTip) + offset;

    // Calculate the direction vector
    final direction = screenTip - screenTail;
    final length = direction.distance;

    if (length < 0.001) return; // Skip if vector is too short

    // Normalize direction
    final unitDirection = direction / length;

    // Calculate the point where the line should end (before the arrowhead)
    final lineEnd = screenTip - unitDirection * arrowSize;

    // Create paint for the line
    final strokeColor = _color.withValues(alpha: _color.a * _opacity);
    final strokePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = _weight
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw the line (from tail to just before the arrowhead)
    if (_style == StrokeStyle.dashed) {
      _drawDashedLine(canvas, screenTail, lineEnd, strokePaint);
    } else {
      canvas.drawLine(screenTail, lineEnd, strokePaint);
    }

    // Draw the arrowhead
    _drawArrowhead(canvas, screenTip, unitDirection, strokeColor);
  }

  /// Draws the arrowhead as a filled triangle.
  void _drawArrowhead(Canvas canvas, Offset tip, Offset direction, Color color) {
    // Calculate perpendicular direction for the arrowhead width
    final perpendicular = Offset(-direction.dy, direction.dx);

    // Arrowhead points
    final arrowBack = tip - direction * arrowSize;
    final arrowLeft = arrowBack + perpendicular * (arrowSize / 2);
    final arrowRight = arrowBack - perpendicular * (arrowSize / 2);

    // Draw filled triangle
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(arrowLeft.dx, arrowLeft.dy)
      ..lineTo(arrowRight.dx, arrowRight.dy)
      ..close();

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);
  }

  /// Draws a dashed line between two points.
  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashLength = 8.0;
    const gapLength = 4.0;

    final delta = p2 - p1;
    final length = delta.distance;
    if (length == 0) return;

    final direction = delta / length;
    var distance = 0.0;
    var draw = true;

    while (distance < length) {
      final segmentLength = draw ? dashLength : gapLength;
      final nextDistance = math.min(distance + segmentLength, length);

      if (draw) {
        final start = p1 + direction * distance;
        final end = p1 + direction * nextDistance;
        canvas.drawLine(start, end, paint);
      }

      distance = nextDistance;
      draw = !draw;
    }
  }

  @override
  bool hitTestSelf(Offset position) => false;
}
