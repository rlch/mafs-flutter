import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../context/coordinate_context.dart';
import '../context/pane_context.dart';
import '../context/span_context.dart';
import '../context/transform_context.dart';
import '../display/theme.dart';
import '../gestures/camera.dart';
import '../math.dart' as mafs_math;
import '../vec.dart';

/// Configuration for the viewable area of a Mafs visualization.
@immutable
class ViewBox {
  /// Creates a view box configuration.
  const ViewBox({
    this.x = const (-3, 3),
    this.y = const (-3, 3),
    this.padding = 0.5,
  });

  /// The x-axis range as (min, max).
  final mafs_math.Interval x;

  /// The y-axis range as (min, max).
  final mafs_math.Interval y;

  /// Padding around the view box in coordinate units.
  final double padding;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ViewBox &&
        other.x == x &&
        other.y == y &&
        other.padding == padding;
  }

  @override
  int get hashCode => Object.hash(x, y, padding);
}

/// Configuration for zoom behavior.
@immutable
class ZoomConfig {
  /// Creates a zoom configuration.
  const ZoomConfig({
    this.min = 0.5,
    this.max = 5.0,
  }) : assert(min > 0 && min <= 1, 'min must be in range (0, 1]'),
       assert(max >= 1, 'max must be in range [1, ∞)');

  /// The minimum zoom scale (zoom out limit).
  final double min;

  /// The maximum zoom scale (zoom in limit).
  final double max;
}

/// How to handle aspect ratio when the viewport doesn't match the viewBox.
enum PreserveAspectRatio {
  /// Scale the viewBox to fit within the viewport, preserving aspect ratio.
  contain,

  /// Stretch the viewBox to fill the viewport, not preserving aspect ratio.
  none,
}

/// Callback for tap/click events on the Mafs canvas.
typedef PointCallback = void Function(Offset point);

/// The root widget for Mafs visualizations.
///
/// Mafs provides a coordinate system and rendering context for mathematical
/// visualizations. It handles pan and zoom gestures and provides context
/// to child widgets for coordinate transformations.
///
/// Example:
/// ```dart
/// Mafs(
///   viewBox: const ViewBox(x: (-5, 5), y: (-5, 5)),
///   children: [
///     Coordinates.cartesian(),
///     Plot.ofX(y: (x) => x * x),
///   ],
/// )
/// ```
class Mafs extends StatefulWidget {
  /// Creates a Mafs visualization widget.
  const Mafs({
    super.key,
    this.width,
    this.height = 500,
    this.pan = true,
    this.zoom,
    this.viewBox = const ViewBox(),
    this.preserveAspectRatio = PreserveAspectRatio.contain,
    this.onTap,
    this.theme,
    required this.children,
  });

  /// The width of the widget in pixels.
  ///
  /// If null, expands to fill available width.
  final double? width;

  /// The height of the widget in pixels.
  final double height;

  /// Whether panning is enabled.
  final bool pan;

  /// Zoom configuration.
  ///
  /// - `null` or `false`: Zoom disabled
  /// - `true`: Zoom enabled with default limits (0.5x to 5x)
  /// - [ZoomConfig]: Zoom enabled with custom limits
  final Object? zoom;

  /// The viewable area of the coordinate system.
  final ViewBox viewBox;

  /// How to handle aspect ratio preservation.
  final PreserveAspectRatio preserveAspectRatio;

  /// Callback when the canvas is tapped.
  ///
  /// The [Offset] parameter contains the coordinates in math space.
  final PointCallback? onTap;

  /// Optional theme data. If not provided, uses [MafsThemeData.light].
  final MafsThemeData? theme;

  /// The child widgets to render in the coordinate system.
  final List<Widget> children;

  @override
  State<Mafs> createState() => _MafsState();
}

class _MafsState extends State<Mafs> {
  late CameraController _camera;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void didUpdateWidget(Mafs oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reinitialize camera if zoom settings changed
    if (widget.zoom != oldWidget.zoom) {
      _initCamera();
    }
  }

