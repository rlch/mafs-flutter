import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafs_flutter/mafs_flutter.dart';

void main() {
  group('MafsTransform', () {
    testWidgets('provides transformed context to children', (tester) async {
      TransformContextData? capturedData;

      await tester.pumpWidget(
        _wrapWithContext(
          MafsTransform(
            translate: const Offset(2, 3),
            child: Builder(
              builder: (context) {
                capturedData = TransformContext.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(capturedData, isNotNull);
      // Translation matrix: (1, 0, tx, 0, 1, ty)
      expect(capturedData!.userTransform.$3, 2.0); // tx
      expect(capturedData!.userTransform.$6, 3.0); // ty
    });

    testWidgets('applies translation transform', (tester) async {
      TransformContextData? capturedData;

      await tester.pumpWidget(
        _wrapWithContext(
          MafsTransform(
            translate: const Offset(5, -3),
            child: Builder(
              builder: (context) {
                capturedData = TransformContext.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(capturedData, isNotNull);
      final transform = capturedData!.userTransform;

      // Test by transforming a point
      final point = const Offset(0, 0).transform(transform);
      expect(point.dx, closeTo(5, 0.001));
      expect(point.dy, closeTo(-3, 0.001));
    });

    testWidgets('applies scale transform', (tester) async {
      TransformContextData? capturedData;

      await tester.pumpWidget(
        _wrapWithContext(
          MafsTransform(
            scale: const Offset(2, 3),
            child: Builder(
              builder: (context) {
                capturedData = TransformContext.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(capturedData, isNotNull);
      final transform = capturedData!.userTransform;

      // Test by transforming a point
      final point = const Offset(1, 1).transform(transform);
      expect(point.dx, closeTo(2, 0.001));
      expect(point.dy, closeTo(3, 0.001));
    });

    testWidgets('applies uniform scale', (tester) async {
      TransformContextData? capturedData;

      await tester.pumpWidget(
        _wrapWithContext(
          MafsTransform(
            scale: const Offset(2, 2),
            child: Builder(
              builder: (context) {
                capturedData = TransformContext.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(capturedData, isNotNull);
      final transform = capturedData!.userTransform;

      final point = const Offset(3, 4).transform(transform);
      expect(point.dx, closeTo(6, 0.001));
      expect(point.dy, closeTo(8, 0.001));
    });

    testWidgets('applies rotation transform', (tester) async {
      TransformContextData? capturedData;

      await tester.pumpWidget(
        _wrapWithContext(
          MafsTransform(
            rotate: math.pi / 2, // 90 degrees
            child: Builder(
              builder: (context) {
                capturedData = TransformContext.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(capturedData, isNotNull);
      final transform = capturedData!.userTransform;

      // (1, 0) rotated 90 degrees CCW should be (0, 1)
      final point = const Offset(1, 0).transform(transform);
      expect(point.dx, closeTo(0, 0.001));
      expect(point.dy, closeTo(1, 0.001));
    });

    testWidgets('applies shear transform', (tester) async {
      TransformContextData? capturedData;

      await tester.pumpWidget(
        _wrapWithContext(
          MafsTransform(
            shear: const Offset(1, 0), // Horizontal shear
            child: Builder(
              builder: (context) {
                capturedData = TransformContext.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(capturedData, isNotNull);
      final transform = capturedData!.userTransform;

      // (0, 1) with horizontal shear of 1 should become (1, 1)
      final point = const Offset(0, 1).transform(transform);
      expect(point.dx, closeTo(1, 0.001));
      expect(point.dy, closeTo(1, 0.001));
    });

    testWidgets('applies custom matrix', (tester) async {
      TransformContextData? capturedData;

      // Custom matrix that scales by 3
      const customMatrix = (3.0, 0.0, 0.0, 0.0, 3.0, 0.0);

      await tester.pumpWidget(
        _wrapWithContext(
          MafsTransform(
            matrix: customMatrix,
            child: Builder(
              builder: (context) {
                capturedData = TransformContext.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(capturedData, isNotNull);
      final transform = capturedData!.userTransform;

      final point = const Offset(2, 2).transform(transform);
      expect(point.dx, closeTo(6, 0.001));
      expect(point.dy, closeTo(6, 0.001));
    });

    testWidgets('composes multiple transforms in correct order', (tester) async {
      TransformContextData? capturedData;

      // Order is: matrix, translate, scale, rotate, shear
      // With translate(2, 0) then scale(2, 2):
      // Point (0, 0) -> translate -> (2, 0) -> scale -> (4, 0)
      await tester.pumpWidget(
        _wrapWithContext(
          MafsTransform(
            translate: const Offset(2, 0),
            scale: const Offset(2, 2),
            child: Builder(
              builder: (context) {
                capturedData = TransformContext.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(capturedData, isNotNull);
      final transform = capturedData!.userTransform;

      final point = const Offset(0, 0).transform(transform);
      expect(point.dx, closeTo(4, 0.001));
      expect(point.dy, closeTo(0, 0.001));
    });

    testWidgets('nested transforms compose correctly', (tester) async {
      TransformContextData? capturedData;

      await tester.pumpWidget(
        _wrapWithContext(
          MafsTransform(
            translate: const Offset(1, 0),
            child: MafsTransform(
              translate: const Offset(2, 0),
              child: Builder(
                builder: (context) {
                  capturedData = TransformContext.of(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      expect(capturedData, isNotNull);
      final transform = capturedData!.userTransform;

      // Inner translate(2,0) composed with outer translate(1,0)
      // should result in total translation of (3, 0)
      final point = const Offset(0, 0).transform(transform);
      expect(point.dx, closeTo(3, 0.001));
      expect(point.dy, closeTo(0, 0.001));
    });

    testWidgets('preserves viewTransform from parent', (tester) async {
      TransformContextData? parentData;
      TransformContextData? childData;

      await tester.pumpWidget(
        _wrapWithContext(
          Builder(
            builder: (context) {
              parentData = TransformContext.of(context);
              return MafsTransform(
                translate: const Offset(1, 1),
                child: Builder(
                  builder: (context) {
                    childData = TransformContext.of(context);
                    return const SizedBox();
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(parentData, isNotNull);
      expect(childData, isNotNull);
      expect(childData!.viewTransform, equals(parentData!.viewTransform));
    });

    testWidgets('works with no transforms specified', (tester) async {
      TransformContextData? parentData;
      TransformContextData? childData;

      await tester.pumpWidget(
        _wrapWithContext(
          Builder(
            builder: (context) {
              parentData = TransformContext.of(context);
              return MafsTransform(
                child: Builder(
                  builder: (context) {
                    childData = TransformContext.of(context);
                    return const SizedBox();
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(parentData, isNotNull);
      expect(childData, isNotNull);
      // With no transforms, userTransform should be same as parent
      expect(childData!.userTransform, equals(parentData!.userTransform));
    });

    testWidgets('transforms MafsPoint position', (tester) async {
      // Verify that MafsPoint actually uses the transformed context
      await tester.pumpWidget(
        _wrapWithContext(
          MafsTransform(
            translate: const Offset(2, 2),
            child: const MafsPoint(x: 0, y: 0),
          ),
        ),
      );

      // Find the render object and verify it received the transform
      final renderObject = tester.renderObject<RenderMafsPoint>(
        find.byType(MafsPoint),
      );

      expect(renderObject.userTransform.$3, closeTo(2, 0.001)); // tx
      expect(renderObject.userTransform.$6, closeTo(2, 0.001)); // ty
    });

    testWidgets('transforms multiple children', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: _wrapWithContext(
            MafsTransform(
              translate: const Offset(1, 1),
              child: Stack(
                children: const [
                  MafsPoint(x: 0, y: 0),
                  MafsPoint(x: 1, y: 1),
                ],
              ),
            ),
          ),
        ),
      );

      final renderObjects = tester.renderObjectList<RenderMafsPoint>(
        find.byType(MafsPoint),
      );

      for (final ro in renderObjects) {
        expect(ro.userTransform.$3, closeTo(1, 0.001));
        expect(ro.userTransform.$6, closeTo(1, 0.001));
      }
    });

    testWidgets(
        'rotation around point works with translate-rotate-translate pattern',
        (tester) async {
      TransformContextData? capturedData;

      // To rotate around point (2, 0):
      // 1. Translate to origin: translate(-2, 0)
      // 2. Rotate: rotate(pi/2)
      // 3. Translate back: translate(2, 0)
      //
      // Using nested transforms (inner first):
      await tester.pumpWidget(
        _wrapWithContext(
          MafsTransform(
            translate: const Offset(2, 0), // Translate back
            child: MafsTransform(
              rotate: math.pi / 2, // Rotate
              child: MafsTransform(
                translate: const Offset(-2, 0), // Translate to origin
                child: Builder(
                  builder: (context) {
                    capturedData = TransformContext.of(context);
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        ),
      );

      expect(capturedData, isNotNull);
      final transform = capturedData!.userTransform;

      // Point (3, 0) should rotate around (2, 0) by 90 degrees to (2, 1)
      final point = const Offset(3, 0).transform(transform);
      expect(point.dx, closeTo(2, 0.001));
      expect(point.dy, closeTo(1, 0.001));

      // Point (2, 0) should stay at (2, 0) (it's the center of rotation)
      final center = const Offset(2, 0).transform(transform);
      expect(center.dx, closeTo(2, 0.001));
      expect(center.dy, closeTo(0, 0.001));
    });

    testWidgets('scale and rotate combine correctly', (tester) async {
      TransformContextData? capturedData;

      await tester.pumpWidget(
        _wrapWithContext(
          MafsTransform(
            scale: const Offset(2, 2),
            rotate: math.pi / 2,
            child: Builder(
              builder: (context) {
                capturedData = TransformContext.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(capturedData, isNotNull);
      final transform = capturedData!.userTransform;

      // (1, 0) -> scale(2,2) -> (2, 0) -> rotate 90° -> (0, 2)
      final point = const Offset(1, 0).transform(transform);
      expect(point.dx, closeTo(0, 0.001));
      expect(point.dy, closeTo(2, 0.001));
    });

    testWidgets('matrix transform is applied first', (tester) async {
      TransformContextData? capturedData;

      // Custom matrix that translates by (10, 0)
      const customMatrix = (1.0, 0.0, 10.0, 0.0, 1.0, 0.0);

      await tester.pumpWidget(
        _wrapWithContext(
          MafsTransform(
            matrix: customMatrix,
            translate: const Offset(5, 0),
            child: Builder(
              builder: (context) {
                capturedData = TransformContext.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(capturedData, isNotNull);
      final transform = capturedData!.userTransform;

      // (0, 0) -> matrix(+10, 0) -> (10, 0) -> translate(+5, 0) -> (15, 0)
      final point = const Offset(0, 0).transform(transform);
      expect(point.dx, closeTo(15, 0.001));
      expect(point.dy, closeTo(0, 0.001));
    });

    testWidgets('deeply nested transforms work correctly', (tester) async {
      TransformContextData? capturedData;

      await tester.pumpWidget(
        _wrapWithContext(
          MafsTransform(
            translate: const Offset(1, 0),
            child: MafsTransform(
              translate: const Offset(1, 0),
              child: MafsTransform(
                translate: const Offset(1, 0),
                child: MafsTransform(
                  translate: const Offset(1, 0),
                  child: Builder(
                    builder: (context) {
                      capturedData = TransformContext.of(context);
                      return const SizedBox();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(capturedData, isNotNull);
      final transform = capturedData!.userTransform;

      // Four nested translations of (1, 0) each = (4, 0) total
      final point = const Offset(0, 0).transform(transform);
      expect(point.dx, closeTo(4, 0.001));
      expect(point.dy, closeTo(0, 0.001));
    });

    testWidgets('45 degree rotation works correctly', (tester) async {
      TransformContextData? capturedData;

      await tester.pumpWidget(
        _wrapWithContext(
          MafsTransform(
            rotate: math.pi / 4, // 45 degrees
            child: Builder(
              builder: (context) {
                capturedData = TransformContext.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(capturedData, isNotNull);
      final transform = capturedData!.userTransform;

      // (1, 0) rotated 45 degrees CCW should be (√2/2, √2/2)
      final point = const Offset(1, 0).transform(transform);
      final expected = math.sqrt(2) / 2;
      expect(point.dx, closeTo(expected, 0.001));
      expect(point.dy, closeTo(expected, 0.001));
    });
  });
}

/// Wraps a widget with the necessary context providers for testing.
Widget _wrapWithContext(Widget child) {
  return CoordinateContext(
    data: const CoordinateContextData(
      xMin: 0,
      xMax: 100,
      yMin: 0,
      yMax: 100,
      width: 100,
      height: 100,
    ),
    child: TransformContext(
      data: TransformContextData(
        userTransform: MatrixOps.identity,
        viewTransform: MatrixOps.identity,
      ),
      child: child,
    ),
  );
}
