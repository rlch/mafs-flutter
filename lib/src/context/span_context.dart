import 'package:flutter/widgets.dart';

/// Data class containing the span (range) of the visible coordinate system.
@immutable
class SpanContextData {
  /// Creates span context data.
  const SpanContextData({
    required this.xSpan,
    required this.ySpan,
  });

  /// The span of the x-axis (xMax - xMin).
  final double xSpan;

  /// The span of the y-axis (yMax - yMin).
  final double ySpan;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpanContextData &&
        other.xSpan == xSpan &&
        other.ySpan == ySpan;
  }

  @override
  int get hashCode => Object.hash(xSpan, ySpan);

  @override
  String toString() => 'SpanContextData(xSpan: $xSpan, ySpan: $ySpan)';
}

/// An inherited widget that provides coordinate span information to descendants.
///
/// The span represents the total range of coordinates visible in the viewport.
class SpanContext extends InheritedWidget {
  /// Creates a span context.
  const SpanContext({
    super.key,
    required this.data,
    required super.child,
  });

  /// The span context data.
  final SpanContextData data;

  /// Retrieves the [SpanContextData] from the nearest ancestor [SpanContext].
  ///
  /// Throws a [FlutterError] if no [SpanContext] is found in the tree.
  static SpanContextData of(BuildContext context) {
    final result = maybeOf(context);
    if (result == null) {
      throw FlutterError.fromParts([
        ErrorSummary('SpanContext.of() called without a SpanContext in scope.'),
        ErrorDescription(
          'No SpanContext ancestor could be found starting from the context '
          'that was passed to SpanContext.of().',
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

  /// Retrieves the [SpanContextData] from the nearest ancestor [SpanContext],
  /// or null if none is found.
  static SpanContextData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SpanContext>()?.data;
  }

  @override
  bool updateShouldNotify(SpanContext oldWidget) {
    return data != oldWidget.data;
  }
}
