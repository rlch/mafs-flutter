/// A Flutter library for creating interactive math visualizations.
///
/// Mafs Flutter is a port of the React [Mafs](https://mafs.dev) library,
/// providing a declarative API for building interactive mathematical
/// visualizations with pan and zoom support.
///
/// **Note:** This library has no Material or Cupertino dependencies—it uses
/// only `dart:ui`, `rendering`, and `widgets` layers.
///
/// ## Getting Started
///
/// The main entry point is the [Mafs] widget, which sets up the coordinate
/// system and provides context to child widgets:
///
/// ```dart
/// import 'dart:math' as math;
/// import 'package:flutter/widgets.dart';
/// import 'package:mafs_flutter/mafs_flutter.dart';
///
/// Mafs(
///   viewBox: const ViewBox(x: (-5, 5), y: (-5, 5)),
///   pan: true,
///   zoom: true,
///   children: [
///     Coordinates.cartesian(),
///     Plot.ofX(y: (x) => math.sin(x), color: MafsColors.blue),
///     MafsPoint(x: 0, y: 0),
///   ],
/// )
/// ```
///
/// ## Display Components
///
/// - [MafsPoint] - Points at specific coordinates
/// - [MafsCircle], [MafsEllipse] - Circular and elliptical shapes
/// - [MafsPolygon], [MafsPolyline] - Polygons and polylines
/// - [MafsVector] - Vectors with arrow heads
/// - [MafsText] - Text labels at coordinates
/// - [MafsLaTeX] - LaTeX mathematical notation (requires `flutter_math_fork`)
/// - [MafsWidget] - Position any Flutter widget in math coordinates
/// - [Line] - Line segments and infinite lines
/// - [Plot] - Function plots (y=f(x), x=f(y), parametric)
/// - [Coordinates] - Cartesian and polar coordinate systems
/// - [MafsTransform] - Geometric transformations (translate, rotate, scale)
///
/// ## Interaction
///
/// - [MovablePoint] - Draggable points with optional constraints
///
/// ## Core Concepts
///
/// - **ViewBox**: Defines the visible coordinate range in math units
/// - **Coordinate System**: Y-axis increases upward (mathematical convention)
/// - **Transforms**: Nest [MafsTransform] to apply geometric transformations
/// - **Theme**: Use [MafsTheme] and [MafsColors] for consistent styling
///
/// ## Example: Interactive Distance Calculator
///
/// ```dart
/// class DistanceDemo extends StatefulWidget {
///   @override
///   State<DistanceDemo> createState() => _DistanceDemoState();
/// }
///
/// class _DistanceDemoState extends State<DistanceDemo> {
///   Offset _point1 = const Offset(1, 1);
///   Offset _point2 = const Offset(-1, -1);
///
///   double get _distance {
///     final dx = _point1.dx - _point2.dx;
///     final dy = _point1.dy - _point2.dy;
///     return math.sqrt(dx * dx + dy * dy);
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Mafs(
///       viewBox: const ViewBox(x: (-3, 3), y: (-3, 3)),
///       children: [
///         Coordinates.cartesian(),
///         MovablePoint(
///           point: _point1,
///           onMove: (p) => setState(() => _point1 = p),
///         ),
///         MovablePoint(
///           point: _point2,
///           onMove: (p) => setState(() => _point2 = p),
///         ),
///         Line.segment(point1: _point1, point2: _point2),
///         MafsText(
///           x: 0,
///           y: 2,
///           text: 'd = ${_distance.toStringAsFixed(2)}',
///         ),
///       ],
///     );
///   }
/// }
/// ```
library;
// ignore_for_file: comment_references

// Core math utilities
export 'src/math.dart';
export 'src/vec.dart';

// Context providers
export 'src/context/coordinate_context.dart';
export 'src/context/pane_context.dart';
export 'src/context/span_context.dart';
export 'src/context/transform_context.dart';

// Display components
export 'src/display/circle.dart';
export 'src/display/coordinates/coordinates.dart';
export 'src/display/ellipse.dart';
export 'src/display/latex.dart';
export 'src/display/line.dart';
export 'src/display/plot.dart';
export 'src/display/point.dart';
export 'src/display/polygon.dart';
export 'src/display/text.dart';
export 'src/display/theme.dart';
export 'src/display/transform.dart';
export 'src/display/vector.dart';
export 'src/display/widget.dart';

// Gestures
export 'src/gestures/camera.dart';

// Interaction
export 'src/interaction/movable_point.dart';

// Main widget
export 'src/view/mafs.dart';
