import 'package:flutter/widgets.dart';

import '../../context/coordinate_context.dart';
import '../../context/pane_context.dart';
import '../../context/span_context.dart';
import '../../context/transform_context.dart';
import '../../math.dart' as mafs_math;
import '../../vec.dart';
import '../theme.dart';
import 'polar.dart';

/// Function that creates a label string from a numeric value.
typedef LabelMaker = String Function(double value);

/// Default label maker that formats numbers nicely.
String defaultLabelMaker(double value) {
  // Remove trailing zeros and unnecessary decimal point
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toString();
}

/// Configuration options for an axis.
@immutable
class AxisOptions {
  /// Creates axis options.
  const AxisOptions({
    this.axis = true,
    this.lines = 1.0,
    this.labels = defaultLabelMaker,
    this.subdivisions,
  });

  /// Whether to show the axis line (at x=0 or y=0).
  final bool axis;

  /// The spacing between major grid lines.
  ///
  /// Set to `null` to disable grid lines.
  final double? lines;

  /// Function to create labels for the axis.
  ///
  /// Set to `null` to disable labels.
  final LabelMaker? labels;

  /// Number of subdivisions between major grid lines.
  ///
  /// Set to `null` to disable subdivisions.
  final int? subdivisions;

  /// Creates a copy with the given fields replaced.
  AxisOptions copyWith({
    bool? axis,
    double? lines,
    LabelMaker? labels,
    int? subdivisions,
  }) {
    return AxisOptions(
      axis: axis ?? this.axis,
      lines: lines ?? this.lines,
      labels: labels ?? this.labels,
      subdivisions: subdivisions ?? this.subdivisions,
    );
  }
}

/// A Cartesian coordinate system with grid lines, axes, and labels.
///
/// This widget renders a traditional x-y coordinate system with:
/// - Major grid lines at configurable intervals
/// - Optional subdivision grid lines
/// - X and Y axis lines through the origin
/// - Numeric labels along each axis
///
/// ## Example
///
/// ```dart
/// Mafs(
///   children: [
///     // Default cartesian coordinates
///     Coordinates.cartesian(),
///
///     // With custom options
///     Coordinates.cartesian(
///       xAxis: AxisOptions(lines: 2, subdivisions: 4),
///       yAxis: AxisOptions(lines: 1, subdivisions: 5),
///     ),
///
///     // With auto-scaling grid
///     Coordinates.cartesian(
///       xAxis: Coordinates.autoAxis,
///       yAxis: Coordinates.autoAxis,
///     ),
///   ],
/// )
/// ```
class CartesianCoordinates extends StatelessWidget {
  /// Creates a Cartesian coordinate system.
  const CartesianCoordinates({
    super.key,
    this.xAxis = const AxisOptions(),
    this.yAxis = const AxisOptions(),
    this.subdivisions,
  });

  /// Creates a Cartesian coordinate system with auto-scaling grid.
  ///
  /// The grid line spacing automatically adjusts based on the zoom level.
  factory CartesianCoordinates.auto({
    Key? key,
    int? subdivisions,
  }) {
    return _AutoCartesianCoordinates(
      key: key,
      subdivisions: subdivisions,
    );
  }

  /// Configuration for the x-axis.
  ///
  /// Set to `null` to disable the x-axis entirely.
  final AxisOptions? xAxis;

  /// Configuration for the y-axis.
  ///
  /// Set to `null` to disable the y-axis entirely.
  final AxisOptions? yAxis;

  /// Default subdivisions for both axes.
  ///
  /// Can be overridden per-axis in [AxisOptions].
  final int? subdivisions;

  @override
  Widget build(BuildContext context) {
    final effectiveXAxis = xAxis?.copyWith(
      subdivisions: xAxis?.subdivisions ?? subdivisions,
    );
    final effectiveYAxis = yAxis?.copyWith(
      subdivisions: yAxis?.subdivisions ?? subdivisions,
    );

    return _CartesianCoordinatesPainter(
      xAxis: effectiveXAxis,
      yAxis: effectiveYAxis,
    );
  }
}

