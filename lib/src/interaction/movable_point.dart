import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../context/coordinate_context.dart';
import '../context/transform_context.dart';
import '../display/theme.dart';
import '../vec.dart';

/// Function that constrains a point's position.
typedef ConstraintFunction = Offset Function(Offset position);

/// A draggable point that can be moved around the coordinate system.
///
/// This widget displays an interactive point that users can drag to change
/// its position. The point features smooth animations on hover and drag,
/// matching the original Mafs library's design.
///
/// ## Features
///
/// - Draggable with smooth visual feedback
/// - Hover animations (point grows, ring expands)
/// - Optional movement constraints (horizontal, vertical, or custom)
///
/// ## Example
///
/// ```dart
/// class MyWidget extends StatefulWidget {
///   @override
///   State<MyWidget> createState() => _MyWidgetState();
/// }
///
/// class _MyWidgetState extends State<MyWidget> {
///   Offset _point = const Offset(1, 1);
///
///   @override
///   Widget build(BuildContext context) {
///     return Mafs(
///       children: [
///         MovablePoint(
///           point: _point,
///           onMove: (newPoint) => setState(() => _point = newPoint),
///         ),
///       ],
///     );
///   }
/// }
/// ```
///
/// ## Constraints
///
/// You can constrain movement to an axis or custom path:
///
/// ```dart
/// // Horizontal only
/// MovablePoint(
///   point: point,
///   onMove: onMove,
///   constrain: MovablePoint.horizontal(point.dy),
/// )
///
/// // Vertical only
/// MovablePoint(
///   point: point,
///   onMove: onMove,
///   constrain: MovablePoint.vertical(point.dx),
/// )
///
/// // Snap to grid
/// MovablePoint(
///   point: point,
///   onMove: onMove,
///   constrain: (p) => Offset(p.dx.roundToDouble(), p.dy.roundToDouble()),
/// )
/// ```
class MovablePoint extends StatefulWidget {
  /// Creates a movable point.
  const MovablePoint({
    super.key,
    required this.point,
    required this.onMove,
    this.constrain,
    this.color,
  });

  /// The current position of the point in math coordinates.
  final Offset point;

  /// Called when the user drags the point to a new position.
  final ValueChanged<Offset> onMove;

  /// Optional function to constrain the point's movement.
  ///
  /// Use [horizontal] or [vertical] for axis constraints,
  /// or provide a custom function.
  final ConstraintFunction? constrain;

  /// The color of the point.
  ///
  /// Defaults to [MafsColors.pink] if not specified.
  final Color? color;

  /// Creates a constraint function for horizontal movement only.
  static ConstraintFunction horizontal(double y) {
    return (Offset p) => Offset(p.dx, y);
  }

  /// Creates a constraint function for vertical movement only.
  static ConstraintFunction vertical(double x) {
    return (Offset p) => Offset(x, p.dy);
  }

  @override
  State<MovablePoint> createState() => _MovablePointState();
}

class _MovablePointState extends State<MovablePoint>
    with SingleTickerProviderStateMixin {
  bool _dragging = false;
  bool _hovering = false;

  // Animation controller for smooth transitions
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateAnimation() {
    if (_hovering || _dragging) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _handleDragStart() {
    if (!_dragging) {
      setState(() => _dragging = true);
      _updateAnimation();
    }
  }

  void _handleDragEnd() {
    if (_dragging) {
      setState(() => _dragging = false);
      _updateAnimation();
    }
  }

  void _setHovering(bool value) {
    if (_hovering != value) {
      setState(() => _hovering = value);
      _updateAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? MafsColors.pink;
    final transformData = TransformContext.of(context);
    final coordData = CoordinateContext.of(context);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return _MovablePointLayout(
          point: widget.point,
          color: color,
          hoverProgress: _scaleAnimation.value,
          constrain: widget.constrain ?? (p) => p,
          onMove: widget.onMove,
          onDragStart: _handleDragStart,
          onDragEnd: _handleDragEnd,
          onHoverChanged: _setHovering,
          cursor: _dragging ? SystemMouseCursors.grabbing : SystemMouseCursors.grab,
          userTransform: transformData.userTransform,
          xMin: coordData.xMin,
          xMax: coordData.xMax,
          yMin: coordData.yMin,
          yMax: coordData.yMax,
          width: coordData.width,
          height: coordData.height,
        );
      },
    );
  }
}

/// A layout widget that positions the interactive hit area and visual display.
class _MovablePointLayout extends StatefulWidget {
  const _MovablePointLayout({
    required this.point,
    required this.color,
    required this.hoverProgress,
    required this.constrain,
    required this.onMove,
    required this.onDragStart,
    required this.onDragEnd,
    required this.onHoverChanged,
    required this.cursor,
    required this.userTransform,
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
    required this.width,
    required this.height,
  });

  final Offset point;
  final Color color;
  final double hoverProgress;
  final ConstraintFunction constrain;
  final ValueChanged<Offset> onMove;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;
  final ValueChanged<bool> onHoverChanged;
  final MouseCursor cursor;
  final Matrix2D userTransform;
  final double xMin, xMax, yMin, yMax;
  final double width, height;

  @override
  State<_MovablePointLayout> createState() => _MovablePointLayoutState();
}

class _MovablePointLayoutState extends State<_MovablePointLayout> {
  Offset? _pickupPoint;
  bool _isDragging = false;
  bool _pointerExitedDuringDrag = false;

  static const double _hitboxRadius = 30.0;

