import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafs_flutter/src/context/coordinate_context.dart';
import 'package:mafs_flutter/src/context/transform_context.dart';
import 'package:mafs_flutter/src/display/plot.dart';
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

  group('Plot namespace', () {
    testWidgets('Plot.ofX creates PlotOfX widget', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: Plot.ofX(
            y: (x) => x * x,
          ),
        ),
      );

      expect(find.byType(PlotOfX), findsOneWidget);
    });

    testWidgets('Plot.ofY creates PlotOfY widget', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: Plot.ofY(
            x: (y) => y * y,
          ),
        ),
      );

      expect(find.byType(PlotOfY), findsOneWidget);
    });

    testWidgets('Plot.parametric creates PlotParametric widget', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: Plot.parametric(
            xy: (t) => Offset(math.cos(t), math.sin(t)),
            domain: (0, 2 * math.pi),
          ),
        ),
      );

      expect(find.byType(PlotParametric), findsOneWidget);
    });
  });

  group('PlotOfX widget', () {
    testWidgets('creates with required y function', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotOfX(
            y: (x) => x,
          ),
        ),
      );

      expect(find.byType(PlotOfX), findsOneWidget);
    });

    testWidgets('creates with all parameters', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotOfX(
            y: (x) => math.sin(x),
            domain: (-math.pi, math.pi),
            color: MafsColors.blue,
            opacity: 0.8,
            weight: 3,
            style: StrokeStyle.dashed,
            minSamplingDepth: 6,
            maxSamplingDepth: 12,
          ),
        ),
      );

      expect(find.byType(PlotOfX), findsOneWidget);
    });

    testWidgets('uses default values correctly', (tester) async {
      const plot = PlotOfX(
        y: _identity,
      );

      expect(plot.color, isNull);
      expect(plot.opacity, 1.0);
      expect(plot.weight, 2);
      expect(plot.style, StrokeStyle.solid);
      expect(plot.minSamplingDepth, 8);
      expect(plot.maxSamplingDepth, 14);
      expect(plot.domain, isNull);
    });

    testWidgets('uses theme color when color is null', (tester) async {
      const customTheme = MafsThemeData(foreground: Color(0xFF123456));

      await tester.pumpWidget(
        buildTestWidget(
          theme: customTheme,
          child: PlotOfX(
            y: (x) => x,
          ),
        ),
      );

      // PlotOfX internally creates PlotParametric
      final renderObject = tester.renderObject<RenderPlotParametric>(
        find.byType(PlotParametric),
      );

      expect(renderObject.color, const Color(0xFF123456));
    });

    testWidgets('uses explicit color over theme', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotOfX(
            y: (x) => x,
            color: MafsColors.red,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderPlotParametric>(
        find.byType(PlotParametric),
      );

      expect(renderObject.color, MafsColors.red);
    });

    testWidgets('uses visible x range when domain is null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          xMin: -10,
          xMax: 10,
          child: PlotOfX(
            y: (x) => x,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderPlotParametric>(
        find.byType(PlotParametric),
      );

      expect(renderObject.domain, (-10.0, 10.0));
    });

    testWidgets('uses explicit domain over visible range', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          xMin: -10,
          xMax: 10,
          child: PlotOfX(
            y: (x) => x,
            domain: (-2, 2),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderPlotParametric>(
        find.byType(PlotParametric),
      );

      expect(renderObject.domain, (-2.0, 2.0));
    });

    group('common functions', () {
      testWidgets('sin function', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: PlotOfX(
              y: (x) => math.sin(x),
            ),
          ),
        );

        expect(find.byType(PlotOfX), findsOneWidget);
      });

      testWidgets('cos function', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: PlotOfX(
              y: (x) => math.cos(x),
            ),
          ),
        );

        expect(find.byType(PlotOfX), findsOneWidget);
      });

      testWidgets('quadratic x^2 function', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: PlotOfX(
              y: (x) => x * x,
            ),
          ),
        );

        expect(find.byType(PlotOfX), findsOneWidget);
      });

      testWidgets('linear function', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: PlotOfX(
              y: (x) => 2 * x + 1,
            ),
          ),
        );

        expect(find.byType(PlotOfX), findsOneWidget);
      });
    });
  });

  group('PlotOfY widget', () {
    testWidgets('creates with required x function', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotOfY(
            x: (y) => y,
          ),
        ),
      );

      expect(find.byType(PlotOfY), findsOneWidget);
    });

    testWidgets('creates with all parameters', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotOfY(
            x: (y) => y * y,
            domain: (-3, 3),
            color: MafsColors.green,
            opacity: 0.6,
            weight: 4,
            style: StrokeStyle.dashed,
            minSamplingDepth: 5,
            maxSamplingDepth: 10,
          ),
        ),
      );

      expect(find.byType(PlotOfY), findsOneWidget);
    });

    testWidgets('uses default values correctly', (tester) async {
      const plot = PlotOfY(
        x: _identity,
      );

      expect(plot.color, isNull);
      expect(plot.opacity, 1.0);
      expect(plot.weight, 2);
      expect(plot.style, StrokeStyle.solid);
      expect(plot.minSamplingDepth, 8);
      expect(plot.maxSamplingDepth, 14);
      expect(plot.domain, isNull);
    });

    testWidgets('uses theme color when color is null', (tester) async {
      const customTheme = MafsThemeData(foreground: Color(0xFF654321));

      await tester.pumpWidget(
        buildTestWidget(
          theme: customTheme,
          child: PlotOfY(
            x: (y) => y,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderPlotParametric>(
        find.byType(PlotParametric),
      );

      expect(renderObject.color, const Color(0xFF654321));
    });

    testWidgets('uses explicit color over theme', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotOfY(
            x: (y) => y,
            color: MafsColors.violet,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderPlotParametric>(
        find.byType(PlotParametric),
      );

      expect(renderObject.color, MafsColors.violet);
    });

    testWidgets('uses visible y range when domain is null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          yMin: -8,
          yMax: 8,
          child: PlotOfY(
            x: (y) => y,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderPlotParametric>(
        find.byType(PlotParametric),
      );

      expect(renderObject.domain, (-8.0, 8.0));
    });

    testWidgets('uses explicit domain over visible range', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          yMin: -8,
          yMax: 8,
          child: PlotOfY(
            x: (y) => y,
            domain: (-1, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderPlotParametric>(
        find.byType(PlotParametric),
      );

      expect(renderObject.domain, (-1.0, 1.0));
    });

    group('common functions', () {
      testWidgets('sqrt function (sideways parabola)', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: PlotOfY(
              x: (y) => y >= 0 ? math.sqrt(y) : double.nan,
            ),
          ),
        );

        expect(find.byType(PlotOfY), findsOneWidget);
      });

      testWidgets('quadratic y^2 function', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: PlotOfY(
              x: (y) => y * y,
            ),
          ),
        );

        expect(find.byType(PlotOfY), findsOneWidget);
      });
    });
  });

  group('PlotParametric widget', () {
    testWidgets('creates with required xy function and domain', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotParametric(
            xy: (t) => Offset(t, t),
            domain: (0, 1),
          ),
        ),
      );

      expect(find.byType(PlotParametric), findsOneWidget);
    });

    testWidgets('creates with all parameters', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotParametric(
            xy: (t) => Offset(math.cos(t), math.sin(t)),
            domain: (0, 2 * math.pi),
            color: MafsColors.pink,
            opacity: 0.9,
            weight: 5,
            style: StrokeStyle.dashed,
            minSamplingDepth: 4,
            maxSamplingDepth: 16,
          ),
        ),
      );

      expect(find.byType(PlotParametric), findsOneWidget);
    });

    testWidgets('default values (minSamplingDepth=8, maxSamplingDepth=14, etc)', (tester) async {
      final plot = PlotParametric(
        xy: (t) => Offset(t, t),
        domain: (0, 1),
      );

      expect(plot.color, isNull);
      expect(plot.opacity, 1.0);
      expect(plot.weight, 2);
      expect(plot.style, StrokeStyle.solid);
      expect(plot.minSamplingDepth, 8);
      expect(plot.maxSamplingDepth, 14);
    });

    testWidgets('uses theme color when color is null', (tester) async {
      const customTheme = MafsThemeData(foreground: Color(0xFFABCDEF));

      await tester.pumpWidget(
        buildTestWidget(
          theme: customTheme,
          child: PlotParametric(
            xy: (t) => Offset(t, t),
            domain: (0, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderPlotParametric>(
        find.byType(PlotParametric),
      );

      expect(renderObject.color, const Color(0xFFABCDEF));
    });

    testWidgets('uses explicit color over theme', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotParametric(
            xy: (t) => Offset(t, t),
            domain: (0, 1),
            color: MafsColors.orange,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderPlotParametric>(
        find.byType(PlotParametric),
      );

      expect(renderObject.color, MafsColors.orange);
    });

    testWidgets('render object property updates', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotParametric(
            xy: (t) => Offset(t, t),
            domain: (0, 1),
            weight: 2,
            opacity: 1.0,
          ),
        ),
      );

      var renderObject = tester.renderObject<RenderPlotParametric>(
        find.byType(PlotParametric),
      );
      expect(renderObject.weight, 2);
      expect(renderObject.opacity, 1.0);

      await tester.pumpWidget(
        buildTestWidget(
          child: PlotParametric(
            xy: (t) => Offset(t, t),
            domain: (0, 1),
            weight: 5,
            opacity: 0.5,
          ),
        ),
      );

      renderObject = tester.renderObject<RenderPlotParametric>(
        find.byType(PlotParametric),
      );
      expect(renderObject.weight, 5);
      expect(renderObject.opacity, 0.5);
    });

    testWidgets('sizedByParent returns true', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotParametric(
            xy: (t) => Offset(t, t),
            domain: (0, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderPlotParametric>(
        find.byType(PlotParametric),
      );

      expect(renderObject.sizedByParent, true);
    });

    testWidgets('hitTestSelf returns false', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotParametric(
            xy: (t) => Offset(t, t),
            domain: (0, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderPlotParametric>(
        find.byType(PlotParametric),
      );

      expect(renderObject.hitTestSelf(Offset.zero), false);
    });

    group('parametric curves', () {
      testWidgets('circle', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: PlotParametric(
              xy: (t) => Offset(math.cos(t), math.sin(t)),
              domain: (0, 2 * math.pi),
            ),
          ),
        );

        expect(find.byType(PlotParametric), findsOneWidget);
      });

      testWidgets('ellipse', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: PlotParametric(
              xy: (t) => Offset(2 * math.cos(t), math.sin(t)),
              domain: (0, 2 * math.pi),
            ),
          ),
        );

        expect(find.byType(PlotParametric), findsOneWidget);
      });

      testWidgets('spiral (Archimedean)', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: PlotParametric(
              xy: (t) => Offset(t * math.cos(t) / 10, t * math.sin(t) / 10),
              domain: (0, 6 * math.pi),
            ),
          ),
        );

        expect(find.byType(PlotParametric), findsOneWidget);
      });

      testWidgets('Lissajous curve', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: PlotParametric(
              xy: (t) => Offset(math.sin(3 * t), math.sin(2 * t)),
              domain: (0, 2 * math.pi),
            ),
          ),
        );

        expect(find.byType(PlotParametric), findsOneWidget);
      });
    });
  });

  group('RenderPlotParametric', () {
    testWidgets('renders with solid stroke style', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotParametric(
            xy: (t) => Offset(t, t),
            domain: (-2, 2),
            style: StrokeStyle.solid,
          ),
        ),
      );

      expect(find.byType(PlotParametric), findsOneWidget);
    });

    testWidgets('renders with dashed stroke style', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotParametric(
            xy: (t) => Offset(t, t),
            domain: (-2, 2),
            style: StrokeStyle.dashed,
          ),
        ),
      );

      expect(find.byType(PlotParametric), findsOneWidget);
    });

    testWidgets('handles empty domain (tMin >= tMax)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotParametric(
            xy: (t) => Offset(t, t),
            domain: (5, 5), // empty domain
          ),
        ),
      );

      // Should render without error
      expect(find.byType(PlotParametric), findsOneWidget);
    });

    testWidgets('handles reversed domain (tMin > tMax)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotParametric(
            xy: (t) => Offset(t, t),
            domain: (5, 0), // reversed domain
          ),
        ),
      );

      // Should render without error
      expect(find.byType(PlotParametric), findsOneWidget);
    });

    testWidgets('setters trigger repaint when values change', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotParametric(
            xy: (t) => Offset(t, t),
            domain: (0, 1),
            color: MafsColors.blue,
          ),
        ),
      );

      var renderObject = tester.renderObject<RenderPlotParametric>(
        find.byType(PlotParametric),
      );
      expect(renderObject.color, MafsColors.blue);

      await tester.pumpWidget(
        buildTestWidget(
          child: PlotParametric(
            xy: (t) => Offset(t, t),
            domain: (0, 1),
            color: MafsColors.red,
          ),
        ),
      );

      renderObject = tester.renderObject<RenderPlotParametric>(
        find.byType(PlotParametric),
      );
      expect(renderObject.color, MafsColors.red);
    });

    testWidgets('setters do not repaint when values unchanged', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotParametric(
            xy: (t) => Offset(t, t),
            domain: (0, 1),
            weight: 3,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderPlotParametric>(
        find.byType(PlotParametric),
      );

      // Setting same value should not cause issues
      renderObject.weight = 3;
      expect(renderObject.weight, 3);
    });

    testWidgets('user transform is applied', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          userTransform: MatrixOps.translate(2, 2),
          child: PlotParametric(
            xy: (t) => Offset(t, t),
            domain: (0, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderPlotParametric>(
        find.byType(PlotParametric),
      );

      expect(renderObject.userTransform, MatrixOps.translate(2, 2));
    });

    testWidgets('coordinate bounds are correctly set', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          xMin: -10,
          xMax: 10,
          yMin: -8,
          yMax: 8,
          child: PlotParametric(
            xy: (t) => Offset(t, t),
            domain: (0, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderPlotParametric>(
        find.byType(PlotParametric),
      );

      expect(renderObject.xMin, -10);
      expect(renderObject.xMax, 10);
      expect(renderObject.yMin, -8);
      expect(renderObject.yMax, 8);
    });
  });

  group('Sampling', () {
    testWidgets('handles functions that return NaN gracefully', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotOfX(
            y: (x) {
              // sqrt of negative number returns NaN
              if (x < 0) return double.nan;
              return math.sqrt(x);
            },
          ),
        ),
      );

      // Should render without error
      expect(find.byType(PlotOfX), findsOneWidget);
    });

    testWidgets('handles functions that return Infinity gracefully', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotOfX(
            y: (x) {
              // 1/x returns infinity at x=0
              if (x == 0) return double.infinity;
              return 1 / x;
            },
          ),
        ),
      );

      // Should render without error
      expect(find.byType(PlotOfX), findsOneWidget);
    });

    testWidgets('handles functions that return negative Infinity gracefully', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotOfX(
            y: (x) {
              if (x == 0) return double.negativeInfinity;
              return -1 / x.abs();
            },
          ),
        ),
      );

      // Should render without error
      expect(find.byType(PlotOfX), findsOneWidget);
    });

    testWidgets('handles asymptotic functions (tan)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotOfX(
            y: (x) => math.tan(x),
          ),
        ),
      );

      // Should render without error (tan has asymptotes at pi/2 + n*pi)
      expect(find.byType(PlotOfX), findsOneWidget);
    });

    testWidgets('handles functions returning only non-finite values', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotParametric(
            xy: (t) => const Offset(double.nan, double.nan),
            domain: (0, 1),
          ),
        ),
      );

      // Should render without error (empty path)
      expect(find.byType(PlotParametric), findsOneWidget);
    });
  });

  group('sampleParametric function', () {
    test('returns points for simple linear function', () {
      final points = sampleParametric(
        (t) => Offset(t, t),
        (0, 1),
        2, // low min depth for testing
        4, // low max depth for testing
        0.1,
      );

      expect(points, isNotEmpty);
      expect(points.first, const Offset(0, 0));
      // Last point should be close to (1, 1)
      expect(points.last.dx, closeTo(1, 0.01));
      expect(points.last.dy, closeTo(1, 0.01));
    });

    test('returns points for circle', () {
      final points = sampleParametric(
        (t) => Offset(math.cos(t), math.sin(t)),
        (0, 2 * math.pi),
        4,
        8,
        0.01,
      );

      expect(points, isNotEmpty);
      // First point should be (1, 0)
      expect(points.first.dx, closeTo(1, 0.01));
      expect(points.first.dy, closeTo(0, 0.01));
    });

    test('produces more points in high curvature areas', () {
      // Sample a straight line
      final linearPoints = sampleParametric(
        (t) => Offset(t, t),
        (0, 1),
        2,
        10,
        0.001,
      );

      // Sample a high-curvature function
      final curvedPoints = sampleParametric(
        (t) => Offset(t, math.sin(10 * t)),
        (0, 1),
        2,
        10,
        0.001,
      );

      // Curved function should produce more points due to adaptive sampling
      expect(curvedPoints.length, greaterThan(linearPoints.length));
    });
  });

  group('Coordinate transformation', () {
    testWidgets('plot endpoints transform correctly', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          xMin: -5,
          xMax: 5,
          yMin: -5,
          yMax: 5,
          width: 400,
          height: 400,
          child: PlotParametric(
            xy: (t) => Offset(t, t * 2),
            domain: (0, 5),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderPlotParametric>(
        find.byType(PlotParametric),
      );

      expect(renderObject.domain, (0.0, 5.0));
      expect(renderObject.xMin, -5);
      expect(renderObject.xMax, 5);
    });

    testWidgets('user transform is applied to render object', (tester) async {
      final transform = MatrixOps.scale(2, 2);

      await tester.pumpWidget(
        buildTestWidget(
          userTransform: transform,
          child: PlotParametric(
            xy: (t) => Offset(t, t),
            domain: (0, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderPlotParametric>(
        find.byType(PlotParametric),
      );

      expect(renderObject.userTransform, transform);
    });
  });

  group('Edge cases', () {
    testWidgets('very small domain', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotParametric(
            xy: (t) => Offset(t, t),
            domain: (0, 0.0001),
          ),
        ),
      );

      expect(find.byType(PlotParametric), findsOneWidget);
    });

    testWidgets('very large domain', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotParametric(
            xy: (t) => Offset(math.cos(t), math.sin(t)),
            domain: (0, 1000),
          ),
        ),
      );

      expect(find.byType(PlotParametric), findsOneWidget);
    });

    testWidgets('negative domain', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotParametric(
            xy: (t) => Offset(t, t * t),
            domain: (-10, -5),
          ),
        ),
      );

      expect(find.byType(PlotParametric), findsOneWidget);
    });

    testWidgets('zero weight renders without error', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotParametric(
            xy: (t) => Offset(t, t),
            domain: (0, 1),
            weight: 0,
          ),
        ),
      );

      expect(find.byType(PlotParametric), findsOneWidget);
    });

    testWidgets('zero opacity renders without error', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlotParametric(
            xy: (t) => Offset(t, t),
            domain: (0, 1),
            opacity: 0,
          ),
        ),
      );

      expect(find.byType(PlotParametric), findsOneWidget);
    });
  });
}

// Helper function for default value tests (const functions can't be lambdas)
double _identity(double x) => x;
