import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../context/coordinate_context.dart';
import '../context/transform_context.dart';
import '../vec.dart';
import 'theme.dart';

/// A widget that renders an ellipse in the Mafs coordinate system.
///
/// The ellipse is defined by its [center], [radius] (as x and y radii),
/// and an optional rotation [angle].
///
/// Example:
/// ```dart
/// MafsEllipse(
///   center: const Offset(0, 0),
///   radius: const Offset(2, 1),
///   angle: math.pi / 4, // 45 degrees rotation
///   color: MafsColors.blue,
/// )
/// ```
class MafsEllipse extends LeafRenderObjectWidget {
  /// Creates a Mafs ellipse widget.
  ///
  /// The [center] specifies the center point in math coordinates.
  /// The [radius] specifies the x and y radii (dx = rx, dy = ry).
  /// The [angle] specifies the rotation in radians (default: 0).
  const MafsEllipse({
    super.key,
    required this.center,
    required this.radius,
    this.angle = 0,
    this.color,
    this.weight = 2,
    this.fillOpacity = 0.15,
    this.strokeOpacity = 1.0,
    this.strokeStyle = StrokeStyle.solid,
  });

  /// The center point of the ellipse in math coordinates.
  final Offset center;

  /// The radii of the ellipse (dx = x-radius, dy = y-radius) in math units.
  final Offset radius;

  /// The rotation angle in radians.
  final double angle;

  /// The color for fill and stroke.
  ///
  /// If null, uses the theme's foreground color.
  final Color? color;

  /// The stroke weight in pixels.
  final double weight;

  /// The fill opacity (0.0 to 1.0).
  final double fillOpacity;

  /// The stroke opacity (0.0 to 1.0).
  final double strokeOpacity;

  /// The stroke style (solid or dashed).
  final StrokeStyle strokeStyle;

  @override
  RenderObject createRenderObject(BuildContext context) {
    final theme = MafsTheme.of(context);
    final transformData = TransformContext.of(context);
    final coordData = CoordinateContext.of(context);

    return RenderMafsEllipse(
      center: center,
      radius: radius,
      angle: angle,
      color: color ?? theme.foreground,
      weight: weight,
      fillOpacity: fillOpacity,
      strokeOpacity: strokeOpacity,
      strokeStyle: strokeStyle,
      userTransform: transformData.userTransform,
      xMin: coordData.xMin,
      xMax: coordData.xMax,
      yMin: coordData.yMin,
      yMax: coordData.yMax,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderMafsEllipse renderObject) {
    final theme = MafsTheme.of(context);
    final transformData = TransformContext.of(context);
    final coordData = CoordinateContext.of(context);

    renderObject
      ..center = center
      ..radius = radius
      ..angle = angle
      ..color = color ?? theme.foreground
      ..weight = weight
      ..fillOpacity = fillOpacity
      ..strokeOpacity = strokeOpacity
      ..strokeStyle = strokeStyle
      ..userTransform = transformData.userTransform
      ..xMin = coordData.xMin
      ..xMax = coordData.xMax
      ..yMin = coordData.yMin
      ..yMax = coordData.yMax;
  }
}

/// The render object for [MafsEllipse].
class RenderMafsEllipse extends RenderBox {
  /// Creates a render object for a Mafs ellipse.
  RenderMafsEllipse({
    required Offset center,
    required Offset radius,
    required double angle,
    required Color color,
    required double weight,
    required double fillOpacity,
    required double strokeOpacity,
    required StrokeStyle strokeStyle,
    required Matrix2D userTransform,
    required double xMin,
    required double xMax,
    required double yMin,
    required double yMax,
  })  : _center = center,
        _radius = radius,
        _angle = angle,
        _color = color,
        _weight = weight,
        _fillOpacity = fillOpacity,
        _strokeOpacity = strokeOpacity,
        _strokeStyle = strokeStyle,
        _userTransform = userTransform,
        _xMin = xMin,
        _xMax = xMax,
        _yMin = yMin,
        _yMax = yMax;

  Offset _center;
  Offset get center => _center;
  set center(Offset value) {
    if (_center == value) return;
    _center = value;
    markNeedsPaint();
  }

