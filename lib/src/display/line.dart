import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../context/coordinate_context.dart';
import '../context/transform_context.dart';
import '../vec.dart';
import 'theme.dart';

/// A namespace containing different line component variants.
///
/// Use [Line.segment] for a line segment between two points,
/// [Line.throughPoints] for an infinite line through two points,
/// [Line.pointAngle] for an infinite line at a point with an angle,
/// or [Line.pointSlope] for an infinite line at a point with a slope.
abstract final class Line {
  /// Creates a line segment between two points.
  ///
  /// Example:
  /// ```dart
  /// Line.segment(
  ///   point1: Offset(0, 0),
  ///   point2: Offset(2, 3),
  ///   color: MafsColors.blue,
  /// )
  /// ```
  static Widget segment({
    Key? key,
    required Offset point1,
    required Offset point2,
    Color? color,
    double opacity = 1.0,
    double weight = 2,
    StrokeStyle style = StrokeStyle.solid,
  }) {
    return LineSegment(
      key: key,
      point1: point1,
      point2: point2,
      color: color,
      opacity: opacity,
      weight: weight,
      style: style,
    );
  }

  /// Creates an infinite line passing through two points.
  ///
  /// The line extends to the edges of the visible viewport.
  ///
  /// Example:
  /// ```dart
  /// Line.throughPoints(
  ///   point1: Offset(0, 0),
  ///   point2: Offset(1, 1),
  ///   color: MafsColors.red,
  /// )
  /// ```
  static Widget throughPoints({
    Key? key,
    required Offset point1,
    required Offset point2,
    Color? color,
    double opacity = 1.0,
    double weight = 2,
    StrokeStyle style = StrokeStyle.solid,
  }) {
    return LineThroughPoints(
      key: key,
      point1: point1,
      point2: point2,
      color: color,
      opacity: opacity,
      weight: weight,
      style: style,
    );
  }

  /// Creates an infinite line at a point with a given angle.
  ///
  /// The [angle] is in radians, measured counter-clockwise from the positive x-axis.
  ///
  /// Example:
  /// ```dart
  /// Line.pointAngle(
  ///   point: Offset(0, 0),
  ///   angle: math.pi / 4, // 45 degrees
  ///   color: MafsColors.green,
  /// )
  /// ```
  static Widget pointAngle({
    Key? key,
    required Offset point,
    required double angle,
    Color? color,
    double opacity = 1.0,
    double weight = 2,
    StrokeStyle style = StrokeStyle.solid,
  }) {
    return LinePointAngle(
      key: key,
      point: point,
      angle: angle,
      color: color,
      opacity: opacity,
      weight: weight,
      style: style,
    );
  }

  /// Creates an infinite line at a point with a given slope.
  ///
  /// The [slope] is the rise over run (dy/dx).
  ///
  /// Example:
  /// ```dart
  /// Line.pointSlope(
  ///   point: Offset(0, 1),
  ///   slope: 2, // y = 2x + 1
  ///   color: MafsColors.violet,
  /// )
  /// ```
  static Widget pointSlope({
    Key? key,
    required Offset point,
    required double slope,
    Color? color,
    double opacity = 1.0,
    double weight = 2,
    StrokeStyle style = StrokeStyle.solid,
  }) {
    return LinePointSlope(
      key: key,
      point: point,
      slope: slope,
      color: color,
      opacity: opacity,
      weight: weight,
      style: style,
    );
  }
}

/// A line segment between two points.
///
/// This widget renders a straight line from [point1] to [point2].
/// For an infinite line, use [LineThroughPoints] instead.
class LineSegment extends LeafRenderObjectWidget {
  /// Creates a line segment between two points.
  const LineSegment({
    super.key,
    required this.point1,
    required this.point2,
    this.color,
    this.opacity = 1.0,
    this.weight = 2,
    this.style = StrokeStyle.solid,
  }) : assert(opacity >= 0.0 && opacity <= 1.0);

  /// The starting point of the line segment in math coordinates.
  final Offset point1;

  /// The ending point of the line segment in math coordinates.
  final Offset point2;

  /// The stroke color.
  ///
  /// If null, uses [MafsThemeData.foreground] from the nearest [MafsTheme].
  final Color? color;

  /// The opacity of the line (0.0 to 1.0).
  final double opacity;

  /// The stroke weight in pixels.
  final double weight;

  /// The stroke style (solid or dashed).
  final StrokeStyle style;