/// Internal widget that auto-computes axis options based on zoom level.
class _AutoCartesianCoordinates extends CartesianCoordinates {
  const _AutoCartesianCoordinates({
    super.key,
    super.subdivisions,
  }) : super(xAxis: null, yAxis: null);

  @override
  Widget build(BuildContext context) {
    final spanData = SpanContext.of(context);

    // Calculate auto grid spacing based on viewport width
    // Magic number 3.5 makes it feel right (roughly 3-4 major grid lines visible)
    final mathWidth = spanData.xSpan / 3.5;
    final nearestPowerOf10 = mafs_math.roundToNearestPowerOf10(mathWidth);

    // Available multiples with their subdivision counts
    const multiples = [
      (value: 1.0, subdivisions: 5),
      (value: 2.0, subdivisions: 4),
      (value: 5.0, subdivisions: 5),
    ];

    final options = multiples.map((m) => nearestPowerOf10 * m.value).toList();
    final closest = mafs_math.pickClosestToValue(mathWidth, options);
    final autoLines = closest.value;
    final autoSubdivisions = multiples[closest.index].subdivisions;

    final autoAxis = AxisOptions(
      lines: autoLines,
      subdivisions: subdivisions ?? autoSubdivisions,
    );

    return _CartesianCoordinatesPainter(
      xAxis: autoAxis,
      yAxis: autoAxis,
    );
  }
}

/// The actual painter widget for Cartesian coordinates.
class _CartesianCoordinatesPainter extends LeafRenderObjectWidget {
  const _CartesianCoordinatesPainter({
    required this.xAxis,
    required this.yAxis,
  });

  final AxisOptions? xAxis;
  final AxisOptions? yAxis;