  void _initCamera() {
    double minZoom = 1.0;
    double maxZoom = 1.0;

    final zoom = widget.zoom;
    if (zoom is ZoomConfig) {
      minZoom = zoom.min;
      maxZoom = zoom.max;
    } else if (zoom == true) {
      minZoom = 0.5;
      maxZoom = 5.0;
    }

    _camera = CameraController(minZoom: minZoom, maxZoom: maxZoom);
    _camera.addListener(_onCameraChange);
  }

  void _onCameraChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _camera.removeListener(_onCameraChange);
    _camera.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? MafsThemeData.light;

    return MafsTheme(
      data: theme,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Determine the actual dimensions to use
          // - If widget specifies a dimension, use it
          // - Otherwise, use constraints.maxWidth/maxHeight
          // - But if parent gives tight constraints, respect those
          double width;
          if (widget.width != null) {
            // User specified a width, but respect tight constraints
            width = constraints.hasTightWidth
                ? constraints.maxWidth
                : widget.width!;
          } else {
            width = constraints.maxWidth;
          }

          // Height always has a value (default 500), but respect tight constraints
          final height = constraints.hasTightHeight
              ? constraints.maxHeight
              : widget.height;

          if (width == 0 || height == 0 || !width.isFinite || !height.isFinite) {
            return SizedBox(width: width.isFinite ? width : null, height: height.isFinite ? height : null);
          }

          // Wrap in SizedBox to ensure children get correct constraints
          return SizedBox(
            width: width,
            height: height,
            child: _MafsCanvas(
              width: width,
              height: height,
              viewBox: widget.viewBox,
              preserveAspectRatio: widget.preserveAspectRatio,
              pan: widget.pan,
              zoom: widget.zoom,
              camera: _camera,
              onTap: widget.onTap,
              children: widget.children,
            ),
          );
        },
      ),
    );
  }
}

class _MafsCanvas extends StatefulWidget {
  const _MafsCanvas({
    required this.width,
    required this.height,
    required this.viewBox,
    required this.preserveAspectRatio,
    required this.pan,
    required this.zoom,
    required this.camera,
    required this.onTap,
    required this.children,
  });

  final double width;
  final double height;
  final ViewBox viewBox;
  final PreserveAspectRatio preserveAspectRatio;
  final bool pan;
  final Object? zoom;
  final CameraController camera;
  final PointCallback? onTap;
  final List<Widget> children;

  @override
  State<_MafsCanvas> createState() => _MafsCanvasState();
}

class _MafsCanvasState extends State<_MafsCanvas> {
  Offset? _scaleStartFocalPoint;

  // Base spans after aspect ratio adjustment (before camera transform)
  // Used for consistent pan velocity
  late double _baseXSpan;
  late double _baseYSpan;

  // Computed bounds after applying camera and aspect ratio
  late double _xMin;
  late double _xMax;
  late double _yMin;
  late double _yMax;
  late double _xSpan;
  late double _ySpan;
  late Matrix2D _viewTransform;

  @override
  void initState() {
    super.initState();
    _computeBounds();
    widget.camera.addListener(_onCameraChange);
  }