  Offset get _screenPoint {
    final transformedPoint = widget.point.transform(widget.userTransform);
    final xSpan = widget.xMax - widget.xMin;
    final ySpan = widget.yMax - widget.yMin;
    final screenX = (transformedPoint.dx - widget.xMin) / xSpan * widget.width;
    final screenY = (1 - (transformedPoint.dy - widget.yMin) / ySpan) * widget.height;
    return Offset(screenX, screenY);
  }

  void _handleDragStart(Offset localPosition) {
    _pickupPoint = widget.point.transform(widget.userTransform);
    _isDragging = true;
    _pointerExitedDuringDrag = false;
    widget.onDragStart();
  }

  void _handleDragUpdate(Offset delta) {
    if (_pickupPoint == null) return;

    final inverseUser = MatrixOps.invert(widget.userTransform);
    if (inverseUser == null) return;

    final xSpan = widget.xMax - widget.xMin;
    final ySpan = widget.yMax - widget.yMin;

    final mathDelta = Offset(
      delta.dx / widget.width * xSpan,
      -delta.dy / widget.height * ySpan,
    );

    _pickupPoint = _pickupPoint! + mathDelta;
    final newPoint = widget.constrain(_pickupPoint!.transform(inverseUser));
    widget.onMove(newPoint);
  }

  void _handleDragEnd() {
    _pickupPoint = null;
    _isDragging = false;
    widget.onDragEnd();
    // If the pointer exited during the drag, reset hover state now
    if (_pointerExitedDuringDrag) {
      _pointerExitedDuringDrag = false;
      widget.onHoverChanged(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenPoint = _screenPoint;

    return Stack(
      alignment: Alignment.topLeft,
      clipBehavior: Clip.none,
      children: [
        // Visual display (full size, paints the point)
        // IgnorePointer ensures this doesn't block hit testing for other widgets
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _MovablePointPainter(
                screenPoint: screenPoint,
                color: widget.color,
                hoverProgress: widget.hoverProgress,
              ),
            ),
          ),
        ),
        // Hit area (positioned at the point location)
        Positioned(
          left: screenPoint.dx - _hitboxRadius,
          top: screenPoint.dy - _hitboxRadius,
          width: _hitboxRadius * 2,
          height: _hitboxRadius * 2,
          child: MouseRegion(
            cursor: widget.cursor,
            onEnter: (_) => widget.onHoverChanged(true),
            onExit: (_) {
              if (_isDragging) {
                // Remember that pointer exited during drag - we'll reset hover when drag ends
                _pointerExitedDuringDrag = true;
              } else {
                widget.onHoverChanged(false);
              }
            },
            child: RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: <Type, GestureRecognizerFactory>{
                _EagerDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<_EagerDragGestureRecognizer>(
                  () => _EagerDragGestureRecognizer(),
                  (_EagerDragGestureRecognizer instance) {
                    instance
                      ..onStart = _handleDragStart
                      ..onUpdate = _handleDragUpdate
                      ..onEnd = _handleDragEnd
                      ..onCancel = _handleDragEnd;
                  },
                ),
              },
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }
}

/// A custom drag gesture recognizer that immediately claims the gesture arena.
///
/// This prevents the parent Mafs pan/zoom gesture from taking over when
/// dragging a MovablePoint.
class _EagerDragGestureRecognizer extends OneSequenceGestureRecognizer {
  _EagerDragGestureRecognizer() : super();

  /// Called when a drag starts (pointer down).
  ValueChanged<Offset>? onStart;

  /// Called when the pointer moves.
  ValueChanged<Offset>? onUpdate;

  /// Called when the drag ends.
  VoidCallback? onEnd;

  /// Called when the drag is cancelled.
  VoidCallback? onCancel;

  Offset? _lastPosition;

  @override
  void addPointer(PointerDownEvent event) {
    startTrackingPointer(event.pointer, event.transform);
    // Immediately resolve and claim this gesture to prevent parent gestures
    // from taking over
    resolve(GestureDisposition.accepted);
    _lastPosition = event.localPosition;
    onStart?.call(event.localPosition);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      final delta = event.localPosition - (_lastPosition ?? event.localPosition);
      _lastPosition = event.localPosition;
      onUpdate?.call(delta);
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      stopTrackingPointer(event.pointer);
      if (event is PointerUpEvent) {
        onEnd?.call();
      } else {
        onCancel?.call();
      }
      _lastPosition = null;
    }
  }

  @override
  String get debugDescription => 'eager drag';

  @override
  void didStopTrackingLastPointer(int pointer) {
    // Clean up when tracking stops
  }
}

/// Custom painter for the movable point visual.
class _MovablePointPainter extends CustomPainter {
  _MovablePointPainter({
    required this.screenPoint,
    required this.color,
    required this.hoverProgress,
  });

  final Offset screenPoint;
  final Color color;
  final double hoverProgress;

  static const double _pointRadius = 6.0;
  static const double _ringRadius = 15.0;
  static const double _ringOpacity = 0.25;
  static const double _hoverPointGrow = 7.0;
  static const double _hoverRingGrow = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate animated sizes based on hover progress
    final ringRadius = _ringRadius + (_hoverRingGrow * hoverProgress);
    final pointRadius = _pointRadius + (_hoverPointGrow * hoverProgress);

    // Draw the ring (semi-transparent background)
    final ringPaint = Paint()
      ..color = color.withValues(alpha: _ringOpacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(screenPoint, ringRadius, ringPaint);

    // Draw the point (solid fill)
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(screenPoint, pointRadius, pointPaint);
  }

  @override
  bool shouldRepaint(_MovablePointPainter oldDelegate) {
    return screenPoint != oldDelegate.screenPoint ||
        color != oldDelegate.color ||
        hoverProgress != oldDelegate.hoverProgress;
  }
}