  @override
  RenderObject createRenderObject(BuildContext context) {
    final theme = MafsTheme.of(context);
    final coordData = CoordinateContext.of(context);
    final transformData = TransformContext.of(context);
    final paneData = PaneContext.of(context);

    return _RenderCartesianCoordinates(
      xAxis: xAxis,
      yAxis: yAxis,
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
    _RenderCartesianCoordinates renderObject,
  ) {
    final theme = MafsTheme.of(context);
    final coordData = CoordinateContext.of(context);
    final transformData = TransformContext.of(context);
    final paneData = PaneContext.of(context);

    renderObject
      ..xAxis = xAxis
      ..yAxis = yAxis
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

class _RenderCartesianCoordinates extends RenderBox {
  _RenderCartesianCoordinates({
    required AxisOptions? xAxis,
    required AxisOptions? yAxis,
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
        _theme = theme,
        _xMin = xMin,
        _xMax = xMax,
        _yMin = yMin,
        _yMax = yMax,
        _viewTransform = viewTransform,
        _xPanes = xPanes,
        _yPanes = yPanes;

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

    // Draw subdivision grid lines
    _paintSubdivisionGrid(canvas);

    // Draw major grid lines
    _paintMajorGrid(canvas);

    // Draw axes
    _paintAxes(canvas);

    // Draw labels
    _paintLabels(canvas);

    canvas.restore();
  }

  void _paintSubdivisionGrid(Canvas canvas) {
    final paint = Paint()
      ..color = _theme.effectiveGridColor.withValues(alpha: 0.5)
      ..strokeWidth = 0.5;

    final xLines = _xAxis?.lines;
    final yLines = _yAxis?.lines;
    final xSubs = _xAxis?.subdivisions ?? 1;
    final ySubs = _yAxis?.subdivisions ?? 1;

    // Draw vertical subdivision lines
    if (_xAxis != null && xLines != null && xSubs > 1) {
      final subStep = xLines / xSubs;
      for (final (paneMin, paneMax) in _xPanes) {
        for (final x in _snappedRange(paneMin, paneMax, subStep)) {
          // Skip if this is a major grid line
          if ((x / xLines - (x / xLines).round()).abs() < 1e-9) continue;

          final screenPoint = _mathToScreen(x, 0);
          canvas.drawLine(
            Offset(screenPoint.dx, 0),
            Offset(screenPoint.dx, size.height),
            paint,
          );
        }
      }
    }

    // Draw horizontal subdivision lines
    if (_yAxis != null && yLines != null && ySubs > 1) {
      final subStep = yLines / ySubs;
      for (final (paneMin, paneMax) in _yPanes) {
        for (final y in _snappedRange(paneMin, paneMax, subStep)) {
          // Skip if this is a major grid line
          if ((y / yLines - (y / yLines).round()).abs() < 1e-9) continue;

          final screenPoint = _mathToScreen(0, y);
          canvas.drawLine(
            Offset(0, screenPoint.dy),
            Offset(size.width, screenPoint.dy),
            paint,
          );
        }
      }
    }
  }

  void _paintMajorGrid(Canvas canvas) {
    final paint = Paint()
      ..color = _theme.effectiveGridColor
      ..strokeWidth = 1;

    final xLines = _xAxis?.lines;
    final yLines = _yAxis?.lines;

    // Draw vertical major grid lines
    if (_xAxis != null && xLines != null) {
      for (final (paneMin, paneMax) in _xPanes) {
        for (final x in _snappedRange(paneMin, paneMax, xLines)) {
          final screenPoint = _mathToScreen(x, 0);
          canvas.drawLine(
            Offset(screenPoint.dx, 0),
            Offset(screenPoint.dx, size.height),
            paint,
          );
        }
      }
    }

    // Draw horizontal major grid lines
    if (_yAxis != null && yLines != null) {
      for (final (paneMin, paneMax) in _yPanes) {
        for (final y in _snappedRange(paneMin, paneMax, yLines)) {
          final screenPoint = _mathToScreen(0, y);
          canvas.drawLine(
            Offset(0, screenPoint.dy),
            Offset(size.width, screenPoint.dy),
            paint,
          );
        }
      }
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
    final xLines = _xAxis?.lines ?? 1;
    final yLines = _yAxis?.lines ?? 1;

    // Paint X axis labels
    if (_xAxis != null && xLabels != null) {
      for (final (paneMin, paneMax) in _xPanes) {
        for (final x in _snappedRange(paneMin, paneMax, xLines)) {
          // Skip label at origin (too crowded)
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

          // Position label below axis, centered horizontally
          final labelOffset = Offset(
            screenPoint.dx - textPainter.width / 2,
            _mathToScreen(0, 0).dy + 5,
          );

          // Only draw if within bounds
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
          // Skip label at origin (too crowded)
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

          // Position label to the left of axis, centered vertically
          final labelOffset = Offset(
            _mathToScreen(0, 0).dx + 5,
            screenPoint.dy - textPainter.height / 2,
          );

          // Only draw if within bounds
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

/// Namespace for coordinate system factories.
///
/// Use [Coordinates.cartesian] or [Coordinates.polar] to create coordinate
/// system widgets.
abstract final class Coordinates {
  /// Creates a Cartesian coordinate system with configurable options.
  ///
  /// Example:
  /// ```dart
  /// Coordinates.cartesian(
  ///   xAxis: AxisOptions(lines: 1, subdivisions: 5),
  ///   yAxis: AxisOptions(lines: 1, subdivisions: 5),
  /// )
  /// ```
  static Widget cartesian({
    Key? key,
    AxisOptions? xAxis = const AxisOptions(),
    AxisOptions? yAxis = const AxisOptions(),
    int? subdivisions,
    bool auto = false,
  }) {
    if (auto) {
      return CartesianCoordinates.auto(
        key: key,
        subdivisions: subdivisions,
      );
    }
    return CartesianCoordinates(
      key: key,
      xAxis: xAxis,
      yAxis: yAxis,
      subdivisions: subdivisions,
    );
  }

  /// Creates a polar coordinate system.
  ///
  /// See [PolarCoordinates] for more details.
  static Widget polar({
    Key? key,
    AxisOptions? xAxis = const AxisOptions(),
    AxisOptions? yAxis = const AxisOptions(),
    double lines = 1,
    int? subdivisions,
  }) {
    return PolarCoordinates(
      key: key,
      xAxis: xAxis,
      yAxis: yAxis,
      lines: lines,
      subdivisions: subdivisions,
    );
  }
}
