import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../math.dart' as mafs_math;
import 'coordinate_context.dart';

/// Data class containing pane information for efficient infinite plot rendering.
@immutable
class PaneContextData {
  /// Creates pane context data.
  const PaneContextData({
    required this.xPanes,
    required this.yPanes,
    required this.xPaneRange,
    required this.yPaneRange,
  });

  /// Empty pane context data with no panes.
  static const empty = PaneContextData(
    xPanes: [],
    yPanes: [],
    xPaneRange: (0, 0),
    yPaneRange: (0, 0),
  );

  /// List of x-axis pane intervals.
  ///
  /// Each pane is an interval [min, max] that should be rendered.
  final List<mafs_math.Interval> xPanes;

  /// List of y-axis pane intervals.
  ///
  /// Each pane is an interval [min, max] that should be rendered.
  final List<mafs_math.Interval> yPanes;

  /// The overall x range covered by all panes.
  final mafs_math.Interval xPaneRange;

  /// The overall y range covered by all panes.
  final mafs_math.Interval yPaneRange;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaneContextData &&
        _listEquals(other.xPanes, xPanes) &&
        _listEquals(other.yPanes, yPanes) &&
        other.xPaneRange == xPaneRange &&
        other.yPaneRange == yPaneRange;
  }

  static bool _listEquals(
    List<mafs_math.Interval> a,
    List<mafs_math.Interval> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(xPanes),
        Object.hashAll(yPanes),
        xPaneRange,
        yPaneRange,
      );

  @override
  String toString() {
    return 'PaneContextData(xPanes: ${xPanes.length}, yPanes: ${yPanes.length}, '
        'xRange: $xPaneRange, yRange: $yPaneRange)';
  }
}

/// An inherited widget that provides pane information for efficient rendering.
///
/// The pane system divides the coordinate space into discrete chunks that can
/// be rendered independently. This allows infinite plots to be rendered
/// efficiently by only computing visible panes.
class PaneContext extends InheritedWidget {
  /// Creates a pane context.
  const PaneContext({
    super.key,
    required this.data,
    required super.child,
  });

  /// The pane context data.
  final PaneContextData data;

  /// Retrieves the [PaneContextData] from the nearest ancestor [PaneContext].
  ///
  /// Throws a [FlutterError] if no [PaneContext] is found in the tree.
  static PaneContextData of(BuildContext context) {
    final result = maybeOf(context);
    if (result == null) {
      throw FlutterError.fromParts([
        ErrorSummary('PaneContext.of() called without a PaneContext in scope.'),
        ErrorDescription(
          'No PaneContext ancestor could be found starting from the context '
          'that was passed to PaneContext.of().',
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

  /// Retrieves the [PaneContextData] from the nearest ancestor [PaneContext],
  /// or null if none is found.
  static PaneContextData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PaneContext>()?.data;
  }

  @override
  bool updateShouldNotify(PaneContext oldWidget) {
    return data != oldWidget.data;
  }
}

/// A widget that computes and provides pane context based on coordinate context.
///
/// This widget automatically calculates the appropriate panes based on the
/// current viewport bounds and provides them to descendants via [PaneContext].
class PaneManager extends StatelessWidget {
  /// Creates a pane manager.
  const PaneManager({
    super.key,
    required this.child,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final coords = CoordinateContext.of(context);
    final data = _computePanes(coords);

    return PaneContext(
      data: data,
      child: child,
    );
  }

  static PaneContextData _computePanes(CoordinateContextData coords) {
    final xMin = coords.xMin;
    final xMax = coords.xMax;
    final yMin = coords.yMin;
    final yMax = coords.yMax;

    // Calculate pane sizes as powers of 2 based on viewport span
    final xPaneSize = math.pow(2, (math.log(xMax - xMin) / math.ln2).round() - 1).toDouble();
    final yPaneSize = math.pow(2, (math.log(yMax - yMin) / math.ln2).round() - 1).toDouble();

    // When there's only `pad` remaining of the current pane, we round up to
    // load the next pane. For example, if each pane is 2 units wide, the next
    // step of panes will be loaded at x = 1.75, 3.75, 5.75, etc when pad = 1/8.
    const pad = 1 / 8;
    final xLowerBound = xPaneSize * (xMin / xPaneSize - pad).floor();
    final xUpperBound = xPaneSize * (xMax / xPaneSize + pad).ceil();
    final yLowerBound = yPaneSize * (yMin / yPaneSize - pad).floor();
    final yUpperBound = yPaneSize * (yMax / yPaneSize + pad).ceil();

    final xPanes = <mafs_math.Interval>[];
    for (final x in mafs_math.range(xLowerBound, xUpperBound - xPaneSize, xPaneSize)) {
      xPanes.add((x, x + xPaneSize));
    }

    final yPanes = <mafs_math.Interval>[];
    for (final y in mafs_math.range(yLowerBound, yUpperBound - yPaneSize, yPaneSize)) {
      yPanes.add((y, y + yPaneSize));
    }

    return PaneContextData(
      xPanes: xPanes,
      yPanes: yPanes,
      xPaneRange: (xLowerBound, xUpperBound),
      yPaneRange: (yLowerBound, yUpperBound),
    );
  }
}
