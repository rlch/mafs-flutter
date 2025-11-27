import 'package:flutter/widgets.dart';

/// Data class containing coordinate system bounds and viewport dimensions.
@immutable
class CoordinateContextData {
  /// Creates coordinate context data.
  const CoordinateContextData({
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
    required this.width,
    required this.height,
  });

  /// The minimum x-coordinate visible in the viewport.
  final double xMin;

  /// The maximum x-coordinate visible in the viewport.
  final double xMax;

  /// The minimum y-coordinate visible in the viewport.
  final double yMin;

  /// The maximum y-coordinate visible in the viewport.
  final double yMax;

  /// The width of the viewport in pixels.
  final double width;

  /// The height of the viewport in pixels.
  final double height;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CoordinateContextData &&
        other.xMin == xMin &&
        other.xMax == xMax &&
        other.yMin == yMin &&
        other.yMax == yMax &&
        other.width == width &&
        other.height == height;
  }

  @override
  int get hashCode => Object.hash(xMin, xMax, yMin, yMax, width, height);

  @override
  String toString() {
    return 'CoordinateContextData(x: [$xMin, $xMax], y: [$yMin, $yMax], '
        'size: ${width}x$height)';
  }
}

/// Aspects of [CoordinateContext] that can be depended on independently.
enum CoordinateAspect {
  /// Depend on x-axis bounds (xMin, xMax).
  xBounds,

  /// Depend on y-axis bounds (yMin, yMax).
  yBounds,

  /// Depend on viewport dimensions (width, height).
  dimensions,
}

/// An inherited widget that provides coordinate system information to descendants.
///
/// This is implemented as an [InheritedModel] to allow widgets to depend only
/// on specific aspects of the coordinate system, enabling fine-grained rebuilds.
class CoordinateContext extends InheritedModel<CoordinateAspect> {
  /// Creates a coordinate context.
  const CoordinateContext({
    super.key,
    required this.data,
    required super.child,
  });

  /// The coordinate context data.
  final CoordinateContextData data;

  /// Retrieves the [CoordinateContextData] from the nearest ancestor
  /// [CoordinateContext].
  ///
  /// If [aspect] is provided, the widget will only rebuild when that specific
  /// aspect of the coordinate data changes.
  ///
  /// Throws a [FlutterError] if no [CoordinateContext] is found in the tree.
  static CoordinateContextData of(
    BuildContext context, {
    CoordinateAspect? aspect,
  }) {
    final result = maybeOf(context, aspect: aspect);
    if (result == null) {
      throw FlutterError.fromParts([
        ErrorSummary('CoordinateContext.of() called without a CoordinateContext in scope.'),
        ErrorDescription(
          'No CoordinateContext ancestor could be found starting from the context '
          'that was passed to CoordinateContext.of().',
        ),
        ErrorHint(
          'This usually means the widget is not inside a Mafs widget. '
          'Make sure your widget is a descendant of Mafs.',
        ),
        context.describeElement('The context used was'),
      ]);
    }
    return result;
  }

  /// Retrieves the [CoordinateContextData] from the nearest ancestor
  /// [CoordinateContext], or null if none is found.
  static CoordinateContextData? maybeOf(
    BuildContext context, {
    CoordinateAspect? aspect,
  }) {
    return InheritedModel.inheritFrom<CoordinateContext>(
      context,
      aspect: aspect,
    )?.data;
  }

  @override
  bool updateShouldNotify(CoordinateContext oldWidget) {
    return data != oldWidget.data;
  }

  @override
  bool updateShouldNotifyDependent(
    CoordinateContext oldWidget,
    Set<CoordinateAspect> dependencies,
  ) {
    if (dependencies.contains(CoordinateAspect.xBounds)) {
      if (data.xMin != oldWidget.data.xMin || data.xMax != oldWidget.data.xMax) {
        return true;
      }
    }
    if (dependencies.contains(CoordinateAspect.yBounds)) {
      if (data.yMin != oldWidget.data.yMin || data.yMax != oldWidget.data.yMax) {
        return true;
      }
    }
    if (dependencies.contains(CoordinateAspect.dimensions)) {
      if (data.width != oldWidget.data.width ||
          data.height != oldWidget.data.height) {
        return true;
      }
    }
    return false;
  }
}
