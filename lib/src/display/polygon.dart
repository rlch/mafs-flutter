import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../context/coordinate_context.dart';
import '../context/transform_context.dart';
import '../vec.dart';
import 'theme.dart';

/// A widget that renders a closed polygon in the Mafs coordinate system.
///
/// The polygon is defined by a list of [points] representing vertices
/// in math coordinates. The shape is automatically closed by connecting
/// the last point back to the first.
///
/// Example:
/// ```dart
/// MafsPolygon(
///   points: [
///     Offset(0, 0),
///     Offset(2, 0),
///     Offset(1, 2),
///   ],
///   color: MafsColors.blue,
///   fillOpacity: 0.3,
/// )
/// ```
class MafsPolygon extends LeafRenderObjectWidget {
  /// Creates a Mafs polygon widget.
  ///
  /// The [points] list must contain at least 3 points to form a valid polygon.
  const MafsPolygon({
    super.key,
    required this.points,
    this.color,
    this.weight = 2,
    this.fillOpacity = 0.15,
    this.strokeOpacity = 1.0,
    this.strokeStyle = StrokeStyle.solid,
  });

  /// The vertices of the polygon in math coordinates.
  final List<Offset> points;

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

    return RenderMafsPolygon(
      points: points,
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
  void updateRenderObject(BuildContext context, RenderMafsPolygon renderObject) {
    final theme = MafsTheme.of(context);
    final transformData = TransformContext.of(context);
    final coordData = CoordinateContext.of(context);

    renderObject
      ..points = points
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

/// A widget that renders an open polyline in the Mafs coordinate system.
///
/// The polyline is defined by a list of [points] representing vertices
/// in math coordinates. Unlike [MafsPolygon], the shape is not closed.
///
/// By default, the polyline has no fill (fillOpacity = 0).
///
/// Example:
/// ```dart
/// MafsPolyline(
///   points: [
///     Offset(0, 0),
///     Offset(1, 2),
///     Offset(2, 1),
///     Offset(3, 3),
///   ],
///   color: MafsColors.green,
///   weight: 3,
/// )
/// ```
class MafsPolyline extends LeafRenderObjectWidget {
  /// Creates a Mafs polyline widget.
  ///
  /// The [points] list must contain at least 2 points to form a valid polyline.
  const MafsPolyline({
    super.key,
    required this.points,
    this.color,
    this.weight = 2,
    this.fillOpacity = 0,
    this.strokeOpacity = 1.0,
    this.strokeStyle = StrokeStyle.solid,
  });

  /// The vertices of the polyline in math coordinates.
  final List<Offset> points;

  /// The color for fill and stroke.
  ///
  /// If null, uses the theme's foreground color.
  final Color? color;

  /// The stroke weight in pixels.
  final double weight;

  /// The fill opacity (0.0 to 1.0).
  ///
  /// Defaults to 0 (no fill) for polylines.
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

    return RenderMafsPolyline(
      points: points,
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
  void updateRenderObject(BuildContext context, RenderMafsPolyline renderObject) {
    final theme = MafsTheme.of(context);
    final transformData = TransformContext.of(context);
    final coordData = CoordinateContext.of(context);

    renderObject
      ..points = points
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

/// Base render object for polygon and polyline rendering.
///
/// This class contains all the shared logic for coordinate transformation,
/// path building, and drawing with fill/stroke styling.
abstract class RenderMafsPolyBase extends RenderBox {
  /// Creates a base render object for polygon/polyline.
  RenderMafsPolyBase({
    required List<Offset> points,
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
  })  : _points = points,
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

  List<Offset> _points;
  List<Offset> get points => _points;
  set points(List<Offset> value) {
    if (listEquals(_points, value)) return;
    _points = value;
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

  /// Whether the path should be closed (polygon) or open (polyline).
  bool get closePath;

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
    if (_points.isEmpty) return;

    final canvas = context.canvas;

    // Transform all points and convert to screen coordinates
    final screenPoints = _points.map((point) {
      final transformed = point.transform(_userTransform);
      return _mathToScreen(transformed) + offset;
    }).toList();

    // Build the path
    final path = Path();
    path.moveTo(screenPoints[0].dx, screenPoints[0].dy);

    for (var i = 1; i < screenPoints.length; i++) {
      path.lineTo(screenPoints[i].dx, screenPoints[i].dy);
    }

    if (closePath) {
      path.close();
    }

    // Draw fill
    if (_fillOpacity > 0) {
      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = _color.withValues(alpha: _fillOpacity);
      canvas.drawPath(path, fillPaint);
    }

    // Draw stroke
    if (_strokeOpacity > 0 && _weight > 0) {
      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _weight
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..color = _color.withValues(alpha: _strokeOpacity);

      if (_strokeStyle == StrokeStyle.dashed) {
        _drawDashedPath(canvas, path, strokePaint);
      } else {
        canvas.drawPath(path, strokePaint);
      }
    }
  }

  /// Draws a dashed path using path metrics.
  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
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

/// The render object for [MafsPolygon].
///
/// Renders a closed polygon with fill and stroke.
class RenderMafsPolygon extends RenderMafsPolyBase {
  /// Creates a render object for a Mafs polygon.
  RenderMafsPolygon({
    required super.points,
    required super.color,
    required super.weight,
    required super.fillOpacity,
    required super.strokeOpacity,
    required super.strokeStyle,
    required super.userTransform,
    required super.xMin,
    required super.xMax,
    required super.yMin,
    required super.yMax,
  });

  @override
  bool get closePath => true;
}

/// The render object for [MafsPolyline].
///
/// Renders an open polyline with optional fill and stroke.
class RenderMafsPolyline extends RenderMafsPolyBase {
  /// Creates a render object for a Mafs polyline.
  RenderMafsPolyline({
    required super.points,
    required super.color,
    required super.weight,
    required super.fillOpacity,
    required super.strokeOpacity,
    required super.strokeStyle,
    required super.userTransform,
    required super.xMin,
    required super.xMax,
    required super.yMin,
    required super.yMax,
  });

  @override
  bool get closePath => false;
}
