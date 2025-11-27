import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../context/coordinate_context.dart';
import '../context/transform_context.dart';
import '../vec.dart';
import 'theme.dart';

// =============================================================================
// Adaptive Sampling Utilities
// =============================================================================

/// Cheap pseudo-random hash for consistent sampling.
///
/// Returns a value between 0.4 and 0.6 based on the input range,
/// used to jitter sample points for more robust adaptive sampling.
double _cheapHash(double min, double max) {
  final result = math.sin(min * 12.9898 + max * 78.233) * 43758.5453;
  return 0.4 + 0.2 * (result - result.floor());
}

/// Generic adaptive sampling function.
///
/// Recursively subdivides the domain until the error between the sampled
/// points and interpolated estimates is below the threshold.
///
/// Type parameter [P] is the point type being sampled.
///
/// - [fn]: Function to sample at a given t value
/// - [error]: Function to compute error between real and estimated points
/// - [lerp]: Function to linearly interpolate between two points
/// - [onPoint]: Callback to receive sampled points
/// - [domain]: The (min, max) range of t values to sample
/// - [minDepth]: Minimum recursion depth (guarantees 2^minDepth segments)
/// - [maxDepth]: Maximum recursion depth (caps at 2^maxDepth segments)
/// - [threshold]: Error threshold below which subdivision stops
void _sample<P>({
  required P Function(double t) fn,
  required double Function(P real, P estimate) error,
  required P Function(P p1, P p2, double t) lerp,
  required void Function(double t, P p) onPoint,
  required (double, double) domain,
  required int minDepth,
  required int maxDepth,
  required double threshold,
}) {
  final (min, max) = domain;

  // Evaluate endpoints
  final pMin = fn(min);
  final pMax = fn(max);

  // Emit starting point
  onPoint(min, pMin);

  void subdivide(
    double tMin,
    P pAtMin,
    double tMax,
    P pAtMax,
    int depth,
  ) {
    // Use pseudo-random midpoint for better sampling coverage
    final tMid = tMin + (tMax - tMin) * _cheapHash(tMin, tMax);
    final pMidReal = fn(tMid);
    final pMidEstimate = lerp(pAtMin, pAtMax, _cheapHash(tMin, tMax));

    final shouldSubdivide =
        depth < minDepth || (depth < maxDepth && error(pMidReal, pMidEstimate) > threshold);

    if (shouldSubdivide) {
      subdivide(tMin, pAtMin, tMid, pMidReal, depth + 1);
      subdivide(tMid, pMidReal, tMax, pAtMax, depth + 1);
    } else {
      onPoint(tMax, pAtMax);
    }
  }

  subdivide(min, pMin, max, pMax, 0);
}

/// Sample a parametric function and return a list of points.
///
/// Uses adaptive sampling to produce more points in areas of high curvature
/// and fewer points in linear regions.
///
/// - [fn]: Parametric function returning Offset for a given t
/// - [domain]: The (min, max) range of t values
/// - [minDepth]: Minimum recursion depth
/// - [maxDepth]: Maximum recursion depth
/// - [threshold]: Error threshold in math units
///
/// Returns a list of sampled [Offset] points.
List<Offset> sampleParametric(
  Offset Function(double t) fn,
  (double, double) domain,
  int minDepth,
  int maxDepth,
  double threshold,
) {
  final points = <Offset>[];

  _sample<Offset>(
    fn: fn,
    error: (real, estimate) {
      // Use squared distance for efficiency
      return real.squareDistTo(estimate);
    },
    lerp: (p1, p2, t) => Offset.lerp(p1, p2, t)!,
    onPoint: (t, p) => points.add(p),
    domain: domain,
    minDepth: minDepth,
    maxDepth: maxDepth,
    threshold: threshold * threshold, // Square the threshold since we use squared distance
  );

  return points;
}

// =============================================================================
// Plot Namespace
// =============================================================================