  Offset _radius;
  Offset get radius => _radius;
  set radius(Offset value) {
    if (_radius == value) return;
    _radius = value;
    markNeedsPaint();
  }

  double _angle;
  double get angle => _angle;
  set angle(double value) {
    if (_angle == value) return;
    _angle = value;
    markNeedsPaint();
  }

  Color _color;
  Color get color => _color;
  set color(Color value) {
    if (_color == value) return;
    _color = value;
    markNeedsPaint();
  }

  double _weight;
  double get weight => _weight;
  set weight(double value) {
    if (_weight == value) return;
    _weight = value;
    markNeedsPaint();
  }

  double _fillOpacity;
  double get fillOpacity => _fillOpacity;
  set fillOpacity(double value) {
    if (_fillOpacity == value) return;
    _fillOpacity = value;
    markNeedsPaint();
  }

  double _strokeOpacity;
  double get strokeOpacity => _strokeOpacity;
  set strokeOpacity(double value) {
    if (_strokeOpacity == value) return;
    _strokeOpacity = value;
    markNeedsPaint();
  }

  StrokeStyle _strokeStyle;
  StrokeStyle get strokeStyle => _strokeStyle;
  set strokeStyle(StrokeStyle value) {
    if (_strokeStyle == value) return;
    _strokeStyle = value;
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

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    // Use our laid-out size for calculations
    final width = size.width;
    final height = size.height;

    // Calculate spans from coordinate bounds
    final xSpan = _xMax - _xMin;
    final ySpan = _yMax - _yMin;

    // Calculate pixel-space radii
    final pixelRadiusX = _radius.dx / xSpan * width;
    final pixelRadiusY = _radius.dy / ySpan * height;

    // Apply userTransform to the center (for nested transforms)
    final userTransformedCenter = _center.transform(_userTransform);

    // Calculate center position in screen coordinates
    // Same formula as grid
    final finalCenterX = (userTransformedCenter.dx - _xMin) / xSpan * width + offset.dx;
    final finalCenterY = (1 - (userTransformedCenter.dy - _yMin) / ySpan) * height + offset.dy;
    final finalPixelCenter = Offset(finalCenterX, finalCenterY);

    // Save canvas state for rotation
    canvas.save();

    // Translate to center, rotate, then draw
    canvas.translate(finalPixelCenter.dx, finalPixelCenter.dy);
    canvas.rotate(-_angle); // Negative because screen Y is inverted

    // Create the ellipse rect centered at origin
    final ellipseRect = Rect.fromCenter(
      center: Offset.zero,
      width: pixelRadiusX * 2,
      height: pixelRadiusY * 2,
    );

    // Draw fill
    if (_fillOpacity > 0) {
      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = _color.withValues(alpha: _fillOpacity);
      canvas.drawOval(ellipseRect, fillPaint);
    }

    // Draw stroke
    if (_strokeOpacity > 0 && _weight > 0) {
      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _weight
        ..color = _color.withValues(alpha: _strokeOpacity);

      if (_strokeStyle == StrokeStyle.dashed) {
        _drawDashedOval(canvas, ellipseRect, strokePaint);
      } else {
        canvas.drawOval(ellipseRect, strokePaint);
      }
    }

    // Restore canvas state
    canvas.restore();
  }

  /// Draws a dashed oval using path metrics.
  void _drawDashedOval(Canvas canvas, Rect rect, Paint paint) {
    final path = Path()..addOval(rect);
    final metrics = path.computeMetrics();

    const dashLength = 8.0;
    const gapLength = 4.0;

    for (final metric in metrics) {
      var distance = 0.0;
      var draw = true;

      while (distance < metric.length) {
        final length = draw ? dashLength : gapLength;
        final nextDistance = math.min(distance + length, metric.length);

        if (draw) {
          final extractedPath = metric.extractPath(distance, nextDistance);
          canvas.drawPath(extractedPath, paint);
        }

        distance = nextDistance;
        draw = !draw;
      }
    }
  }

  @override
  bool hitTestSelf(Offset position) => false;
}
