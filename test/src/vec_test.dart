import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:mafs_flutter/src/vec.dart';

void main() {
  group('Vec2 extension on Offset', () {
    test('x and y getters return dx and dy', () {
      const offset = Offset(3.0, 4.0);
      expect(offset.x, 3.0);
      expect(offset.y, 4.0);
    });

    test('add adds two vectors', () {
      const v1 = Offset(1.0, 2.0);
      const v2 = Offset(3.0, 4.0);
      expect(v1.add(v2), const Offset(4.0, 6.0));
    });

    test('sub subtracts vectors', () {
      const v1 = Offset(5.0, 7.0);
      const v2 = Offset(2.0, 3.0);
      expect(v1.sub(v2), const Offset(3.0, 4.0));
    });

    test('mag returns magnitude', () {
      const v = Offset(3.0, 4.0);
      expect(v.mag, 5.0);
    });

    test('magSquared returns squared magnitude', () {
      const v = Offset(3.0, 4.0);
      expect(v.magSquared, 25.0);
    });

    test('normal returns perpendicular vector', () {
      const v = Offset(1.0, 0.0);
      expect(v.normal, const Offset(0.0, 1.0));
    });

    test('scaleBy multiplies by scalar', () {
      const v = Offset(2.0, 3.0);
      expect(v.scaleBy(2.0), const Offset(4.0, 6.0));
    });

    test('withMag returns vector with specified magnitude', () {
      const v = Offset(3.0, 4.0);
      final result = v.withMag(10.0);
      expect(result.mag, closeTo(10.0, 0.0001));
      // Direction should be preserved
      expect(result.dx / result.dy, closeTo(v.dx / v.dy, 0.0001));
    });

    test('withMag handles zero vector', () {
      const v = Offset.zero;
      expect(v.withMag(10.0), Offset.zero);
    });

    test('normalized returns unit vector', () {
      const v = Offset(3.0, 4.0);
      final result = v.normalized;
      expect(result.mag, closeTo(1.0, 0.0001));
    });

    test('lerpTo interpolates between vectors', () {
      const v1 = Offset(0.0, 0.0);
      const v2 = Offset(10.0, 10.0);

      expect(v1.lerpTo(v2, 0.0), const Offset(0.0, 0.0));
      expect(v1.lerpTo(v2, 0.5).dx, closeTo(5.0, 0.0001));
      expect(v1.lerpTo(v2, 0.5).dy, closeTo(5.0, 0.0001));
      expect(v1.lerpTo(v2, 1.0).dx, closeTo(10.0, 0.0001));
      expect(v1.lerpTo(v2, 1.0).dy, closeTo(10.0, 0.0001));
    });

    test('rotate rotates vector around origin', () {
      const v = Offset(1.0, 0.0);

      // Rotate 90 degrees
      final rotated90 = v.rotate(math.pi / 2);
      expect(rotated90.dx, closeTo(0.0, 0.0001));
      expect(rotated90.dy, closeTo(1.0, 0.0001));

      // Rotate 180 degrees
      final rotated180 = v.rotate(math.pi);
      expect(rotated180.dx, closeTo(-1.0, 0.0001));
      expect(rotated180.dy, closeTo(0.0, 0.0001));
    });

    test('rotateAbout rotates vector around a point', () {
      const v = Offset(2.0, 0.0);
      const center = Offset(1.0, 0.0);

      // Rotate 90 degrees around (1, 0)
      final rotated = v.rotateAbout(center, math.pi / 2);
      expect(rotated.dx, closeTo(1.0, 0.0001));
      expect(rotated.dy, closeTo(1.0, 0.0001));
    });

    test('midpointTo returns midpoint', () {
      const v1 = Offset(0.0, 0.0);
      const v2 = Offset(10.0, 10.0);
      expect(v1.midpointTo(v2).dx, closeTo(5.0, 0.0001));
      expect(v1.midpointTo(v2).dy, closeTo(5.0, 0.0001));
    });

    test('distTo returns distance', () {
      const v1 = Offset(0.0, 0.0);
      const v2 = Offset(3.0, 4.0);
      expect(v1.distTo(v2), 5.0);
    });

    test('squareDistTo returns squared distance', () {
      const v1 = Offset(0.0, 0.0);
      const v2 = Offset(3.0, 4.0);
      expect(v1.squareDistTo(v2), 25.0);
    });

    test('dot returns dot product', () {
      const v1 = Offset(1.0, 2.0);
      const v2 = Offset(3.0, 4.0);
      expect(v1.dot(v2), 11.0); // 1*3 + 2*4
    });

    test('transform applies matrix transformation', () {
      const v = Offset(1.0, 0.0);

      // Identity transform
      expect(v.transform(MatrixOps.identity), v);

      // Translation
      final translated = v.transform(MatrixOps.translate(5.0, 10.0));
      expect(translated, const Offset(6.0, 10.0));

      // Scale
      final scaled = v.transform(MatrixOps.scale(2.0, 3.0));
      expect(scaled, const Offset(2.0, 0.0));
    });
  });

  group('MatrixOps', () {
    test('identity is the identity matrix', () {
      const v = Offset(5.0, 7.0);
      expect(v.transform(MatrixOps.identity), v);
    });

    test('create creates a matrix with specified values', () {
      final m = MatrixOps.create(a: 2, d: 3);
      const v = Offset(1.0, 1.0);
      expect(v.transform(m), const Offset(2.0, 3.0));
    });

    test('translate creates translation matrix', () {
      final m = MatrixOps.translate(5.0, 10.0);
      const v = Offset(1.0, 2.0);
      expect(v.transform(m), const Offset(6.0, 12.0));
    });

    test('scale creates scaling matrix', () {
      final m = MatrixOps.scale(2.0, 3.0);
      const v = Offset(4.0, 5.0);
      expect(v.transform(m), const Offset(8.0, 15.0));
    });

    test('rotation creates rotation matrix', () {
      final m = MatrixOps.rotation(math.pi / 2);
      const v = Offset(1.0, 0.0);
      final result = v.transform(m);
      expect(result.dx, closeTo(0.0, 0.0001));
      expect(result.dy, closeTo(1.0, 0.0001));
    });

    test('shear creates shear matrix', () {
      final m = MatrixOps.shear(1.0, 0.0);
      const v = Offset(0.0, 1.0);
      expect(v.transform(m), const Offset(1.0, 1.0));
    });

    test('mult multiplies matrices correctly', () {
      // Scale by 2, then translate by (10, 10)
      final scale = MatrixOps.scale(2.0, 2.0);
      final translate = MatrixOps.translate(10.0, 10.0);
      final combined = MatrixOps.mult(translate, scale);

      const v = Offset(1.0, 1.0);
      // First scale: (2, 2), then translate: (12, 12)
      expect(v.transform(combined), const Offset(12.0, 12.0));
    });

    test('det calculates determinant', () {
      // Identity has determinant 1
      expect(MatrixOps.det(MatrixOps.identity), 1.0);

      // Scale by 2 in both directions has determinant 4
      expect(MatrixOps.det(MatrixOps.scale(2.0, 2.0)), 4.0);

      // Rotation has determinant 1 (preserves area)
      expect(MatrixOps.det(MatrixOps.rotation(math.pi / 4)), closeTo(1.0, 0.0001));
    });

    test('invert returns inverse matrix', () {
      final m = MatrixOps.translate(5.0, 10.0);
      final inverse = MatrixOps.invert(m);

      expect(inverse, isNotNull);

      const v = Offset(1.0, 1.0);
      final transformed = v.transform(m);
      final restored = transformed.transform(inverse!);

      expect(restored.dx, closeTo(v.dx, 0.0001));
      expect(restored.dy, closeTo(v.dy, 0.0001));
    });

    test('invert returns null for degenerate matrix', () {
      // Scale by 0 in one direction creates a degenerate matrix
      final degenerate = MatrixOps.scale(0.0, 1.0);
      expect(MatrixOps.invert(degenerate), isNull);
    });

    test('toCSS formats matrix correctly', () {
      final m = MatrixOps.identity;
      expect(MatrixOps.toCSS(m), 'matrix(1.0, 0.0, 0.0, 1.0, 0.0, 0.0)');
    });
  });

  group('MatrixBuilder', () {
    test('creates identity by default', () {
      final m = MatrixBuilder().build();
      expect(m, MatrixOps.identity);
    });

    test('chains transformations', () {
      final m = MatrixBuilder()
          .translate(10.0, 10.0)
          .scale(2.0, 2.0)
          .build();

      const v = Offset(0.0, 0.0);
      // First translate to (10, 10), then scale: (20, 20)
      expect(v.transform(m), const Offset(20.0, 20.0));
    });

    test('from starts with existing matrix', () {
      final initial = MatrixOps.translate(5.0, 5.0);
      final m = MatrixBuilder.from(initial)
          .translate(5.0, 5.0)
          .build();

      const v = Offset(0.0, 0.0);
      expect(v.transform(m), const Offset(10.0, 10.0));
    });

    test('rotate works correctly', () {
      final m = MatrixBuilder().rotate(math.pi / 2).build();
      const v = Offset(1.0, 0.0);
      final result = v.transform(m);
      expect(result.dx, closeTo(0.0, 0.0001));
      expect(result.dy, closeTo(1.0, 0.0001));
    });

    test('shear works correctly', () {
      final m = MatrixBuilder().shear(1.0, 0.0).build();
      const v = Offset(0.0, 1.0);
      expect(v.transform(m), const Offset(1.0, 1.0));
    });

    test('mult applies arbitrary matrix', () {
      final custom = MatrixOps.scale(3.0, 3.0);
      final m = MatrixBuilder().mult(custom).build();

      const v = Offset(1.0, 1.0);
      expect(v.transform(m), const Offset(3.0, 3.0));
    });
  });
}