/// A namespace containing different plot component variants.
///
/// Use [Plot.ofX] for y = f(x) functions,
/// [Plot.ofY] for x = f(y) functions,
/// or [Plot.parametric] for parametric curves.
abstract final class Plot {
  /// Creates a plot of y = f(x).
  ///
  /// The function [y] is evaluated for x values within [domain].
  /// If [domain] is null, the visible x range is used.
  ///
  /// Example:
  /// ```dart
  /// Plot.ofX(
  ///   y: (x) => math.sin(x),
  ///   color: MafsColors.blue,
  /// )
  /// ```
  static Widget ofX({
    Key? key,
    required double Function(double x) y,
    (double, double)? domain,
    Color? color,
    double opacity = 1.0,
    double weight = 2,
    StrokeStyle style = StrokeStyle.solid,
    int minSamplingDepth = 8,
    int maxSamplingDepth = 14,
  }) {
    return PlotOfX(
      key: key,
      y: y,
      domain: domain,
      color: color,
      opacity: opacity,
      weight: weight,
      style: style,
      minSamplingDepth: minSamplingDepth,
      maxSamplingDepth: maxSamplingDepth,
    );
  }

  /// Creates a plot of x = f(y).
  ///
  /// The function [x] is evaluated for y values within [domain].
  /// If [domain] is null, the visible y range is used.
  ///
  /// Example:
  /// ```dart
  /// Plot.ofY(
  ///   x: (y) => y * y,
  ///   color: MafsColors.green,
  /// )
  /// ```
  static Widget ofY({
    Key? key,
    required double Function(double y) x,
    (double, double)? domain,
    Color? color,
    double opacity = 1.0,
    double weight = 2,
    StrokeStyle style = StrokeStyle.solid,
    int minSamplingDepth = 8,
    int maxSamplingDepth = 14,
  }) {
    return PlotOfY(
      key: key,
      x: x,
      domain: domain,
      color: color,
      opacity: opacity,
      weight: weight,
      style: style,
      minSamplingDepth: minSamplingDepth,
      maxSamplingDepth: maxSamplingDepth,
    );
  }

  /// Creates a parametric curve plot.
  ///
  /// The function [xy] returns a point for each t value in [domain].
  ///
  /// Example:
  /// ```dart
  /// // Lissajous curve
  /// Plot.parametric(
  ///   xy: (t) => Offset(math.sin(3 * t), math.sin(2 * t)),
  ///   domain: (0, 2 * math.pi),
  ///   color: MafsColors.violet,
  /// )
  /// ```
  static Widget parametric({
    Key? key,
    required Offset Function(double t) xy,
    required (double, double) domain,
    Color? color,
    double opacity = 1.0,
    double weight = 2,
    StrokeStyle style = StrokeStyle.solid,
    int minSamplingDepth = 8,
    int maxSamplingDepth = 14,
  }) {
    return PlotParametric(
      key: key,
      xy: xy,
      domain: domain,
      color: color,
      opacity: opacity,
      weight: weight,
      style: style,
      minSamplingDepth: minSamplingDepth,
      maxSamplingDepth: maxSamplingDepth,
    );
  }
}

// =============================================================================
// PlotOfX - y = f(x)
// =============================================================================

/// A widget that plots y = f(x) functions.
///
/// This is a convenience wrapper around [PlotParametric] that automatically
/// determines the x domain from the visible viewport if not specified.
class PlotOfX extends StatelessWidget {
  /// Creates a plot of y = f(x).
  const PlotOfX({
    super.key,
    required this.y,
    this.domain,
    this.color,
    this.opacity = 1.0,
    this.weight = 2,
    this.style = StrokeStyle.solid,
    this.minSamplingDepth = 8,
    this.maxSamplingDepth = 14,
  }) : assert(opacity >= 0.0 && opacity <= 1.0);

  /// The function to plot: y = f(x).
  final double Function(double x) y;

  /// The x-range to evaluate.
  ///
  /// If null, uses the visible x range from the viewport.
  final (double, double)? domain;

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

  /// Minimum recursion depth for adaptive sampling.
  ///
  /// Higher values produce more samples. Default is 8.
  final int minSamplingDepth;

  /// Maximum recursion depth for adaptive sampling.
  ///
  /// Higher values allow more detail in high-curvature areas. Default is 14.
  final int maxSamplingDepth;