  @override
  void didUpdateWidget(_MafsCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.camera != oldWidget.camera) {
      oldWidget.camera.removeListener(_onCameraChange);
      widget.camera.addListener(_onCameraChange);
    }
    _computeBounds();
  }

  @override
  void dispose() {
    widget.camera.removeListener(_onCameraChange);
    super.dispose();
  }

  void _onCameraChange() {
    setState(() {
      _computeBounds();
    });
  }

  void _computeBounds() {
    final padding = widget.viewBox.padding;

    // Start with viewBox bounds plus padding
    var xMin = widget.viewBox.x.$1 - padding;
    var xMax = widget.viewBox.x.$2 + padding;
    var yMin = widget.viewBox.y.$1 - padding;
    var yMax = widget.viewBox.y.$2 + padding;

    // Apply aspect ratio preservation
    if (widget.preserveAspectRatio == PreserveAspectRatio.contain) {
      final aspect = widget.width / widget.height;
      final aoiAspect = (xMax - xMin) / (yMax - yMin);

      if (aoiAspect > aspect) {
        // ViewBox is wider than viewport, expand y
        final yCenter = (yMax + yMin) / 2;
        final ySpan = (xMax - xMin) / aspect / 2;
        yMin = yCenter - ySpan;
        yMax = yCenter + ySpan;
      } else {
        // ViewBox is taller than viewport, expand x
        final xCenter = (xMax + xMin) / 2;
        final xSpan = (yMax - yMin) * aspect / 2;
        xMin = xCenter - xSpan;
        xMax = xCenter + xSpan;
      }
    }

    // Store base spans (after aspect ratio, before camera) for pan calculations
    _baseXSpan = xMax - xMin;
    _baseYSpan = yMax - yMin;

    // Apply camera transformation
    final cameraMatrix = widget.camera.matrix;
    final minCorner = Offset(xMin, yMin).transform(cameraMatrix);
    final maxCorner = Offset(xMax, yMax).transform(cameraMatrix);

    _xMin = minCorner.dx;
    _yMin = minCorner.dy;
    _xMax = maxCorner.dx;
    _yMax = maxCorner.dy;
    _xSpan = _xMax - _xMin;
    _ySpan = _yMax - _yMin;

    // Compute view transform (math space to pixel space)
    // Note: Y is flipped because screen Y increases downward
    final scaleX = mafs_math.round(widget.width / _xSpan, 5);
    final scaleY = mafs_math.round(-widget.height / _ySpan, 5);

    _viewTransform = MatrixBuilder().scale(scaleX, scaleY).build();
  }

  Offset _screenToMath(Offset screenPoint) {
    // Convert screen point to math coordinates
    // Screen x goes from 0 to width, mapping to xMin to xMax
    // Screen y goes from 0 to height, mapping to yMax to yMin (Y is flipped)
    final mathX = (screenPoint.dx / widget.width) * _xSpan + _xMin;
    final mathY = (1 - screenPoint.dy / widget.height) * _ySpan + _yMin;

    return Offset(mathX, mathY);
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _scaleStartFocalPoint = details.localFocalPoint;
    widget.camera.setBase();
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    final zoomEnabled = widget.zoom != null && widget.zoom != false;

    // Handle panning (translation from scale gesture)
    if (widget.pan && _scaleStartFocalPoint != null) {
      final delta = details.localFocalPoint - _scaleStartFocalPoint!;

      // Convert screen delta to math coordinates
      // Use the BASE span (after aspect ratio, before camera) for consistent 1:1 movement
      final mathDeltaX = -delta.dx / widget.width * _baseXSpan;
      final mathDeltaY = delta.dy / widget.height * _baseYSpan;

      if (zoomEnabled && details.scale != 1.0) {
        // Both pan and zoom
        // Pinch out (scale > 1) should zoom in, so use details.scale directly
        final focalPoint = _screenToMath(details.localFocalPoint);
        widget.camera.move(
          pan: Offset(mathDeltaX, mathDeltaY),
          zoom: (at: focalPoint, scale: details.scale),
        );
      } else {
        // Pan only
        widget.camera.move(pan: Offset(mathDeltaX, mathDeltaY));
      }
    } else if (zoomEnabled && details.scale != 1.0) {
      // Zoom only
      // Pinch out (scale > 1) should zoom in, so use details.scale directly
      final focalPoint = _screenToMath(details.localFocalPoint);
      widget.camera.move(
        zoom: (at: focalPoint, scale: details.scale),
      );
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _scaleStartFocalPoint = null;
  }

  void _handleTap(TapUpDetails details) {
    if (widget.onTap == null) return;
    final mathPoint = _screenToMath(details.localPosition);
    widget.onTap!(mathPoint);
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    final zoomEnabled = widget.zoom != null && widget.zoom != false;
    if (!zoomEnabled) return;

    if (event is PointerScrollEvent) {
      // Simple sigmoid function to flatten extreme scrolling
      final scroll = event.scrollDelta.dy;
      final scaledScroll = (-scroll / 300).clamp(-10.0, 10.0);
      final scale = 2 / (1 + math.exp(scaledScroll));

      final point = _screenToMath(event.localPosition);
      widget.camera.setBase();
      widget.camera.move(zoom: (at: point, scale: scale));
    }
  }

  @override
  Widget build(BuildContext context) {
    final zoomEnabled = widget.zoom != null && widget.zoom != false;

    // Compute viewBox offset for the CustomPaint
    final viewBoxX = (_xMin / _xSpan) * widget.width;
    final viewBoxY = (_yMax / -_ySpan) * widget.height;

    final coordinateData = CoordinateContextData(
      xMin: _xMin,
      xMax: _xMax,
      yMin: _yMin,
      yMax: _yMax,
      width: widget.width,
      height: widget.height,
    );

    final spanData = SpanContextData(
      xSpan: _xSpan,
      ySpan: _ySpan,
    );

    final transformData = TransformContextData(
      userTransform: MatrixOps.identity,
      viewTransform: _viewTransform,
    );

    Widget content = CoordinateContext(
      data: coordinateData,
      child: SpanContext(
        data: spanData,
        child: TransformContext(
          data: transformData,
          child: PaneManager(
            child: ClipRect(
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  // Background painter
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _MafsBackgroundPainter(
                        viewBoxX: viewBoxX,
                        viewBoxY: viewBoxY,
                      ),
                    ),
                  ),
                  // Transform children from math space to pixel space
                  Positioned.fill(
                    child: _MafsTransformLayer(
                      viewTransform: _viewTransform,
                      viewBoxOffset: Offset(viewBoxX, viewBoxY),
                      children: widget.children,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Wrap with gesture handling
    // Use scale gesture for both pan and zoom (scale is a superset of pan)
    if (widget.pan || zoomEnabled) {
      content = Listener(
        onPointerSignal: zoomEnabled ? _handlePointerSignal : null,
        child: GestureDetector(
          onScaleStart: _handleScaleStart,
          onScaleUpdate: _handleScaleUpdate,
          onScaleEnd: _handleScaleEnd,
          onTapUp: widget.onTap != null ? _handleTap : null,
          behavior: HitTestBehavior.opaque,
          child: content,
        ),
      );
    } else if (widget.onTap != null) {
      content = GestureDetector(
        onTapUp: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: content,
    );
  }
}

/// Background painter for the Mafs canvas.
class _MafsBackgroundPainter extends CustomPainter {
  _MafsBackgroundPainter({
    required this.viewBoxX,
    required this.viewBoxY,
  });

  final double viewBoxX;
  final double viewBoxY;

  @override
  void paint(Canvas canvas, Size size) {
    // Background is typically transparent, but we could paint it here
    // if needed based on theme
  }

  @override
  bool shouldRepaint(_MafsBackgroundPainter oldDelegate) {
    return viewBoxX != oldDelegate.viewBoxX || viewBoxY != oldDelegate.viewBoxY;
  }
}

/// Transform layer that applies the view transform to children.
class _MafsTransformLayer extends StatelessWidget {
  const _MafsTransformLayer({
    required this.viewTransform,
    required this.viewBoxOffset,
    required this.children,
  });

  final Matrix2D viewTransform;
  final Offset viewBoxOffset;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // The view transform and offset are available via context
    // Children will use CustomPainter to draw in math coordinates
    // Wrap each child in Positioned.fill to ensure they fill the container
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        for (final child in children) Positioned.fill(child: child),
      ],
    );
  }
}
