import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../context/coordinate_context.dart';
import '../../context/pane_context.dart';
import '../../context/transform_context.dart';
import '../../math.dart' as mafs_math;
import '../../vec.dart';
import '../theme.dart';
import 'cartesian.dart';

/// A polar coordinate system with concentric circles and radial lines.
///
/// This widget renders a polar coordinate system with:
/// - Concentric circles at configurable radius intervals
/// - Radial lines emanating from the origin
/// - X and Y axis lines through the origin
/// - Optional numeric labels along each axis
///
/// ## Example
///
/// ```dart
/// Mafs(
///   children: [
///     // Default polar coordinates
///     PolarCoordinates(),
///
///     // With custom options
///     PolarCoordinates(
///       lines: 2,
///       subdivisions: 4,
///     ),
///   ],
/// )
/// ```
class PolarCoordinates extends LeafRenderObjectWidget {
  /// Creates a polar coordinate system.
  const PolarCoordinates({
    super.key,
    this.xAxis = const AxisOptions(),
    this.yAxis = const AxisOptions(),
    this.lines = 1,
    this.subdivisions,
  });

  /// Configuration for the x-axis.
  ///
  /// Set to `null` to disable the x-axis entirely.
  final AxisOptions? xAxis;

  /// Configuration for the y-axis.
  ///
  /// Set to `null` to disable the y-axis entirely.
  final AxisOptions? yAxis;

  /// The spacing between concentric circles.
  final double lines;

  /// Number of subdivisions between major circles.
  final int? subdivisions;

  @override
  RenderPolarCoordinates createRenderObject(BuildContext context) {
    final theme = MafsTheme.of(context);
    final coordData = CoordinateContext.of(context);
    final transformData = TransformContext.of(context);
    final paneData = PaneContext.of(context);

    return RenderPolarCoordinates(
      xAxis: xAxis,
      yAxis: yAxis,
      lines: lines,
      subdivisions: subdivisions,
      theme: theme,
      xMin: coordData.xMin,
      xMax: coordData.xMax,
      yMin: coordData.yMin,
      yMax: coordData.yMax,
      viewTransform: transformData.viewTransform,
      xPanes: paneData.xPanes,
      yPanes: paneData.yPanes,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderPolarCoordinates renderObject,
  ) {
    final theme = MafsTheme.of(context);
    final coordData = CoordinateContext.of(context);
    final transformData = TransformContext.of(context);
    final paneData = PaneContext.of(context);

    renderObject
      ..xAxis = xAxis
      ..yAxis = yAxis
      ..lines = lines
      ..subdivisions = subdivisions
      ..theme = theme
      ..xMin = coordData.xMin
      ..xMax = coordData.xMax
      ..yMin = coordData.yMin
      ..yMax = coordData.yMax
      ..viewTransform = transformData.viewTransform
      ..xPanes = paneData.xPanes
      ..yPanes = paneData.yPanes;
  }
}

/// Render object for [PolarCoordinates].
class RenderPolarCoordinates extends RenderBox {
  /// Creates a render object for polar coordinates.
  RenderPolarCoordinates({
    required AxisOptions? xAxis,
    required AxisOptions? yAxis,
    required double lines,
    required int? subdivisions,
    required MafsThemeData theme,
    required double xMin,
    required double xMax,
    required double yMin,
    required double yMax,
    required Matrix2D viewTransform,
    required List<mafs_math.Interval> xPanes,
    required List<mafs_math.Interval> yPanes,
  })  : _xAxis = xAxis,
        _yAxis = yAxis,
        _lines = lines,
        _subdivisions = subdivisions,
        _theme = theme,
        _xMin = xMin,
        _xMax = xMax,
        _yMin = yMin,
        _yMax = yMax,
        _viewTransform = viewTransform,
        _xPanes = xPanes,
        _yPanes = yPanes;

  // Radial lines every 15 degrees (π/12)
  static final List<double> _thetas = mafs_math.range(0, 2 * math.pi, math.pi / 12);

  AxisOptions? _xAxis;
  AxisOptions? get xAxis => _xAxis;
  set xAxis(AxisOptions? value) {
    if (_xAxis == value) return;
    _xAxis = value;
    markNeedsPaint();
  }

