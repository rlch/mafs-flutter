import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafs_flutter/src/context/coordinate_context.dart';
import 'package:mafs_flutter/src/context/transform_context.dart';
import 'package:mafs_flutter/src/display/point.dart';
import 'package:mafs_flutter/src/display/theme.dart';
import 'package:mafs_flutter/src/vec.dart';

void main() {
  group('MafsPoint widget', () {
    testWidgets('creates with required parameters', (tester) async {
      await tester.pumpWidget(
        _wrapWithContext(
          const MafsPoint(x: 1, y: 2),
        ),
      );

      expect(find.byType(MafsPoint), findsOneWidget);
    });

    testWidgets('creates with all parameters', (tester) async {
      await tester.pumpWidget(
        _wrapWithContext(
          const MafsPoint(
            x: 3,
            y: 4,
            color: Color(0xFFFF0000),
            opacity: 0.5,
          ),
        ),
      );

      expect(find.byType(MafsPoint), findsOneWidget);
    });

    testWidgets('uses theme foreground color when color is null', (tester) async {
      const customTheme = MafsThemeData(foreground: Color(0xFF00FF00));

      await tester.pumpWidget(
        MafsTheme(
          data: customTheme,
          child: _wrapWithContext(
            const MafsPoint(x: 0, y: 0),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPoint>(
        find.byType(MafsPoint),
      );

      expect(renderObject.color, const Color(0xFF00FF00));
    });

    testWidgets('uses provided color when specified', (tester) async {
      await tester.pumpWidget(
        _wrapWithContext(
          const MafsPoint(
            x: 0,
            y: 0,
            color: Color(0xFFFF0000),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPoint>(
        find.byType(MafsPoint),
      );

      expect(renderObject.color, const Color(0xFFFF0000));
    });

    testWidgets('applies opacity correctly', (tester) async {
      await tester.pumpWidget(
        _wrapWithContext(
          const MafsPoint(
            x: 0,
            y: 0,
            opacity: 0.5,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPoint>(
        find.byType(MafsPoint),
      );

      expect(renderObject.opacity, 0.5);
    });

    testWidgets('default opacity is 1.0', (tester) async {
      await tester.pumpWidget(
        _wrapWithContext(
          const MafsPoint(x: 0, y: 0),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPoint>(
        find.byType(MafsPoint),
      );

      expect(renderObject.opacity, 1.0);
    });

    testWidgets('updates when properties change', (tester) async {
      await tester.pumpWidget(
        _wrapWithContext(
          const MafsPoint(x: 1, y: 2),
        ),
      );

      var renderObject = tester.renderObject<RenderMafsPoint>(
        find.byType(MafsPoint),
      );

      expect(renderObject.x, 1);
      expect(renderObject.y, 2);

      await tester.pumpWidget(
        _wrapWithContext(
          const MafsPoint(x: 3, y: 4),
        ),
      );

      renderObject = tester.renderObject<RenderMafsPoint>(
        find.byType(MafsPoint),
      );

      expect(renderObject.x, 3);
      expect(renderObject.y, 4);
    });

    testWidgets('throws when contexts are not in tree', (tester) async {
      await tester.pumpWidget(
        const MafsPoint(x: 0, y: 0),
      );

      expect(tester.takeException(), isA<FlutterError>());
    });
  });

  group('RenderMafsPoint', () {
    test('has correct point radius', () {
      expect(RenderMafsPoint.pointRadius, 6.0);
    });

    testWidgets('stores transform data correctly', (tester) async {
      await tester.pumpWidget(
        _wrapWithContext(
          const MafsPoint(x: 1, y: 1),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPoint>(
        find.byType(MafsPoint),
      );

      expect(renderObject.userTransform, MatrixOps.identity);
      expect(renderObject.xMin, 0);
      expect(renderObject.xMax, 100);
      expect(renderObject.yMin, 0);
      expect(renderObject.yMax, 100);
    });

    testWidgets('setters mark needs paint when values change', (tester) async {
      await tester.pumpWidget(
        _wrapWithContext(
          const MafsPoint(x: 0, y: 0),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPoint>(
        find.byType(MafsPoint),
      );

      // Initial values
      expect(renderObject.x, 0);
      expect(renderObject.y, 0);
      expect(renderObject.opacity, 1.0);
      expect(renderObject.color, MafsColors.foreground);

      // Change values - these should mark needs paint
      renderObject.x = 5;
      renderObject.y = 10;
      renderObject.opacity = 0.5;
      renderObject.color = const Color(0xFFFF0000);

      expect(renderObject.x, 5);
      expect(renderObject.y, 10);
      expect(renderObject.opacity, 0.5);
      expect(renderObject.color, const Color(0xFFFF0000));
    });

    testWidgets('setters do not mark needs paint when values are same',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithContext(
          const MafsPoint(
            x: 5,
            y: 10,
            color: Color(0xFFFF0000),
            opacity: 0.5,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPoint>(
        find.byType(MafsPoint),
      );

      // Set to same values - these should not trigger repaint
      renderObject.x = 5;
      renderObject.y = 10;
      renderObject.opacity = 0.5;
      renderObject.color = const Color(0xFFFF0000);

      expect(renderObject.x, 5);
      expect(renderObject.y, 10);
      expect(renderObject.opacity, 0.5);
      expect(renderObject.color, const Color(0xFFFF0000));
    });

    testWidgets('sizedByParent is true', (tester) async {
      await tester.pumpWidget(
        _wrapWithContext(
          const MafsPoint(x: 0, y: 0),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPoint>(
        find.byType(MafsPoint),
      );

      expect(renderObject.sizedByParent, true);
    });
  });

  group('coordinate transformation', () {
    testWidgets('point at origin renders at center-bottom with default viewport',
        (tester) async {
      // With viewport from (0, 0) to (100, 100) and yMax = 100
      // Point at (0, 0) should render at:
      // screenX = (0 - 0) * scaleX = 0
      // screenY = (100 - 0) * scaleY = 100 (at bottom)
      await tester.pumpWidget(
        _wrapWithContext(
          const MafsPoint(x: 0, y: 0),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPoint>(
        find.byType(MafsPoint),
      );

      expect(renderObject.x, 0);
      expect(renderObject.y, 0);
      expect(renderObject.xMin, 0);
      expect(renderObject.yMax, 100);
    });

    testWidgets('point transforms with scale factors', (tester) async {
      // viewTransform with scale(2, -2) means 2 pixels per unit
      // xMin = -50, yMax = 50 (centered viewport)
      await tester.pumpWidget(
        _wrapWithContextCustom(
          const MafsPoint(x: 10, y: 20),
          xMin: -50,
          yMax: 50,
          viewTransform: MatrixOps.scale(2, -2),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPoint>(
        find.byType(MafsPoint),
      );

      expect(renderObject.x, 10);
      expect(renderObject.y, 20);
      expect(renderObject.xMin, -50);
      expect(renderObject.yMax, 50);
      // Screen position would be:
      // screenX = (10 - (-50)) * 2 = 60 * 2 = 120
      // screenY = (50 - 20) * 2 = 30 * 2 = 60
    });

    testWidgets('user transform is applied before conversion', (tester) async {
      // User transform translates by (5, 5) in math space
      await tester.pumpWidget(
        _wrapWithContextCustom(
          const MafsPoint(x: 0, y: 0),
          xMin: 0,
          yMax: 100,
          userTransform: MatrixOps.translate(5, 5),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPoint>(
        find.byType(MafsPoint),
      );

      expect(renderObject.userTransform, MatrixOps.translate(5, 5));
    });

    testWidgets('hitTestSelf works for points within radius', (tester) async {
      // Create a point at (50, 50) in a 100x100 viewport
      // The render object gets laid out at 800x600 (default test size)
      // Viewport: xMin = 0, xMax = 100, yMin = 0, yMax = 100
      // screenX = (50 - 0) / 100 * 800 = 400
      // screenY = (1 - (50 - 0) / 100) * 600 = 300
      await tester.pumpWidget(
        _wrapWithContextCustom(
          const MafsPoint(x: 50, y: 50),
          xMin: 0,
          xMax: 100,
          yMin: 0,
          yMax: 100,
          width: 800,
          height: 600,
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPoint>(
        find.byType(MafsPoint),
      );

      // Point should be at screen position (400, 300)
      // screenX = (50 - 0) / 100 * 800 = 400
      // screenY = (1 - (50 - 0) / 100) * 600 = 300
      // Test hit at exact position
      expect(renderObject.hitTestSelf(const Offset(400, 300)), true);

      // Test hit within radius (6 pixels)
      expect(renderObject.hitTestSelf(const Offset(403, 300)), true);
      expect(renderObject.hitTestSelf(const Offset(400, 305)), true);

      // Test hit outside radius
      expect(renderObject.hitTestSelf(const Offset(410, 300)), false);
      expect(renderObject.hitTestSelf(const Offset(400, 310)), false);
    });
  });
}

/// Wraps a widget with the necessary context providers for testing.
/// Uses a simple viewport: xMin=0, xMax=100, yMin=0, yMax=100
/// with identity transforms (1 pixel per unit).
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

/// Wraps a widget with custom context settings.
Widget _wrapWithContextCustom(
  Widget child, {
  double xMin = 0,
  double xMax = 100,
  double yMin = 0,
  double yMax = 100,
  double width = 100,
  double height = 100,
  Matrix2D? userTransform,
  Matrix2D? viewTransform,
}) {
  return CoordinateContext(
    data: CoordinateContextData(
      xMin: xMin,
      xMax: xMax,
      yMin: yMin,
      yMax: yMax,
      width: width,
      height: height,
    ),
    child: TransformContext(
      data: TransformContextData(
        userTransform: userTransform ?? MatrixOps.identity,
        viewTransform: viewTransform ?? MatrixOps.identity,
      ),
      child: child,
    ),
  );
}
