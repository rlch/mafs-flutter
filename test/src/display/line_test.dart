import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafs_flutter/src/context/coordinate_context.dart';
import 'package:mafs_flutter/src/context/transform_context.dart';
import 'package:mafs_flutter/src/display/line.dart';
import 'package:mafs_flutter/src/display/theme.dart';
import 'package:mafs_flutter/src/vec.dart';

void main() {
  // Helper to wrap widget with required context providers
  Widget buildTestWidget({
    required Widget child,
    MafsThemeData theme = MafsThemeData.light,
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
              viewTransform: MatrixOps.identity,
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

  group('Line namespace', () {
    testWidgets('Line.segment creates LineSegment widget', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: Line.segment(
            point1: const Offset(0, 0),
            point2: const Offset(1, 1),
          ),
        ),
      );

      expect(find.byType(LineSegment), findsOneWidget);
    });

    testWidgets('Line.throughPoints creates LineThroughPoints widget', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: Line.throughPoints(
            point1: const Offset(0, 0),
            point2: const Offset(1, 1),
          ),
        ),
      );

      expect(find.byType(LineThroughPoints), findsOneWidget);
    });

    testWidgets('Line.pointAngle creates LinePointAngle widget', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: Line.pointAngle(
            point: const Offset(0, 0),
            angle: math.pi / 4,
          ),
        ),
      );

      expect(find.byType(LinePointAngle), findsOneWidget);
    });

    testWidgets('Line.pointSlope creates LinePointSlope widget', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: Line.pointSlope(
            point: const Offset(0, 0),
            slope: 1,
          ),
        ),
      );

      expect(find.byType(LinePointSlope), findsOneWidget);
    });
  });

  group('LineSegment widget', () {
    testWidgets('creates with required parameters', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LineSegment(
            point1: Offset(0, 0),
            point2: Offset(1, 1),
          ),
        ),
      );

      expect(find.byType(LineSegment), findsOneWidget);
    });

    testWidgets('creates with all parameters', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LineSegment(
            point1: Offset(-1, -1),
            point2: Offset(2, 3),
            color: MafsColors.blue,
            opacity: 0.5,
            weight: 3,
            style: StrokeStyle.dashed,
          ),
        ),
      );

      expect(find.byType(LineSegment), findsOneWidget);
    });

    testWidgets('uses default values correctly', (tester) async {
      const segment = LineSegment(
        point1: Offset(0, 0),
        point2: Offset(1, 1),
      );

      expect(segment.color, isNull);
      expect(segment.opacity, 1.0);
      expect(segment.weight, 2);
      expect(segment.style, StrokeStyle.solid);
    });

    testWidgets('uses theme foreground color when color is null', (tester) async {
      const customTheme = MafsThemeData(foreground: Color(0xFF123456));

      await tester.pumpWidget(
        buildTestWidget(
          theme: customTheme,
          child: const LineSegment(
            point1: Offset(0, 0),
            point2: Offset(1, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderLineSegment>(
        find.byType(LineSegment),
      );

      expect(renderObject.color, const Color(0xFF123456));
    });

    testWidgets('uses explicit color over theme color', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LineSegment(
            point1: Offset(0, 0),
            point2: Offset(1, 1),
            color: MafsColors.red,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderLineSegment>(
        find.byType(LineSegment),
      );

      expect(renderObject.color, MafsColors.red);
    });

    testWidgets('updates render object on property changes', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LineSegment(
            point1: Offset(0, 0),
            point2: Offset(1, 1),
            weight: 2,
          ),
        ),
      );

      var renderObject = tester.renderObject<RenderLineSegment>(
        find.byType(LineSegment),
      );
      expect(renderObject.weight, 2);

      await tester.pumpWidget(
        buildTestWidget(
          child: const LineSegment(
            point1: Offset(0, 0),
            point2: Offset(1, 1),
            weight: 5,
          ),
        ),
      );

      renderObject = tester.renderObject<RenderLineSegment>(
        find.byType(LineSegment),
      );
      expect(renderObject.weight, 5);
    });
  });

  group('RenderLineSegment', () {
    testWidgets('renders with solid stroke style', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LineSegment(
            point1: Offset(-2, -2),
            point2: Offset(2, 2),
            style: StrokeStyle.solid,
          ),
        ),
      );

      expect(find.byType(LineSegment), findsOneWidget);
    });

    testWidgets('renders with dashed stroke style', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LineSegment(
            point1: Offset(-2, -2),
            point2: Offset(2, 2),
            style: StrokeStyle.dashed,
          ),
        ),
      );

      expect(find.byType(LineSegment), findsOneWidget);
    });

    testWidgets('sizedByParent returns true', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LineSegment(
            point1: Offset(0, 0),
            point2: Offset(1, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderLineSegment>(
        find.byType(LineSegment),
      );

      expect(renderObject.sizedByParent, true);
    });

    testWidgets('hitTestSelf returns false', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LineSegment(
            point1: Offset(0, 0),
            point2: Offset(1, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderLineSegment>(
        find.byType(LineSegment),
      );

      expect(renderObject.hitTestSelf(Offset.zero), false);
    });

    testWidgets('setters trigger repaint when values change', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LineSegment(
            point1: Offset(0, 0),
            point2: Offset(1, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderLineSegment>(
        find.byType(LineSegment),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const LineSegment(
            point1: Offset(0, 0),
            point2: Offset(2, 2),
          ),
        ),
      );

      expect(renderObject.point2, const Offset(2, 2));
    });
  });

  group('LineThroughPoints widget', () {
    testWidgets('creates with required parameters', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LineThroughPoints(
            point1: Offset(0, 0),
            point2: Offset(1, 1),
          ),
        ),
      );

      expect(find.byType(LineThroughPoints), findsOneWidget);
    });

    testWidgets('creates with all parameters', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LineThroughPoints(
            point1: Offset(-1, -1),
            point2: Offset(2, 3),
            color: MafsColors.green,
            opacity: 0.7,
            weight: 4,
            style: StrokeStyle.dashed,
          ),
        ),
      );

      expect(find.byType(LineThroughPoints), findsOneWidget);
    });

    testWidgets('uses default values correctly', (tester) async {
      const line = LineThroughPoints(
        point1: Offset(0, 0),
        point2: Offset(1, 1),
      );

      expect(line.color, isNull);
      expect(line.opacity, 1.0);
      expect(line.weight, 2);
      expect(line.style, StrokeStyle.solid);
    });

    testWidgets('uses theme foreground color when color is null', (tester) async {
      const customTheme = MafsThemeData(foreground: Color(0xFF654321));

      await tester.pumpWidget(
        buildTestWidget(
          theme: customTheme,
          child: const LineThroughPoints(
            point1: Offset(0, 0),
            point2: Offset(1, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderLineThroughPoints>(
        find.byType(LineThroughPoints),
      );

      expect(renderObject.color, const Color(0xFF654321));
    });
  });

  group('RenderLineThroughPoints', () {
    testWidgets('handles horizontal line (slope = 0)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LineThroughPoints(
            point1: Offset(-1, 0),
            point2: Offset(1, 0),
          ),
        ),
      );

      expect(find.byType(LineThroughPoints), findsOneWidget);
    });

    testWidgets('handles vertical line (infinite slope)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LineThroughPoints(
            point1: Offset(0, -1),
            point2: Offset(0, 1),
          ),
        ),
      );

      expect(find.byType(LineThroughPoints), findsOneWidget);
    });

    testWidgets('handles steep line (slope > 1)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LineThroughPoints(
            point1: Offset(0, 0),
            point2: Offset(1, 3),
          ),
        ),
      );

      expect(find.byType(LineThroughPoints), findsOneWidget);
    });

    testWidgets('handles shallow line (slope < 1)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LineThroughPoints(
            point1: Offset(0, 0),
            point2: Offset(3, 1),
          ),
        ),
      );

      expect(find.byType(LineThroughPoints), findsOneWidget);
    });

    testWidgets('handles negative slope', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LineThroughPoints(
            point1: Offset(0, 0),
            point2: Offset(1, -1),
          ),
        ),
      );

      expect(find.byType(LineThroughPoints), findsOneWidget);
    });

    testWidgets('sizedByParent returns true', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LineThroughPoints(
            point1: Offset(0, 0),
            point2: Offset(1, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderLineThroughPoints>(
        find.byType(LineThroughPoints),
      );

      expect(renderObject.sizedByParent, true);
    });

    testWidgets('hitTestSelf returns false', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LineThroughPoints(
            point1: Offset(0, 0),
            point2: Offset(1, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderLineThroughPoints>(
        find.byType(LineThroughPoints),
      );

      expect(renderObject.hitTestSelf(Offset.zero), false);
    });
  });

  group('LinePointAngle widget', () {
    testWidgets('creates with required parameters', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LinePointAngle(
            point: Offset(0, 0),
            angle: 0,
          ),
        ),
      );

      expect(find.byType(LinePointAngle), findsOneWidget);
    });

    testWidgets('creates with all parameters', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LinePointAngle(
            point: Offset(1, 2),
            angle: math.pi / 4,
            color: MafsColors.violet,
            opacity: 0.8,
            weight: 3,
            style: StrokeStyle.dashed,
          ),
        ),
      );

      expect(find.byType(LinePointAngle), findsOneWidget);
    });

    testWidgets('uses default values correctly', (tester) async {
      const line = LinePointAngle(
        point: Offset(0, 0),
        angle: math.pi / 4,
      );

      expect(line.color, isNull);
      expect(line.opacity, 1.0);
      expect(line.weight, 2);
      expect(line.style, StrokeStyle.solid);
    });

    testWidgets('wraps LineThroughPoints internally', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LinePointAngle(
            point: Offset(0, 0),
            angle: math.pi / 4,
          ),
        ),
      );

      // LinePointAngle should contain a LineThroughPoints
      expect(find.byType(LineThroughPoints), findsOneWidget);
    });

    testWidgets('angle = 0 creates horizontal line', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LinePointAngle(
            point: Offset(0, 0),
            angle: 0,
          ),
        ),
      );

      expect(find.byType(LinePointAngle), findsOneWidget);
    });

    testWidgets('angle = pi/2 creates vertical line', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LinePointAngle(
            point: Offset(0, 0),
            angle: math.pi / 2,
          ),
        ),
      );

      expect(find.byType(LinePointAngle), findsOneWidget);
    });
  });

  group('LinePointSlope widget', () {
    testWidgets('creates with required parameters', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LinePointSlope(
            point: Offset(0, 0),
            slope: 1,
          ),
        ),
      );

      expect(find.byType(LinePointSlope), findsOneWidget);
    });

    testWidgets('creates with all parameters', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LinePointSlope(
            point: Offset(1, 1),
            slope: 2,
            color: MafsColors.orange,
            opacity: 0.6,
            weight: 4,
            style: StrokeStyle.dashed,
          ),
        ),
      );

      expect(find.byType(LinePointSlope), findsOneWidget);
    });

    testWidgets('uses default values correctly', (tester) async {
      const line = LinePointSlope(
        point: Offset(0, 0),
        slope: 1,
      );

      expect(line.color, isNull);
      expect(line.opacity, 1.0);
      expect(line.weight, 2);
      expect(line.style, StrokeStyle.solid);
    });

    testWidgets('wraps LinePointAngle internally', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LinePointSlope(
            point: Offset(0, 0),
            slope: 1,
          ),
        ),
      );

      // LinePointSlope should contain a LinePointAngle
      expect(find.byType(LinePointAngle), findsOneWidget);
    });

    testWidgets('slope = 0 creates horizontal line', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LinePointSlope(
            point: Offset(0, 0),
            slope: 0,
          ),
        ),
      );

      expect(find.byType(LinePointSlope), findsOneWidget);
    });

    testWidgets('slope = 1 creates 45 degree line', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LinePointSlope(
            point: Offset(0, 0),
            slope: 1,
          ),
        ),
      );

      expect(find.byType(LinePointSlope), findsOneWidget);
    });

    testWidgets('negative slope works correctly', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const LinePointSlope(
            point: Offset(0, 0),
            slope: -1,
          ),
        ),
      );

      expect(find.byType(LinePointSlope), findsOneWidget);
    });
  });

  group('Coordinate transformation', () {
    testWidgets('segment endpoints transform correctly', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          xMin: -5,
          xMax: 5,
          yMin: -5,
          yMax: 5,
          width: 400,
          height: 400,
          child: const LineSegment(
            point1: Offset(0, 0),
            point2: Offset(5, 5),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderLineSegment>(
        find.byType(LineSegment),
      );

      expect(renderObject.point1, const Offset(0, 0));
      expect(renderObject.point2, const Offset(5, 5));
      expect(renderObject.xMin, -5);
      expect(renderObject.xMax, 5);
    });

    testWidgets('user transform is applied', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          userTransform: MatrixOps.translate(2, 2),
          child: const LineSegment(
            point1: Offset(0, 0),
            point2: Offset(1, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderLineSegment>(
        find.byType(LineSegment),
      );

      expect(renderObject.userTransform, MatrixOps.translate(2, 2));
    });
  });
}
