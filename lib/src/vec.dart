import 'dart:math' as math;
import 'dart:ui';

/// Mafs' internal linear algebra functions.
///
/// A lot of the code here was adapted from [vec-la](https://github.com/francisrstokes/vec-la) 1.4.0,
/// which was released under the MIT license.

/// A 2x3 representation of a 3x3 matrix used to transform and translate a
/// two-dimensional vector.
///
/// Layout: [a, c, tx, b, d, ty] representing:
/// ```
/// | a  c  tx |
/// | b  d  ty |
/// | 0  0  1  |
/// ```
typedef Matrix2D = (double, double, double, double, double, double);

/// Extension methods for 2D vector operations on [Offset].
///
/// Uses Flutter's built-in [Offset] type as Vector2.
extension Vec2 on Offset {
  /// The x component of this vector.
  double get x => dx;

  /// The y component of this vector.
  double get y => dy;

  /// Add two vectors.
  Offset add(Offset other) => this + other;

  /// Subtract one vector from another.
  Offset sub(Offset other) => this - other;

  /// Get the magnitude (length) of this vector.
  double get mag => distance;

  /// Get the squared magnitude of this vector.
  double get magSquared => distanceSquared;

  /// Get the normal (perpendicular) vector of this vector.
  ///
  /// Returns a vector rotated 90 degrees counter-clockwise.
  Offset get normal => Offset(-dy, dx);

  /// Scale this vector by a scalar.
  Offset scaleBy(double scalar) => this * scalar;

  /// Return a vector with the specified magnitude.
  Offset withMag(double m) {
    final magnitude = mag;
    if (magnitude == 0) return Offset.zero;
    return scaleBy(m / magnitude);
  }

  /// Return a normalized version of this vector (magnitude = 1).
  Offset get normalized => withMag(1);

  /// Linear interpolation between this vector and another.
  Offset lerpTo(Offset other, double t) {
    final d = other - this;
    final m = d.mag;
    return this + d.withMag(t * m);
  }

  /// Rotates this vector around the origin by [angle] radians.
  Offset rotate(double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    return Offset(dx * c - dy * s, dx * s + dy * c);
  }

  /// Rotates this vector around a given [center] point by [angle] radians.
  Offset rotateAbout(Offset center, double angle) {
    final translated = this - center;
    return center + translated.rotate(angle);
  }

  /// Gets the midpoint between this vector and another.
  Offset midpointTo(Offset other) => lerpTo(other, 0.5);

  /// Gets the distance between this vector and another.
  double distTo(Offset other) => (this - other).distance;

  /// Gets the squared distance between this vector and another.
  double squareDistTo(Offset other) => (this - other).distanceSquared;

  /// Dot product with another vector.
  double dot(Offset other) => dx * other.dx + dy * other.dy;

  /// Apply a matrix transformation to this vector.
  Offset transform(Matrix2D m) {
    return Offset(
      dx * m.$1 + dy * m.$2 + m.$3,
      dx * m.$4 + dy * m.$5 + m.$6,
    );
  }
}

/// Matrix operations for 2D transformations.
///
/// These functions operate on [Matrix2D] which is a 2x3 matrix stored as:
/// (a, c, tx, b, d, ty)
abstract final class MatrixOps {
  /// The identity matrix.
  static const Matrix2D identity = (1.0, 0.0, 0.0, 0.0, 1.0, 0.0);

  /// Create a matrix with the specified values.
  ///
  /// Default is the identity matrix.
  static Matrix2D create({
    double a = 1,
    double b = 0,
    double c = 0,
    double d = 1,
    double tx = 0,
    double ty = 0,
  }) {
    return (a, c, tx, b, d, ty);
  }

  /// Create a translation matrix.
  static Matrix2D translate(double x, double y) {
    return (1.0, 0.0, x, 0.0, 1.0, y);
  }