  AxisOptions? _yAxis;
  AxisOptions? get yAxis => _yAxis;
  set yAxis(AxisOptions? value) {
    if (_yAxis == value) return;
    _yAxis = value;
    markNeedsPaint();
  }

  double _lines;
  double get lines => _lines;
  set lines(double value) {
    if (_lines == value) return;
    _lines = value;
    markNeedsPaint();
  }

  int? _subdivisions;
  int? get subdivisions => _subdivisions;
  set subdivisions(int? value) {
    if (_subdivisions == value) return;
    _subdivisions = value;
    markNeedsPaint();
  }

  MafsThemeData _theme;
  MafsThemeData get theme => _theme;
  set theme(MafsThemeData value) {
    if (_theme == value) return;
    _theme = value;
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

  Matrix2D _viewTransform;
  Matrix2D get viewTransform => _viewTransform;
  set viewTransform(Matrix2D value) {
    if (_viewTransform == value) return;
    _viewTransform = value;
    markNeedsPaint();
  }

  List<mafs_math.Interval> _xPanes;
  List<mafs_math.Interval> get xPanes => _xPanes;
  set xPanes(List<mafs_math.Interval> value) {
    if (_xPanes == value) return;
    _xPanes = value;
    markNeedsPaint();
  }

  List<mafs_math.Interval> _yPanes;
  List<mafs_math.Interval> get yPanes => _yPanes;
  set yPanes(List<mafs_math.Interval> value) {
    if (_yPanes == value) return;
    _yPanes = value;
    markNeedsPaint();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void performResize() {
    size = computeDryLayout(constraints);
  }

  Offset _mathToScreen(double x, double y) {
    final xSpan = _xMax - _xMin;
    final ySpan = _yMax - _yMin;
    final screenX = (x - _xMin) / xSpan * size.width;
    final screenY = (1 - (y - _yMin) / ySpan) * size.height;
    return Offset(screenX, screenY);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    // Calculate visible radius range
    final cornerDistances = [
      _distance(_xMin, _yMin),
      _distance(_xMin, _yMax),
      _distance(_xMax, _yMin),
      _distance(_xMax, _yMax),
      _distance((_xMin + _xMax) / 2, (_yMin + _yMax) / 2),
    ];

    final maxViewDimension = math.max(_xMax - _xMin, _yMax - _yMin);
    final closeToOrigin = cornerDistances.reduce(math.min) < maxViewDimension;
    final minRadiusPrecise = closeToOrigin ? 0.0 : cornerDistances.reduce(math.min);
    final maxRadiusPrecise = cornerDistances.reduce(math.max);

    final minRadius = (minRadiusPrecise / _lines).floor() * _lines;
    final maxRadius = (maxRadiusPrecise / _lines).ceil() * _lines;

    // Draw radial lines
    _paintRadialLines(canvas, maxRadius);

    // Draw subdivision circles
    _paintSubdivisionCircles(canvas, minRadius, maxRadius);

    // Draw major circles
    _paintMajorCircles(canvas, minRadius, maxRadius);

    // Draw axes
    _paintAxes(canvas);

    // Draw labels
    _paintLabels(canvas);

    canvas.restore();
  }

  double _distance(double x, double y) {
    return math.sqrt(x * x + y * y);
  }

  void _paintRadialLines(Canvas canvas, double maxRadius) {
    final paint = Paint()
      ..color = _theme.effectiveGridColor.withValues(alpha: 0.5)
      ..strokeWidth = 0.5;

    final origin = _mathToScreen(0, 0);

    for (final theta in _thetas) {
      final endX = math.cos(theta) * maxRadius;
      final endY = math.sin(theta) * maxRadius;
      final endPoint = _mathToScreen(endX, endY);

      canvas.drawLine(origin, endPoint, paint);
    }
  }

  void _paintSubdivisionCircles(Canvas canvas, double minRadius, double maxRadius) {
    if (_subdivisions == null || _subdivisions! <= 1) return;

    final paint = Paint()
      ..color = _theme.effectiveGridColor.withValues(alpha: 0.5)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final origin = _mathToScreen(0, 0);
    final xSpan = _xMax - _xMin;
    final ySpan = _yMax - _yMin;
    final scaleX = size.width / xSpan;
    final scaleY = size.height / ySpan;

    final subStep = _lines / _subdivisions!;
    for (final r in mafs_math.range(minRadius, maxRadius, subStep)) {
      // Skip major circles
      if ((r / _lines - (r / _lines).round()).abs() < 1e-9) continue;
      if (r <= 0) continue;

      // Draw ellipse (circle scaled by viewport aspect ratio)
      final rect = Rect.fromCenter(
        center: origin,
        width: r * 2 * scaleX,
        height: r * 2 * scaleY,
      );
      canvas.drawOval(rect, paint);
    }
  }

  void _paintMajorCircles(Canvas canvas, double minRadius, double maxRadius) {
    final paint = Paint()
      ..color = _theme.effectiveGridColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final origin = _mathToScreen(0, 0);
    final xSpan = _xMax - _xMin;
    final ySpan = _yMax - _yMin;
    final scaleX = size.width / xSpan;
    final scaleY = size.height / ySpan;

    for (final r in mafs_math.range(minRadius, maxRadius, _lines)) {
      if (r <= 0) continue;

      // Draw ellipse (circle scaled by viewport aspect ratio)
      final rect = Rect.fromCenter(
        center: origin,
        width: r * 2 * scaleX,
        height: r * 2 * scaleY,
      );
      canvas.drawOval(rect, paint);
    }
  }

  void _paintAxes(Canvas canvas) {
    final paint = Paint()
      ..color = _theme.effectiveAxisColor
      ..strokeWidth = 2;

    // Draw X axis (y = 0)
    if (_xAxis?.axis == true && _yMin <= 0 && _yMax >= 0) {
      final screenY = _mathToScreen(0, 0).dy;
      canvas.drawLine(
        Offset(0, screenY),
        Offset(size.width, screenY),
        paint,
      );
    }

    // Draw Y axis (x = 0)
    if (_yAxis?.axis == true && _xMin <= 0 && _xMax >= 0) {
      final screenX = _mathToScreen(0, 0).dx;
      canvas.drawLine(
        Offset(screenX, 0),
        Offset(screenX, size.height),
        paint,
      );
    }
  }

  void _paintLabels(Canvas canvas) {
    final labelColor = _theme.effectiveLabelColor;
    final xLabels = _xAxis?.labels;
    final yLabels = _yAxis?.labels;
    final xLines = _xAxis?.lines ?? _lines;
    final yLines = _yAxis?.lines ?? _lines;

    // Paint X axis labels
    if (_xAxis != null && xLabels != null) {
      for (final (paneMin, paneMax) in _xPanes) {
        for (final x in _snappedRange(paneMin, paneMax, xLines)) {
          if (x.abs() < xLines / 1e6) continue;

          final screenPoint = _mathToScreen(x, 0);
          final label = xLabels(x);

          final textPainter = TextPainter(
            text: TextSpan(
              text: label,
              style: TextStyle(
                color: labelColor,
                fontSize: 12,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();

          final labelOffset = Offset(
            screenPoint.dx - textPainter.width / 2,
            _mathToScreen(0, 0).dy + 5,
          );

          if (labelOffset.dy > 0 && labelOffset.dy < size.height - textPainter.height) {
            textPainter.paint(canvas, labelOffset);
          }
        }
      }
    }

    // Paint Y axis labels
    if (_yAxis != null && yLabels != null) {
      for (final (paneMin, paneMax) in _yPanes) {
        for (final y in _snappedRange(paneMin, paneMax, yLines)) {
          if (y.abs() < yLines / 1e6) continue;

          final screenPoint = _mathToScreen(0, y);
          final label = yLabels(y);

          final textPainter = TextPainter(
            text: TextSpan(
              text: label,
              style: TextStyle(
                color: labelColor,
                fontSize: 12,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();

          final labelOffset = Offset(
            _mathToScreen(0, 0).dx + 5,
            screenPoint.dy - textPainter.height / 2,
          );

          if (labelOffset.dx > 0 && labelOffset.dx < size.width - textPainter.width) {
            textPainter.paint(canvas, labelOffset);
          }
        }
      }
    }
  }

  List<double> _snappedRange(double min, double max, double step) {
    final roundMin = (min / step).floor() * step;
    final roundMax = (max / step).ceil() * step;

    if (roundMin == roundMax - step) return [roundMin];
    return mafs_math.range(roundMin, roundMax - step, step);
  }
}