  @override
  RenderObject createRenderObject(BuildContext context) {
    final transformData = TransformContext.of(context);
    final coordData = CoordinateContext.of(context);

    return RenderLineSegment(
      point1: point1,
      point2: point2,
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
  void updateRenderObject(BuildContext context, RenderLineSegment renderObject) {
    final transformData = TransformContext.of(context);
    final coordData = CoordinateContext.of(context);

    renderObject
      ..point1 = point1
      ..point2 = point2
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

/// The render object for [LineSegment].
class RenderLineSegment extends RenderBox {
  /// Creates a render object for a line segment.
  RenderLineSegment({
    required Offset point1,
    required Offset point2,
    required Color color,
    required double opacity,
    required double weight,
    required StrokeStyle style,
    required Matrix2D userTransform,
    required double xMin,
    required double xMax,
    required double yMin,
    required double yMax,
  })  : _point1 = point1,
        _point2 = point2,
        _color = color,
        _opacity = opacity,
        _weight = weight,
        _style = style,
        _userTransform = userTransform,
        _xMin = xMin,
        _xMax = xMax,
        _yMin = yMin,
        _yMax = yMax;

  Offset _point1;
  Offset get point1 => _point1;
  set point1(Offset value) {
    if (_point1 == value) return;
    _point1 = value;
    markNeedsPaint();
  }

  Offset _point2;
  Offset get point2 => _point2;
  set point2(Offset value) {
    if (_point2 == value) return;
    _point2 = value;
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
    final transformedPoint1 = _point1.transform(_userTransform);
    final transformedPoint2 = _point2.transform(_userTransform);

    // Convert to screen coordinates
    final screenPoint1 = _mathToScreen(transformedPoint1) + offset;
    final screenPoint2 = _mathToScreen(transformedPoint2) + offset;

    // Create paint
    final paint = Paint()
      ..color = _color.withValues(alpha: _color.a * _opacity)
      ..strokeWidth = _weight
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (_style == StrokeStyle.dashed) {
      _drawDashedLine(canvas, screenPoint1, screenPoint2, paint);
    } else {
      canvas.drawLine(screenPoint1, screenPoint2, paint);
    }
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

/// An infinite line passing through two points.
///
/// The line extends to the edges of the visible viewport.
class LineThroughPoints extends LeafRenderObjectWidget {
  /// Creates an infinite line passing through two points.
  const LineThroughPoints({
    super.key,
    required this.point1,
    required this.point2,
    this.color,
    this.opacity = 1.0,
    this.weight = 2,
    this.style = StrokeStyle.solid,
  }) : assert(opacity >= 0.0 && opacity <= 1.0);

  /// The first point the line passes through in math coordinates.
  final Offset point1;

  /// The second point the line passes through in math coordinates.
  final Offset point2;

  /// The stroke color.
  ///
  /// If null, uses [MafsThemeData.foreground] from the nearest [MafsTheme].
  final Color? color;

  /// The opacity of the line (0.0 to 1.0).
  final double opacity;

  /// The stroke weight in pixels.
  final double weight;

  /// The stroke style (solid or dashed).
  final StrokeStyle style;

  @override
  RenderObject createRenderObject(BuildContext context) {
    final transformData = TransformContext.of(context);
    final coordData = CoordinateContext.of(context);

    return RenderLineThroughPoints(
      point1: point1,
      point2: point2,
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
  void updateRenderObject(BuildContext context, RenderLineThroughPoints renderObject) {
    final transformData = TransformContext.of(context);
    final coordData = CoordinateContext.of(context);

    renderObject
      ..point1 = point1
      ..point2 = point2
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

/// The render object for [LineThroughPoints].
class RenderLineThroughPoints extends RenderBox {
  /// Creates a render object for an infinite line through two points.
  RenderLineThroughPoints({
    required Offset point1,
    required Offset point2,
    required Color color,
    required double opacity,
    required double weight,
    required StrokeStyle style,
    required Matrix2D userTransform,
    required double xMin,
    required double xMax,
    required double yMin,
    required double yMax,
  })  : _point1 = point1,
        _point2 = point2,
        _color = color,
        _opacity = opacity,
        _weight = weight,
        _style = style,
        _userTransform = userTransform,
        _xMin = xMin,
        _xMax = xMax,
        _yMin = yMin,
        _yMax = yMax;

  Offset _point1;
  Offset get point1 => _point1;
  set point1(Offset value) {
    if (_point1 == value) return;
    _point1 = value;
    markNeedsPaint();
  }

  Offset _point2;
  Offset get point2 => _point2;
  set point2(Offset value) {
    if (_point2 == value) return;
    _point2 = value;
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
    final tPoint1 = _point1.transform(_userTransform);
    final tPoint2 = _point2.transform(_userTransform);

    // Calculate slope
    final dx = tPoint2.dx - tPoint1.dx;
    final dy = tPoint2.dy - tPoint1.dy;

    Offset offscreen1;
    Offset offscreen2;

    if (dx.abs() < 1e-10) {
      // Vertical line
      offscreen1 = Offset(tPoint1.dx, _yMin);
      offscreen2 = Offset(tPoint1.dx, _yMax);
    } else {
      final slope = dy / dx;

      // Choose whether to extend to x bounds or y bounds based on slope
      // This ensures the line endpoints are actually off-screen
      if (slope.abs() > 1) {
        // Steeper line - extend to y bounds
        offscreen1 = Offset(
          (_yMin - tPoint1.dy) / slope + tPoint1.dx,
          _yMin,
        );
        offscreen2 = Offset(
          (_yMax - tPoint1.dy) / slope + tPoint1.dx,
          _yMax,
        );
      } else {
        // Shallower line - extend to x bounds
        offscreen1 = Offset(
          _xMin,
          slope * (_xMin - tPoint1.dx) + tPoint1.dy,
        );
        offscreen2 = Offset(
          _xMax,
          slope * (_xMax - tPoint1.dx) + tPoint1.dy,
        );
      }
    }

    // Convert to screen coordinates
    final screenPoint1 = _mathToScreen(offscreen1) + offset;
    final screenPoint2 = _mathToScreen(offscreen2) + offset;

    // Create paint
    final paint = Paint()
      ..color = _color.withValues(alpha: _color.a * _opacity)
      ..strokeWidth = _weight
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (_style == StrokeStyle.dashed) {
      _drawDashedLine(canvas, screenPoint1, screenPoint2, paint);
    } else {
      canvas.drawLine(screenPoint1, screenPoint2, paint);
    }
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

/// An infinite line at a point with a given angle.
///
/// This is a convenience wrapper around [LineThroughPoints].
class LinePointAngle extends StatelessWidget {
  /// Creates an infinite line at a point with a given angle.
  const LinePointAngle({
    super.key,
    required this.point,
    required this.angle,
    this.color,
    this.opacity = 1.0,
    this.weight = 2,
    this.style = StrokeStyle.solid,
  }) : assert(opacity >= 0.0 && opacity <= 1.0);

  /// The point the line passes through in math coordinates.
  final Offset point;

  /// The angle of the line in radians, measured counter-clockwise from the positive x-axis.
  final double angle;

  /// The stroke color.
  ///
  /// If null, uses [MafsThemeData.foreground] from the nearest [MafsTheme].
  final Color? color;

  /// The opacity of the line (0.0 to 1.0).
  final double opacity;

  /// The stroke weight in pixels.
  final double weight;

  /// The stroke style (solid or dashed).
  final StrokeStyle style;

  @override
  Widget build(BuildContext context) {
    // Create a second point by rotating (1, 0) by the angle and adding to point
    final direction = const Offset(1, 0).rotate(angle);
    final point2 = point + direction;

    return LineThroughPoints(
      point1: point,
      point2: point2,
      color: color,
      opacity: opacity,
      weight: weight,
      style: style,
    );
  }
}

/// An infinite line at a point with a given slope.
///
/// This is a convenience wrapper around [LinePointAngle].
class LinePointSlope extends StatelessWidget {
  /// Creates an infinite line at a point with a given slope.
  const LinePointSlope({
    super.key,
    required this.point,
    required this.slope,
    this.color,
    this.opacity = 1.0,
    this.weight = 2,
    this.style = StrokeStyle.solid,
  }) : assert(opacity >= 0.0 && opacity <= 1.0);

  /// The point the line passes through in math coordinates.
  final Offset point;

  /// The slope of the line (rise over run, dy/dx).
  final double slope;

  /// The stroke color.
  ///
  /// If null, uses [MafsThemeData.foreground] from the nearest [MafsTheme].
  final Color? color;

  /// The opacity of the line (0.0 to 1.0).
  final double opacity;

  /// The stroke weight in pixels.
  final double weight;

  /// The stroke style (solid or dashed).
  final StrokeStyle style;

  @override
  Widget build(BuildContext context) {
    return LinePointAngle(
      point: point,
      angle: math.atan(slope),
      color: color,
      opacity: opacity,
      weight: weight,
      style: style,
    );
  }
}
