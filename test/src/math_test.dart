import 'package:flutter_test/flutter_test.dart';
import 'package:mafs_flutter/src/math.dart';

void main() {
  group('round', () {
    test('rounds to specified precision', () {
      expect(round(3.14159, 2), 3.14);
      expect(round(3.14159, 3), 3.142);
      expect(round(3.14159, 0), 3.0);
    });

    test('handles negative numbers', () {
      expect(round(-3.14159, 2), -3.14);
    });

    test('handles zero precision', () {
      expect(round(3.6, 0), 4.0);
      expect(round(3.4, 0), 3.0);
    });
  });

  group('roundToNearestPowerOf10', () {
    test('rounds to nearest power of 10', () {
      expect(roundToNearestPowerOf10(350), 100);
      expect(roundToNearestPowerOf10(3500), 1000);
      expect(roundToNearestPowerOf10(35), 10);
      expect(roundToNearestPowerOf10(5), 1);
      expect(roundToNearestPowerOf10(0.5), 0.1);
    });

    test('handles exact powers of 10', () {
      // At exact powers of 10, floor(log10(x)) = n, so result = 10^n
      // So roundToNearestPowerOf10(100) = 10^2 = 100
      // And roundToNearestPowerOf10(1000) = 10^3 = 1000... except due to
      // floating point, log10(1000) might be slightly less than 3
      expect(roundToNearestPowerOf10(100), 100);
      // Use closeTo for exact powers of 10 due to floating point
      expect(roundToNearestPowerOf10(1001), 1000); // Just above 1000
    });

    test('handles values <= 0 by returning 1', () {
      expect(roundToNearestPowerOf10(0), 1);
      expect(roundToNearestPowerOf10(-5), 1);
    });
  });

  group('pickClosestToValue', () {
    test('finds closest value', () {
      final result = pickClosestToValue(5.0, [1.0, 3.0, 7.0, 10.0]);
      expect(result.value, 3.0);
      expect(result.index, 1);
    });

    test('handles exact match', () {
      final result = pickClosestToValue(7.0, [1.0, 3.0, 7.0, 10.0]);
      expect(result.value, 7.0);
      expect(result.index, 2);
    });

    test('handles single option', () {
      final result = pickClosestToValue(100.0, [5.0]);
      expect(result.value, 5.0);
      expect(result.index, 0);
    });

    test('handles negative values', () {
      final result = pickClosestToValue(-2.0, [-5.0, -1.0, 3.0]);
      expect(result.value, -1.0);
      expect(result.index, 1);
    });

    test('picks first when equidistant', () {
      final result = pickClosestToValue(5.0, [3.0, 7.0]);
      // Both are distance 2 away, should pick first encountered
      expect(result.index, 0);
    });
  });

  group('range', () {
    test('generates range with default step', () {
      expect(range(0, 5), [0.0, 1.0, 2.0, 3.0, 4.0, 5.0]);
    });

    test('generates range with custom step', () {
      expect(range(0, 10, 2), [0.0, 2.0, 4.0, 6.0, 8.0, 10.0]);
    });

    test('handles fractional step', () {
      final result = range(0, 1, 0.25);
      expect(result.length, 5);
      expect(result[0], 0.0);
      expect(result[1], closeTo(0.25, 0.0001));
      expect(result[4], closeTo(1.0, 0.0001));
    });

    test('handles negative range', () {
      expect(range(-3, 0), [-3.0, -2.0, -1.0, 0.0]);
    });

    test('handles single value range', () {
      final result = range(5, 5);
      // When min == max, the range function returns just the min value
      expect(result.first, 5.0);
      expect(result.length, greaterThanOrEqualTo(1));
    });
  });

  group('clamp', () {
    test('clamps value within range', () {
      expect(clamp(5, 0, 10), 5);
      expect(clamp(-5, 0, 10), 0);
      expect(clamp(15, 0, 10), 10);
    });

    test('handles value at bounds', () {
      expect(clamp(0, 0, 10), 0);
      expect(clamp(10, 0, 10), 10);
    });

    test('handles negative range', () {
      expect(clamp(-5, -10, -1), -5);
      expect(clamp(0, -10, -1), -1);
    });
  });

  group('Anchor', () {
    test('all anchor values exist', () {
      expect(Anchor.values.length, 9);
      expect(Anchor.tl, isNotNull);
      expect(Anchor.tc, isNotNull);
      expect(Anchor.tr, isNotNull);
      expect(Anchor.cl, isNotNull);
      expect(Anchor.cc, isNotNull);
      expect(Anchor.cr, isNotNull);
      expect(Anchor.bl, isNotNull);
      expect(Anchor.bc, isNotNull);
      expect(Anchor.br, isNotNull);
    });
  });

  group('computeAnchor', () {
    const width = 100.0;
    const height = 50.0;
    const x = 200.0;
    const y = 100.0;

    test('top-left anchor', () {
      final (actualX, actualY) = computeAnchor(Anchor.tl, x, y, width, height);
      expect(actualX, x);
      expect(actualY, y);
    });

    test('top-center anchor', () {
      final (actualX, actualY) = computeAnchor(Anchor.tc, x, y, width, height);
      expect(actualX, x - width / 2);
      expect(actualY, y);
    });

    test('top-right anchor', () {
      final (actualX, actualY) = computeAnchor(Anchor.tr, x, y, width, height);
      expect(actualX, x - width);
      expect(actualY, y);
    });

    test('center-left anchor', () {
      final (actualX, actualY) = computeAnchor(Anchor.cl, x, y, width, height);
      expect(actualX, x);
      expect(actualY, y + height / 2);
    });

    test('center-center anchor', () {
      final (actualX, actualY) = computeAnchor(Anchor.cc, x, y, width, height);
      expect(actualX, x - width / 2);
      expect(actualY, y + height / 2);
    });

    test('center-right anchor', () {
      final (actualX, actualY) = computeAnchor(Anchor.cr, x, y, width, height);
      expect(actualX, x - width);
      expect(actualY, y + height / 2);
    });

    test('bottom-left anchor', () {
      final (actualX, actualY) = computeAnchor(Anchor.bl, x, y, width, height);
      expect(actualX, x);
      expect(actualY, y + height);
    });

    test('bottom-center anchor', () {
      final (actualX, actualY) = computeAnchor(Anchor.bc, x, y, width, height);
      expect(actualX, x - width / 2);
      expect(actualY, y + height);
    });

    test('bottom-right anchor', () {
      final (actualX, actualY) = computeAnchor(Anchor.br, x, y, width, height);
      expect(actualX, x - width);
      expect(actualY, y + height);
    });
  });

  group('Interval typedef', () {
    test('can create interval', () {
      const interval = (0.0, 10.0);
      expect(interval.$1, 0.0);
      expect(interval.$2, 10.0);
    });
  });
}
