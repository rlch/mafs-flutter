import 'package:flutter/widgets.dart';

import '../context/coordinate_context.dart';
import '../context/transform_context.dart';
import '../vec.dart';
import 'theme.dart';

/// A point displayed at a specific coordinate.
///
/// This widget displays a filled circle at the given (x, y) position in
/// math coordinates. The position is transformed using the current
/// [TransformContext] to map from math space to screen space.
///
/// Example:
/// ```dart
/// Mafs(
///   children: [
///     MafsPoint(x: 1, y: 2),
///     MafsPoint(x: -1, y: 1, color: Colors.red),
///   ],
/// )
/// ```
class MafsPoint extends LeafRenderObjectWidget {
  /// Creates a point at the specified coordinates.
  const MafsPoint({
    super.key,
    required this.x,
    required this.y,
    this.color,
    this.opacity = 1.0,
  }) : assert(opacity >= 0.0 && opacity <= 1.0);

  /// The x-coordinate in math space.
  final double x;

  /// The y-coordinate in math space.
  final double y;

  /// The fill color of the point.
  ///
  /// If null, uses [MafsThemeData.foreground] from the nearest [MafsTheme].
  final Color? color;

  /// The opacity of the point (0.0 to 1.0).
  ///
  /// Defaults to 1.0 (fully opaque).
  final double opacity;

  @override
  RenderMafsPoint createRenderObject(BuildContext context) {
    final transformData = TransformContext.of(context);
    final coordData = CoordinateContext.of(context);

    return RenderMafsPoint(
      x: x,
      y: y,
      color: color ?? MafsTheme.of(context).foreground,
      opacity: opacity,
      userTransform: transformData.userTransform,
      xMin: coordData.xMin,
      xMax: coordData.xMax,
      yMin: coordData.yMin,
      yMax: coordData.yMax,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderMafsPoint renderObject) {
    final transformData = TransformContext.of(context);
    final coordData = CoordinateContext.of(context);

    renderObject
      ..x = x
      ..y = y
      ..color = color ?? MafsTheme.of(context).foreground
      ..opacity = opacity
      ..userTransform = transformData.userTransform
      ..xMin = coordData.xMin
      ..xMax = coordData.xMax
      ..yMin = coordData.yMin
      ..yMax = coordData.yMax;
  }
}

/// The render object for [MafsPoint].
///
/// Paints a filled circle at the transformed position.
class RenderMafsPoint extends RenderBox {
  /// Creates a render object for painting a point.
  RenderMafsPoint({
    required double x,
    required double y,
    required Color color,
    required double opacity,
    required Matrix2D userTransform,
    required double xMin,
    required double xMax,
    required double yMin,
    required double yMax,
  })  : _x = x,
        _y = y,
        _color = color,
        _opacity = opacity,
        _userTransform = userTransform,
        _xMin = xMin,
        _xMax = xMax,
        _yMin = yMin,
        _yMax = yMax;

  /// The radius of the point in pixels.
  static const double pointRadius = 6.0;

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

  Color _color;
  /// The fill color.
  Color get color => _color;
  set color(Color value) {
    if (_color == value) return;
    _color = value;
    markNeedsPaint();
  }

  double _opacity;
  /// The opacity (0.0 to 1.0).
  double get opacity => _opacity;
  set opacity(double value) {
    if (_opacity == value) return;
    _opacity = value;
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

  @override
  void paint(PaintingContext context, Offset offset) {
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
    // Same formula as grid: screenX = (x - xMin) / xSpan * width
    final screenX = (userTransformedPoint.dx - _xMin) / xSpan * width + offset.dx;
    final screenY = (1 - (userTransformedPoint.dy - _yMin) / ySpan) * height + offset.dy;
    final screenPoint = Offset(screenX, screenY);

    // Create paint with fill color and opacity
    final paint = Paint()
      ..color = _color.withValues(alpha: _color.a * _opacity)
      ..style = PaintingStyle.fill;

    // Draw the circle at the transformed position
    canvas.drawCircle(screenPoint, pointRadius, paint);
  }

  @override
  bool hitTestSelf(Offset position) {
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
    final screenPoint = Offset(screenX, screenY);

    // Check if the position is within the point radius
    return (position - screenPoint).distance <= pointRadius;
  }
}