  @override
  Widget build(BuildContext context) {
    final coordData = CoordinateContext.of(context, aspect: CoordinateAspect.xBounds);
    final xMin = domain?.$1 ?? coordData.xMin;
    final xMax = domain?.$2 ?? coordData.xMax;

    return PlotParametric(
      xy: (x) => Offset(x, y(x)),
      domain: (xMin, xMax),
      color: color,
      opacity: opacity,
      weight: weight,
      style: style,
      minSamplingDepth: minSamplingDepth,
      maxSamplingDepth: maxSamplingDepth,
    );
  }
}

// =============================================================================
// PlotOfY - x = f(y)
// =============================================================================

/// A widget that plots x = f(y) functions.
///
/// This is a convenience wrapper around [PlotParametric] that automatically
/// determines the y domain from the visible viewport if not specified.
class PlotOfY extends StatelessWidget {
  /// Creates a plot of x = f(y).
  const PlotOfY({
    super.key,
    required this.x,
    this.domain,
    this.color,
    this.opacity = 1.0,
    this.weight = 2,
    this.style = StrokeStyle.solid,
    this.minSamplingDepth = 8,
    this.maxSamplingDepth = 14,
  }) : assert(opacity >= 0.0 && opacity <= 1.0);

  /// The function to plot: x = f(y).
  final double Function(double y) x;

  /// The y-range to evaluate.
  ///
  /// If null, uses the visible y range from the viewport.
  final (double, double)? domain;

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

  /// Minimum recursion depth for adaptive sampling.
  ///
  /// Higher values produce more samples. Default is 8.
  final int minSamplingDepth;

  /// Maximum recursion depth for adaptive sampling.
  ///
  /// Higher values allow more detail in high-curvature areas. Default is 14.
  final int maxSamplingDepth;

  @override
  Widget build(BuildContext context) {
    final coordData = CoordinateContext.of(context, aspect: CoordinateAspect.yBounds);
    final yMin = domain?.$1 ?? coordData.yMin;
    final yMax = domain?.$2 ?? coordData.yMax;

    return PlotParametric(
      xy: (yVal) => Offset(x(yVal), yVal),
      domain: (yMin, yMax),
      color: color,
      opacity: opacity,
      weight: weight,
      style: style,
      minSamplingDepth: minSamplingDepth,
      maxSamplingDepth: maxSamplingDepth,
    );
  }
}

// =============================================================================
// PlotParametric
// =============================================================================

/// A widget that renders a parametric curve.
///
/// The curve is defined by a function [xy] that maps parameter t to a point.
/// Adaptive sampling is used to produce smooth curves with minimal points.
class PlotParametric extends LeafRenderObjectWidget {
  /// Creates a parametric plot widget.
  const PlotParametric({
    super.key,
    required this.xy,
    required this.domain,
    this.color,
    this.opacity = 1.0,
    this.weight = 2,
    this.style = StrokeStyle.solid,
    this.minSamplingDepth = 8,
    this.maxSamplingDepth = 14,
  }) : assert(opacity >= 0.0 && opacity <= 1.0);

  /// The parametric function: (x, y) = f(t).
  final Offset Function(double t) xy;

  /// The t-range to evaluate: (tMin, tMax).
  final (double, double) domain;

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

  /// Minimum recursion depth for adaptive sampling.
  final int minSamplingDepth;

  /// Maximum recursion depth for adaptive sampling.
  final int maxSamplingDepth;

