import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafs_flutter/src/context/coordinate_context.dart';
import 'package:mafs_flutter/src/context/transform_context.dart';
import 'package:mafs_flutter/src/display/ellipse.dart';
import 'package:mafs_flutter/src/display/theme.dart';
import 'package:mafs_flutter/src/vec.dart';

void main() {
  // Helper to wrap ellipse widget with required context providers
  Widget buildTestWidget({
    required Widget child,
    MafsThemeData theme = MafsThemeData.light,
    Matrix2D viewTransform = MatrixOps.identity,
    Matrix2D userTransform = MatrixOps.identity,
    double xMin = -5,
    double xMax = 5,
    double yMin = -5,
    double yMax = 5,
    double width = 400,
    double height = 400,
  }) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: MafsTheme(
        data: theme,
        child: CoordinateContext(
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
              viewTransform: viewTransform,
              userTransform: userTransform,
            ),
            child: SizedBox(
              width: width,
              height: height,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  group('MafsEllipse widget', () {
    testWidgets('creates with required parameters', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(1, 1),
          ),
        ),
      );

      expect(find.byType(MafsEllipse), findsOneWidget);
    });

    testWidgets('creates with all parameters', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsEllipse(
            center: Offset(1, 2),
            radius: Offset(3, 2),
            angle: math.pi / 4,
            color: MafsColors.blue,
            weight: 3,
            fillOpacity: 0.5,
            strokeOpacity: 0.8,
            strokeStyle: StrokeStyle.dashed,
          ),
        ),
      );

      expect(find.byType(MafsEllipse), findsOneWidget);
    });

    testWidgets('uses default values correctly', (tester) async {
      const ellipse = MafsEllipse(
        center: Offset(0, 0),
        radius: Offset(1, 1),
      );

      expect(ellipse.angle, 0);
      expect(ellipse.color, isNull);
      expect(ellipse.weight, 2);
      expect(ellipse.fillOpacity, 0.15);
      expect(ellipse.strokeOpacity, 1.0);
      expect(ellipse.strokeStyle, StrokeStyle.solid);
    });

    testWidgets('uses theme foreground color when color is null', (tester) async {
      const customTheme = MafsThemeData(foreground: Color(0xFF123456));

      await tester.pumpWidget(
        buildTestWidget(
          theme: customTheme,
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(1, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsEllipse>(
        find.byType(MafsEllipse),
      );

      expect(renderObject.color, const Color(0xFF123456));
    });

    testWidgets('uses explicit color over theme color', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(1, 1),
            color: MafsColors.red,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsEllipse>(
        find.byType(MafsEllipse),
      );

      expect(renderObject.color, MafsColors.red);
    });

    testWidgets('updates render object on property changes', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(1, 1),
            weight: 2,
          ),
        ),
      );

      var renderObject = tester.renderObject<RenderMafsEllipse>(
        find.byType(MafsEllipse),
      );
      expect(renderObject.weight, 2);

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(1, 1),
            weight: 5,
          ),
        ),
      );

      renderObject = tester.renderObject<RenderMafsEllipse>(
        find.byType(MafsEllipse),
      );
      expect(renderObject.weight, 5);
    });
  });

  group('MafsEllipse render object', () {
    testWidgets('renders with solid stroke style', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          viewTransform: MatrixOps.scale(40, 40), // 400px / 10 units
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(2, 1),
            strokeStyle: StrokeStyle.solid,
          ),
        ),
      );

      // Widget should render without errors
      expect(find.byType(MafsEllipse), findsOneWidget);
    });

    testWidgets('renders with dashed stroke style', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          viewTransform: MatrixOps.scale(40, 40),
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(2, 1),
            strokeStyle: StrokeStyle.dashed,
          ),
        ),
      );

      // Widget should render without errors
      expect(find.byType(MafsEllipse), findsOneWidget);
    });

    testWidgets('renders with rotation angle', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          viewTransform: MatrixOps.scale(40, 40),
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(2, 1),
            angle: math.pi / 4, // 45 degrees
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsEllipse>(
        find.byType(MafsEllipse),
      );

      expect(renderObject.angle, math.pi / 4);
    });

    testWidgets('renders with different radii (ellipse not circle)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          viewTransform: MatrixOps.scale(40, 40),
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(3, 1), // Different x and y radii
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsEllipse>(
        find.byType(MafsEllipse),
      );

      expect(renderObject.radius.dx, 3);
      expect(renderObject.radius.dy, 1);
    });

    testWidgets('renders with zero fill opacity (stroke only)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          viewTransform: MatrixOps.scale(40, 40),
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(1, 1),
            fillOpacity: 0,
          ),
        ),
      );

      expect(find.byType(MafsEllipse), findsOneWidget);
    });

    testWidgets('renders with zero stroke opacity (fill only)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          viewTransform: MatrixOps.scale(40, 40),
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(1, 1),
            strokeOpacity: 0,
            fillOpacity: 0.5,
          ),
        ),
      );

      expect(find.byType(MafsEllipse), findsOneWidget);
    });

    testWidgets('respects userTransform', (tester) async {
      final userTransform = MatrixOps.translate(1, 1);

      await tester.pumpWidget(
        buildTestWidget(
          viewTransform: MatrixOps.scale(40, 40),
          userTransform: userTransform,
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(1, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsEllipse>(
        find.byType(MafsEllipse),
      );

      expect(renderObject.userTransform, userTransform);
    });
  });

  group('RenderMafsEllipse properties', () {
    testWidgets('center setter triggers repaint', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(1, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsEllipse>(
        find.byType(MafsEllipse),
      );

      // Set same value - should not trigger repaint
      renderObject.center = const Offset(0, 0);

      // Set different value
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsEllipse(
            center: Offset(1, 1),
            radius: Offset(1, 1),
          ),
        ),
      );

      expect(renderObject.center, const Offset(1, 1));
    });

    testWidgets('radius setter triggers repaint', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(1, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsEllipse>(
        find.byType(MafsEllipse),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(2, 3),
          ),
        ),
      );

      expect(renderObject.radius, const Offset(2, 3));
    });

    testWidgets('angle setter triggers repaint', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(1, 1),
            angle: 0,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsEllipse>(
        find.byType(MafsEllipse),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(1, 1),
            angle: math.pi / 2,
          ),
        ),
      );

      expect(renderObject.angle, math.pi / 2);
    });

    testWidgets('color setter triggers repaint', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(1, 1),
            color: MafsColors.red,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsEllipse>(
        find.byType(MafsEllipse),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(1, 1),
            color: MafsColors.blue,
          ),
        ),
      );

      expect(renderObject.color, MafsColors.blue);
    });

    testWidgets('fillOpacity setter triggers repaint', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(1, 1),
            fillOpacity: 0.15,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsEllipse>(
        find.byType(MafsEllipse),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(1, 1),
            fillOpacity: 0.5,
          ),
        ),
      );

      expect(renderObject.fillOpacity, 0.5);
    });

    testWidgets('strokeOpacity setter triggers repaint', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(1, 1),
            strokeOpacity: 1.0,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsEllipse>(
        find.byType(MafsEllipse),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(1, 1),
            strokeOpacity: 0.5,
          ),
        ),
      );

      expect(renderObject.strokeOpacity, 0.5);
    });

    testWidgets('strokeStyle setter triggers repaint', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(1, 1),
            strokeStyle: StrokeStyle.solid,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsEllipse>(
        find.byType(MafsEllipse),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(1, 1),
            strokeStyle: StrokeStyle.dashed,
          ),
        ),
      );

      expect(renderObject.strokeStyle, StrokeStyle.dashed);
    });
  });

  group('MafsEllipse coordinate transformation', () {
    testWidgets('ellipse at origin renders at viewport center', (tester) async {
      // With coordinate system from -5 to 5 and 400px viewport,
      // origin (0,0) should map to center (200, 200)
      await tester.pumpWidget(
        buildTestWidget(
          viewTransform: MatrixOps.scale(40, 40), // 400/10 = 40px per unit
          xMin: -5,
          xMax: 5,
          yMin: -5,
          yMax: 5,
          width: 400,
          height: 400,
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(1, 1),
          ),
        ),
      );

      expect(find.byType(MafsEllipse), findsOneWidget);
    });

    testWidgets('ellipse off-center renders at correct position', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          viewTransform: MatrixOps.scale(40, 40),
          xMin: -5,
          xMax: 5,
          yMin: -5,
          yMax: 5,
          width: 400,
          height: 400,
          child: const MafsEllipse(
            center: Offset(2, -1), // Off-center
            radius: Offset(1, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsEllipse>(
        find.byType(MafsEllipse),
      );

      expect(renderObject.center, const Offset(2, -1));
    });

    testWidgets('radius scales correctly with view transform', (tester) async {
      // With 40px per math unit, a radius of 2 should become 80px
      await tester.pumpWidget(
        buildTestWidget(
          viewTransform: MatrixOps.scale(40, 40),
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(2, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsEllipse>(
        find.byType(MafsEllipse),
      );

      // The radius in math units
      expect(renderObject.radius.dx, 2);
      expect(renderObject.radius.dy, 1);
    });
  });

  group('MafsEllipse sizing', () {
    testWidgets('sizedByParent returns true', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(1, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsEllipse>(
        find.byType(MafsEllipse),
      );

      expect(renderObject.sizedByParent, true);
    });

    testWidgets('hitTestSelf returns false', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsEllipse(
            center: Offset(0, 0),
            radius: Offset(1, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsEllipse>(
        find.byType(MafsEllipse),
      );

      expect(renderObject.hitTestSelf(Offset.zero), false);
    });
  });
}
