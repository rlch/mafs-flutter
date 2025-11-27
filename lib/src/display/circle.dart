import 'package:flutter/widgets.dart';

import 'ellipse.dart';
import 'theme.dart';

/// A widget that renders a circle in Mafs coordinates.
///
/// This is a convenience wrapper around [MafsEllipse] with equal radii.
///
/// Example:
/// ```dart
/// MafsCircle(
///   center: Offset(0, 0),
///   radius: 2,
///   color: MafsColors.blue,
/// )
/// ```
class MafsCircle extends StatelessWidget {
  /// Creates a circle with the given center and radius.
  const MafsCircle({
    super.key,
    required this.center,
    required this.radius,
    this.color,
    this.weight = 2,
    this.fillOpacity = 0.15,
    this.strokeOpacity = 1.0,
    this.strokeStyle = StrokeStyle.solid,
  });

  /// The center of the circle in math coordinates.
  final Offset center;

  /// The radius of the circle.
  final double radius;

  /// The color of the circle stroke and fill.
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
  Widget build(BuildContext context) {
    return MafsEllipse(
      center: center,
      radius: Offset(radius, radius),
      color: color,
      weight: weight,
      fillOpacity: fillOpacity,
      strokeOpacity: strokeOpacity,
      strokeStyle: strokeStyle,
    );
  }
}
