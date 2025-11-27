import 'package:flutter/widgets.dart';

import '../context/transform_context.dart';
import '../vec.dart';

/// A widget that applies geometric transformations to its children in math space.
///
/// This is a container widget that modifies the coordinate system for all
/// descendant Mafs components. Transforms are applied to the `userTransform`
/// matrix which is then used by display components when converting math
/// coordinates to screen coordinates.
///
/// ## Transform Order
///
/// Transforms are applied in the following order:
/// 1. [matrix] (if provided) - custom transformation matrix
/// 2. [translate] - translation offset
/// 3. [scale] - scaling factors
/// 4. [rotate] - rotation angle
/// 5. [shear] - shear factors
/// 6. Parent's userTransform (inherited from ancestor [TransformContext])
///
/// ## Nesting
///
/// Transforms compose when nested. Each [MafsTransform] applies its transforms
/// on top of any parent transforms:
///
/// ```dart
/// MafsTransform(
///   translate: Offset(2, 0),
///   child: MafsTransform(
///     rotate: math.pi / 2,
///     child: MafsPoint(x: 1, y: 0), // Rotated then translated
///   ),
/// )
/// ```
///
/// ## Example
///
/// ```dart
/// // Translate and rotate a point
/// MafsTransform(
///   translate: Offset(2, 0),
///   rotate: math.pi / 4, // 45 degrees
///   child: MafsPoint(x: 0, y: 0), // Will appear at transformed position
/// )
///
/// // Non-uniform scaling
/// MafsTransform(
///   scale: Offset(2, 0.5), // 2x horizontal, 0.5x vertical
///   child: MafsCircle(center: Offset.zero, radius: 1),
/// )
/// ```
class MafsTransform extends StatelessWidget {
  /// Creates a transform container for Mafs components.
  const MafsTransform({
    super.key,
    this.matrix,
    this.translate,
    this.scale,
    this.rotate,
    this.shear,
    required this.child,
  });

  /// A custom transformation matrix to apply.
  ///
  /// This is applied first, before any other transforms.
  /// Use [MatrixBuilder] to construct complex matrices.
  final Matrix2D? matrix;

  /// Translation offset in math coordinates.
  ///
  /// Moves all child elements by (dx, dy) in math space.
  final Offset? translate;

  /// Scale factors as (scaleX, scaleY).
  ///
  /// For uniform scaling, use the same value for both components:
  /// `scale: Offset(2, 2)` doubles the size in both dimensions.
  ///
  /// For non-uniform scaling, use different values:
  /// `scale: Offset(2, 0.5)` stretches horizontally and compresses vertically.
  final Offset? scale;

  /// Rotation angle in radians, counter-clockwise from positive x-axis.
  ///
  /// Common values:
  /// - `math.pi / 4` - 45 degrees
  /// - `math.pi / 2` - 90 degrees
  /// - `math.pi` - 180 degrees
  final double? rotate;

  /// Shear factors as (shearX, shearY).
  ///
  /// Shearing skews the coordinate system:
  /// - `shear: Offset(1, 0)` skews horizontally
  /// - `shear: Offset(0, 1)` skews vertically
  final Offset? shear;

  /// The child widget tree to transform.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final parentData = TransformContext.of(context);

    var builder = MatrixBuilder();

    // Apply matrix first (if provided)
    if (matrix != null) {
      builder = builder.mult(matrix!);
    }

    // Apply transforms in fixed order: translate, scale, rotate, shear
    if (translate != null) {
      builder = builder.translate(translate!.dx, translate!.dy);
    }

    if (scale != null) {
      builder = builder.scale(scale!.dx, scale!.dy);
    }

    if (rotate != null) {
      builder = builder.rotate(rotate!);
    }

    if (shear != null) {
      builder = builder.shear(shear!.dx, shear!.dy);
    }

    // Compose with parent's userTransform
    builder = builder.mult(parentData.userTransform);

    final newUserTransform = builder.build();

    return TransformContext(
      data: TransformContextData(
        userTransform: newUserTransform,
        viewTransform: parentData.viewTransform,
      ),
      child: child,
    );
  }
}