  /// Create a scaling matrix.
  static Matrix2D scale(double x, double y) {
    return (x, 0.0, 0.0, 0.0, y, 0.0);
  }

  /// Create a rotation matrix for the given [angle] in radians.
  static Matrix2D rotation(double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    return (c, -s, 0.0, s, c, 0.0);
  }

  /// Create a shear matrix.
  static Matrix2D shear(double x, double y) {
    return (1.0, x, 0.0, y, 1.0, 0.0);
  }

  /// Multiply two matrices (compose 2D transformations).
  ///
  /// This computes `m * m2`, meaning `m` is applied after `m2`.
  static Matrix2D mult(Matrix2D m, Matrix2D m2) {
    return (
      m.$1 * m2.$1 + m.$2 * m2.$4,
      m.$1 * m2.$2 + m.$2 * m2.$5,
      m.$1 * m2.$3 + m.$2 * m2.$6 + m.$3,
      m.$4 * m2.$1 + m.$5 * m2.$4,
      m.$4 * m2.$2 + m.$5 * m2.$5,
      m.$4 * m2.$3 + m.$5 * m2.$6 + m.$6,
    );
  }

  /// Calculate the determinant of a matrix.
  static double det(Matrix2D m) {
    return m.$1 * m.$5 - m.$4 * m.$2;
  }

  /// Invert a matrix, returning null if the determinant is zero
  /// (indicating a degenerate transformation).
  static Matrix2D? invert(Matrix2D a) {
    final mDet = det(a);
    if (mDet == 0) return null;

    final invDet = 1.0 / mDet;

    final a00 = a.$1, a01 = a.$2, a02 = a.$3;
    final a10 = a.$4, a11 = a.$5, a12 = a.$6;

    return (
      invDet * a11,
      invDet * -a01,
      invDet * (a12 * a01 - a02 * a11),
      invDet * -a10,
      invDet * a00,
      invDet * (-a12 * a00 + a02 * a10),
    );
  }

  /// Transform a vector by a matrix.
  static Offset transformOffset(Offset v, Matrix2D m) {
    return v.transform(m);
  }

  /// Represent a matrix as a CSS transform `matrix(...)` string.
  static String toCSS(Matrix2D matrix) {
    final (a, c, tx, b, d, ty) = matrix;
    return 'matrix($a, $b, $c, $d, $tx, $ty)';
  }
}

/// A builder for creating matrices from a chain of transformations.
///
/// Example:
/// ```dart
/// final matrix = MatrixBuilder()
///     .translate(10, 10)
///     .scale(2, 2)
///     .rotate(math.pi / 4)
///     .build();
/// ```
class MatrixBuilder {
  /// Creates a new matrix builder with the identity matrix.
  MatrixBuilder() : _matrix = MatrixOps.identity;

  /// Creates a matrix builder starting from an existing matrix.
  MatrixBuilder.from(Matrix2D matrix) : _matrix = matrix;

  Matrix2D _matrix;

  /// Multiply by another matrix.
  MatrixBuilder mult(Matrix2D m) {
    _matrix = MatrixOps.mult(m, _matrix);
    return this;
  }

  /// Apply a translation.
  MatrixBuilder translate(double x, double y) {
    _matrix = MatrixOps.mult(MatrixOps.translate(x, y), _matrix);
    return this;
  }

  /// Apply a rotation by [angle] radians.
  MatrixBuilder rotate(double angle) {
    _matrix = MatrixOps.mult(MatrixOps.rotation(angle), _matrix);
    return this;
  }

  /// Apply a scale transformation.
  MatrixBuilder scale(double x, double y) {
    _matrix = MatrixOps.mult(MatrixOps.scale(x, y), _matrix);
    return this;
  }

  /// Apply a shear transformation.
  MatrixBuilder shear(double x, double y) {
    _matrix = MatrixOps.mult(MatrixOps.shear(x, y), _matrix);
    return this;
  }

  /// Build and return the final matrix.
  Matrix2D build() => _matrix;
}