  @override
  RenderObject createRenderObject(BuildContext context) {
    final transformData = TransformContext.of(context);
    final coordData = CoordinateContext.of(context);

    return RenderPlotParametric(
      xy: xy,
      domain: domain,
      color: color ?? MafsTheme.of(context).foreground,
      opacity: opacity,
      weight: weight,
      style: style,
      minSamplingDepth: minSamplingDepth,
      maxSamplingDepth: maxSamplingDepth,
      userTransform: transformData.userTransform,
      xMin: coordData.xMin,
      xMax: coordData.xMax,
      yMin: coordData.yMin,
      yMax: coordData.yMax,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderPlotParametric renderObject) {
    final transformData = TransformContext.of(context);
    final coordData = CoordinateContext.of(context);

    renderObject
      ..xy = xy
      ..domain = domain
      ..color = color ?? MafsTheme.of(context).foreground
      ..opacity = opacity
      ..weight = weight
      ..style = style
      ..minSamplingDepth = minSamplingDepth
      ..maxSamplingDepth = maxSamplingDepth
      ..userTransform = transformData.userTransform
      ..xMin = coordData.xMin
      ..xMax = coordData.xMax
      ..yMin = coordData.yMin
      ..yMax = coordData.yMax;
  }
}

/// The render object for [PlotParametric].
class RenderPlotParametric extends RenderBox {
  /// Creates a render object for a parametric plot.
  RenderPlotParametric({
    required Offset Function(double t) xy,
    required (double, double) domain,
    required Color color,
    required double opacity,
    required double weight,
    required StrokeStyle style,
    required int minSamplingDepth,
    required int maxSamplingDepth,
    required Matrix2D userTransform,
    required double xMin,
    required double xMax,
    required double yMin,
    required double yMax,
  })  : _xy = xy,
        _domain = domain,
        _color = color,
        _opacity = opacity,
        _weight = weight,
        _style = style,
        _minSamplingDepth = minSamplingDepth,
        _maxSamplingDepth = maxSamplingDepth,
        _userTransform = userTransform,
        _xMin = xMin,
        _xMax = xMax,
        _yMin = yMin,
        _yMax = yMax;

  Offset Function(double t) _xy;
  Offset Function(double t) get xy => _xy;
  set xy(Offset Function(double t) value) {
    if (_xy == value) return;
    _xy = value;
    markNeedsPaint();
  }

  (double, double) _domain;
  (double, double) get domain => _domain;
  set domain((double, double) value) {
    if (_domain == value) return;
    _domain = value;
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

  int _minSamplingDepth;
  int get minSamplingDepth => _minSamplingDepth;
  set minSamplingDepth(int value) {
    if (_minSamplingDepth == value) return;
    _minSamplingDepth = value;
    markNeedsPaint();
  }

  int _maxSamplingDepth;
  int get maxSamplingDepth => _maxSamplingDepth;
  set maxSamplingDepth(int value) {
    if (_maxSamplingDepth == value) return;
    _maxSamplingDepth = value;
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

    // Check for empty or invalid domain
    final (tMin, tMax) = _domain;
    if (tMin >= tMax) return;

    // Calculate error threshold based on pixels per unit
    // This ensures consistent visual quality regardless of zoom level
    final xSpan = _xMax - _xMin;
    final ySpan = _yMax - _yMin;
    final pixelsPerUnitX = size.width / xSpan;
    final pixelsPerUnitY = size.height / ySpan;
    final pixelsPerUnit = math.min(pixelsPerUnitX, pixelsPerUnitY);

    // Threshold in math units - target ~1 pixel error
    final threshold = 1.0 / pixelsPerUnit;

    // Sample the parametric function with user transform applied
    final sampledPoints = sampleParametric(
      (t) {
        final point = _xy(t);
        return point.transform(_userTransform);
      },
      _domain,
      _minSamplingDepth,
      _maxSamplingDepth,
      threshold,
    );

    if (sampledPoints.isEmpty) return;

    // Build path from sampled points, handling non-finite values
    final path = Path();
    var pathStarted = false;

    for (final point in sampledPoints) {
      // Skip non-finite points (NaN, Infinity)
      if (!point.dx.isFinite || !point.dy.isFinite) {
        // Break the path at non-finite points
        pathStarted = false;
        continue;
      }

      final screenPoint = _mathToScreen(point) + offset;

      if (!pathStarted) {
        path.moveTo(screenPoint.dx, screenPoint.dy);
        pathStarted = true;
      } else {
        path.lineTo(screenPoint.dx, screenPoint.dy);
      }
    }

    // Create paint
    final paint = Paint()
      ..color = _color.withValues(alpha: _color.a * _opacity)
      ..strokeWidth = _weight
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // Draw the path
    if (_style == StrokeStyle.dashed) {
      _drawDashedPath(canvas, path, paint);
    } else {
      canvas.drawPath(path, paint);
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
