import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafs_flutter/src/context/coordinate_context.dart';
import 'package:mafs_flutter/src/context/transform_context.dart';
import 'package:mafs_flutter/src/display/polygon.dart';
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

  group('MafsPolygon widget', () {
    testWidgets('creates with required parameters', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(0, 0),
              Offset(1, 0),
              Offset(0.5, 1),
            ],
          ),
        ),
      );

      expect(find.byType(MafsPolygon), findsOneWidget);
    });

    testWidgets('creates with all parameters', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(0, 0),
              Offset(2, 0),
              Offset(2, 2),
              Offset(0, 2),
            ],
            color: MafsColors.blue,
            weight: 3,
            fillOpacity: 0.5,
            strokeOpacity: 0.8,
            strokeStyle: StrokeStyle.dashed,
          ),
        ),
      );

      expect(find.byType(MafsPolygon), findsOneWidget);
    });

    testWidgets('uses default values correctly', (tester) async {
      const polygon = MafsPolygon(
        points: [
          Offset(0, 0),
          Offset(1, 0),
          Offset(0.5, 1),
        ],
      );

      expect(polygon.color, isNull);
      expect(polygon.weight, 2);
      expect(polygon.fillOpacity, 0.15);
      expect(polygon.strokeOpacity, 1.0);
      expect(polygon.strokeStyle, StrokeStyle.solid);
    });

    testWidgets('uses theme foreground color when color is null', (tester) async {
      const customTheme = MafsThemeData(foreground: Color(0xFF123456));

      await tester.pumpWidget(
        buildTestWidget(
          theme: customTheme,
          child: const MafsPolygon(
            points: [
              Offset(0, 0),
              Offset(1, 0),
              Offset(0.5, 1),
            ],
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolygon>(
        find.byType(MafsPolygon),
      );

      expect(renderObject.color, const Color(0xFF123456));
    });

    testWidgets('uses explicit color over theme color', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(0, 0),
              Offset(1, 0),
              Offset(0.5, 1),
            ],
            color: MafsColors.red,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolygon>(
        find.byType(MafsPolygon),
      );

      expect(renderObject.color, MafsColors.red);
    });

    testWidgets('updates render object on property changes', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(0, 0),
              Offset(1, 0),
              Offset(0.5, 1),
            ],
            weight: 2,
          ),
        ),
      );

      var renderObject = tester.renderObject<RenderMafsPolygon>(
        find.byType(MafsPolygon),
      );
      expect(renderObject.weight, 2);

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(0, 0),
              Offset(1, 0),
              Offset(0.5, 1),
            ],
            weight: 5,
          ),
        ),
      );

      renderObject = tester.renderObject<RenderMafsPolygon>(
        find.byType(MafsPolygon),
      );
      expect(renderObject.weight, 5);
    });
  });

  group('MafsPolygon render object', () {
    testWidgets('sizedByParent returns true', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(0, 0),
              Offset(1, 0),
              Offset(0.5, 1),
            ],
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolygon>(
        find.byType(MafsPolygon),
      );

      expect(renderObject.sizedByParent, true);
    });

    testWidgets('hitTestSelf returns false', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(0, 0),
              Offset(1, 0),
              Offset(0.5, 1),
            ],
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolygon>(
        find.byType(MafsPolygon),
      );

      expect(renderObject.hitTestSelf(Offset.zero), false);
    });

    testWidgets('closePath returns true for polygon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(0, 0),
              Offset(1, 0),
              Offset(0.5, 1),
            ],
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolygon>(
        find.byType(MafsPolygon),
      );

      expect(renderObject.closePath, true);
    });

    testWidgets('renders with solid stroke style', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(-2, -2),
              Offset(2, -2),
              Offset(0, 2),
            ],
            strokeStyle: StrokeStyle.solid,
          ),
        ),
      );

      expect(find.byType(MafsPolygon), findsOneWidget);
    });

    testWidgets('renders with dashed stroke style', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(-2, -2),
              Offset(2, -2),
              Offset(0, 2),
            ],
            strokeStyle: StrokeStyle.dashed,
          ),
        ),
      );

      expect(find.byType(MafsPolygon), findsOneWidget);
    });
  });

  group('MafsPolygon different shapes', () {
    testWidgets('renders triangle (3 points)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(0, 0),
              Offset(2, 0),
              Offset(1, 2),
            ],
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolygon>(
        find.byType(MafsPolygon),
      );

      expect(renderObject.points.length, 3);
    });

    testWidgets('renders rectangle (4 points)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(0, 0),
              Offset(3, 0),
              Offset(3, 2),
              Offset(0, 2),
            ],
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolygon>(
        find.byType(MafsPolygon),
      );

      expect(renderObject.points.length, 4);
    });

    testWidgets('renders pentagon (5 points)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(0, 2),
              Offset(2, 3),
              Offset(4, 2),
              Offset(3, 0),
              Offset(1, 0),
            ],
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolygon>(
        find.byType(MafsPolygon),
      );

      expect(renderObject.points.length, 5);
    });

    testWidgets('renders irregular polygon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(-2, -1),
              Offset(0, -2),
              Offset(3, 0),
              Offset(2, 2),
              Offset(-1, 3),
              Offset(-3, 1),
            ],
          ),
        ),
      );

      expect(find.byType(MafsPolygon), findsOneWidget);
    });
  });

  group('MafsPolygon empty and edge cases', () {
    testWidgets('handles empty points list', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [],
          ),
        ),
      );

      // Should render without crashing
      expect(find.byType(MafsPolygon), findsOneWidget);
    });

    testWidgets('handles single point', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [Offset(0, 0)],
          ),
        ),
      );

      // Should render without crashing
      expect(find.byType(MafsPolygon), findsOneWidget);
    });

    testWidgets('handles two points (line)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(0, 0),
              Offset(1, 1),
            ],
          ),
        ),
      );

      // Should render without crashing
      expect(find.byType(MafsPolygon), findsOneWidget);
    });
  });

  group('RenderMafsPolygon property setters', () {
    testWidgets('points setter triggers repaint', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(0, 0),
              Offset(1, 0),
              Offset(0.5, 1),
            ],
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolygon>(
        find.byType(MafsPolygon),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(0, 0),
              Offset(2, 0),
              Offset(1, 2),
            ],
          ),
        ),
      );

      expect(renderObject.points[1], const Offset(2, 0));
    });

    testWidgets('color setter triggers repaint', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(0, 0),
              Offset(1, 0),
              Offset(0.5, 1),
            ],
            color: MafsColors.red,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolygon>(
        find.byType(MafsPolygon),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(0, 0),
              Offset(1, 0),
              Offset(0.5, 1),
            ],
            color: MafsColors.blue,
          ),
        ),
      );

      expect(renderObject.color, MafsColors.blue);
    });

    testWidgets('fillOpacity setter triggers repaint', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(0, 0),
              Offset(1, 0),
              Offset(0.5, 1),
            ],
            fillOpacity: 0.15,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolygon>(
        find.byType(MafsPolygon),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(0, 0),
              Offset(1, 0),
              Offset(0.5, 1),
            ],
            fillOpacity: 0.5,
          ),
        ),
      );

      expect(renderObject.fillOpacity, 0.5);
    });

    testWidgets('strokeOpacity setter triggers repaint', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(0, 0),
              Offset(1, 0),
              Offset(0.5, 1),
            ],
            strokeOpacity: 1.0,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolygon>(
        find.byType(MafsPolygon),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(0, 0),
              Offset(1, 0),
              Offset(0.5, 1),
            ],
            strokeOpacity: 0.5,
          ),
        ),
      );

      expect(renderObject.strokeOpacity, 0.5);
    });

    testWidgets('strokeStyle setter triggers repaint', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(0, 0),
              Offset(1, 0),
              Offset(0.5, 1),
            ],
            strokeStyle: StrokeStyle.solid,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolygon>(
        find.byType(MafsPolygon),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(0, 0),
              Offset(1, 0),
              Offset(0.5, 1),
            ],
            strokeStyle: StrokeStyle.dashed,
          ),
        ),
      );

      expect(renderObject.strokeStyle, StrokeStyle.dashed);
    });
  });

  group('MafsPolygon coordinate transformation', () {
    testWidgets('respects userTransform', (tester) async {
      final userTransform = MatrixOps.translate(1, 1);

      await tester.pumpWidget(
        buildTestWidget(
          userTransform: userTransform,
          child: const MafsPolygon(
            points: [
              Offset(0, 0),
              Offset(1, 0),
              Offset(0.5, 1),
            ],
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolygon>(
        find.byType(MafsPolygon),
      );

      expect(renderObject.userTransform, userTransform);
    });

    testWidgets('coordinate bounds are passed correctly', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          xMin: -10,
          xMax: 10,
          yMin: -5,
          yMax: 15,
          child: const MafsPolygon(
            points: [
              Offset(0, 0),
              Offset(1, 0),
              Offset(0.5, 1),
            ],
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolygon>(
        find.byType(MafsPolygon),
      );

      expect(renderObject.xMin, -10);
      expect(renderObject.xMax, 10);
      expect(renderObject.yMin, -5);
      expect(renderObject.yMax, 15);
    });
  });

  group('MafsPolygon rendering with fill and stroke', () {
    testWidgets('renders with zero fill opacity (stroke only)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(0, 0),
              Offset(1, 0),
              Offset(0.5, 1),
            ],
            fillOpacity: 0,
          ),
        ),
      );

      expect(find.byType(MafsPolygon), findsOneWidget);
    });

    testWidgets('renders with zero stroke opacity (fill only)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(0, 0),
              Offset(1, 0),
              Offset(0.5, 1),
            ],
            strokeOpacity: 0,
            fillOpacity: 0.5,
          ),
        ),
      );

      expect(find.byType(MafsPolygon), findsOneWidget);
    });

    testWidgets('renders with zero weight', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [
              Offset(0, 0),
              Offset(1, 0),
              Offset(0.5, 1),
            ],
            weight: 0,
          ),
        ),
      );

      expect(find.byType(MafsPolygon), findsOneWidget);
    });
  });

  // =========================================================================
  // MafsPolyline Tests
  // =========================================================================

  group('MafsPolyline widget', () {
    testWidgets('creates with required parameters', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [
              Offset(0, 0),
              Offset(1, 1),
              Offset(2, 0),
            ],
          ),
        ),
      );

      expect(find.byType(MafsPolyline), findsOneWidget);
    });

    testWidgets('creates with all parameters', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [
              Offset(0, 0),
              Offset(1, 2),
              Offset(2, 1),
              Offset(3, 3),
            ],
            color: MafsColors.green,
            weight: 3,
            fillOpacity: 0.3,
            strokeOpacity: 0.8,
            strokeStyle: StrokeStyle.dashed,
          ),
        ),
      );

      expect(find.byType(MafsPolyline), findsOneWidget);
    });

    testWidgets('uses default values correctly', (tester) async {
      const polyline = MafsPolyline(
        points: [
          Offset(0, 0),
          Offset(1, 1),
        ],
      );

      expect(polyline.color, isNull);
      expect(polyline.weight, 2);
      expect(polyline.fillOpacity, 0); // Default is 0 for polyline
      expect(polyline.strokeOpacity, 1.0);
      expect(polyline.strokeStyle, StrokeStyle.solid);
    });

    testWidgets('default fillOpacity is 0 (no fill)', (tester) async {
      const polyline = MafsPolyline(
        points: [
          Offset(0, 0),
          Offset(1, 1),
        ],
      );

      // This is the key difference from MafsPolygon
      expect(polyline.fillOpacity, 0);
    });

    testWidgets('uses theme foreground color when color is null', (tester) async {
      const customTheme = MafsThemeData(foreground: Color(0xFF654321));

      await tester.pumpWidget(
        buildTestWidget(
          theme: customTheme,
          child: const MafsPolyline(
            points: [
              Offset(0, 0),
              Offset(1, 1),
            ],
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolyline>(
        find.byType(MafsPolyline),
      );

      expect(renderObject.color, const Color(0xFF654321));
    });

    testWidgets('uses explicit color over theme color', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [
              Offset(0, 0),
              Offset(1, 1),
            ],
            color: MafsColors.violet,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolyline>(
        find.byType(MafsPolyline),
      );

      expect(renderObject.color, MafsColors.violet);
    });

    testWidgets('updates render object on property changes', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [
              Offset(0, 0),
              Offset(1, 1),
            ],
            weight: 2,
          ),
        ),
      );

      var renderObject = tester.renderObject<RenderMafsPolyline>(
        find.byType(MafsPolyline),
      );
      expect(renderObject.weight, 2);

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [
              Offset(0, 0),
              Offset(1, 1),
            ],
            weight: 5,
          ),
        ),
      );

      renderObject = tester.renderObject<RenderMafsPolyline>(
        find.byType(MafsPolyline),
      );
      expect(renderObject.weight, 5);
    });
  });

  group('MafsPolyline render object', () {
    testWidgets('sizedByParent returns true', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [
              Offset(0, 0),
              Offset(1, 1),
            ],
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolyline>(
        find.byType(MafsPolyline),
      );

      expect(renderObject.sizedByParent, true);
    });

    testWidgets('hitTestSelf returns false', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [
              Offset(0, 0),
              Offset(1, 1),
            ],
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolyline>(
        find.byType(MafsPolyline),
      );

      expect(renderObject.hitTestSelf(Offset.zero), false);
    });

    testWidgets('closePath returns false for polyline', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [
              Offset(0, 0),
              Offset(1, 1),
            ],
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolyline>(
        find.byType(MafsPolyline),
      );

      expect(renderObject.closePath, false);
    });

    testWidgets('renders with solid stroke style', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [
              Offset(-2, 0),
              Offset(0, 2),
              Offset(2, 0),
            ],
            strokeStyle: StrokeStyle.solid,
          ),
        ),
      );

      expect(find.byType(MafsPolyline), findsOneWidget);
    });

    testWidgets('renders with dashed stroke style', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [
              Offset(-2, 0),
              Offset(0, 2),
              Offset(2, 0),
            ],
            strokeStyle: StrokeStyle.dashed,
          ),
        ),
      );

      expect(find.byType(MafsPolyline), findsOneWidget);
    });
  });

  group('MafsPolyline edge cases', () {
    testWidgets('handles empty points list', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [],
          ),
        ),
      );

      // Should render without crashing
      expect(find.byType(MafsPolyline), findsOneWidget);
    });

    testWidgets('handles single point', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [Offset(0, 0)],
          ),
        ),
      );

      // Should render without crashing
      expect(find.byType(MafsPolyline), findsOneWidget);
    });

    testWidgets('handles two points (simple line)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [
              Offset(0, 0),
              Offset(1, 1),
            ],
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolyline>(
        find.byType(MafsPolyline),
      );

      expect(renderObject.points.length, 2);
    });

    testWidgets('handles many points', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [
              Offset(0, 0),
              Offset(1, 1),
              Offset(2, 0),
              Offset(3, 1),
              Offset(4, 0),
              Offset(5, 1),
            ],
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolyline>(
        find.byType(MafsPolyline),
      );

      expect(renderObject.points.length, 6);
    });
  });

  group('RenderMafsPolyline property setters', () {
    testWidgets('points setter triggers repaint', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [
              Offset(0, 0),
              Offset(1, 1),
            ],
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolyline>(
        find.byType(MafsPolyline),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [
              Offset(0, 0),
              Offset(2, 2),
            ],
          ),
        ),
      );

      expect(renderObject.points[1], const Offset(2, 2));
    });

    testWidgets('color setter triggers repaint', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [
              Offset(0, 0),
              Offset(1, 1),
            ],
            color: MafsColors.red,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolyline>(
        find.byType(MafsPolyline),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [
              Offset(0, 0),
              Offset(1, 1),
            ],
            color: MafsColors.blue,
          ),
        ),
      );

      expect(renderObject.color, MafsColors.blue);
    });

    testWidgets('fillOpacity setter triggers repaint', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [
              Offset(0, 0),
              Offset(1, 1),
            ],
            fillOpacity: 0,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolyline>(
        find.byType(MafsPolyline),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [
              Offset(0, 0),
              Offset(1, 1),
            ],
            fillOpacity: 0.3,
          ),
        ),
      );

      expect(renderObject.fillOpacity, 0.3);
    });

    testWidgets('strokeOpacity setter triggers repaint', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [
              Offset(0, 0),
              Offset(1, 1),
            ],
            strokeOpacity: 1.0,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolyline>(
        find.byType(MafsPolyline),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [
              Offset(0, 0),
              Offset(1, 1),
            ],
            strokeOpacity: 0.5,
          ),
        ),
      );

      expect(renderObject.strokeOpacity, 0.5);
    });

    testWidgets('strokeStyle setter triggers repaint', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [
              Offset(0, 0),
              Offset(1, 1),
            ],
            strokeStyle: StrokeStyle.solid,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolyline>(
        find.byType(MafsPolyline),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [
              Offset(0, 0),
              Offset(1, 1),
            ],
            strokeStyle: StrokeStyle.dashed,
          ),
        ),
      );

      expect(renderObject.strokeStyle, StrokeStyle.dashed);
    });

    testWidgets('weight setter triggers repaint', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [
              Offset(0, 0),
              Offset(1, 1),
            ],
            weight: 2,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolyline>(
        find.byType(MafsPolyline),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [
              Offset(0, 0),
              Offset(1, 1),
            ],
            weight: 4,
          ),
        ),
      );

      expect(renderObject.weight, 4);
    });
  });

  group('MafsPolyline coordinate transformation', () {
    testWidgets('respects userTransform', (tester) async {
      final userTransform = MatrixOps.translate(2, 2);

      await tester.pumpWidget(
        buildTestWidget(
          userTransform: userTransform,
          child: const MafsPolyline(
            points: [
              Offset(0, 0),
              Offset(1, 1),
            ],
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolyline>(
        find.byType(MafsPolyline),
      );

      expect(renderObject.userTransform, userTransform);
    });

    testWidgets('coordinate bounds are passed correctly', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          xMin: -10,
          xMax: 10,
          yMin: -5,
          yMax: 15,
          child: const MafsPolyline(
            points: [
              Offset(0, 0),
              Offset(1, 1),
            ],
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPolyline>(
        find.byType(MafsPolyline),
      );

      expect(renderObject.xMin, -10);
      expect(renderObject.xMax, 10);
      expect(renderObject.yMin, -5);
      expect(renderObject.yMax, 15);
    });
  });

  group('MafsPolyline rendering with fill and stroke', () {
    testWidgets('renders with fill when fillOpacity > 0', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [
              Offset(0, 0),
              Offset(1, 1),
              Offset(2, 0),
            ],
            fillOpacity: 0.3,
          ),
        ),
      );

      expect(find.byType(MafsPolyline), findsOneWidget);
    });

    testWidgets('renders with zero stroke opacity (fill only)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [
              Offset(0, 0),
              Offset(1, 1),
              Offset(2, 0),
            ],
            strokeOpacity: 0,
            fillOpacity: 0.5,
          ),
        ),
      );

      expect(find.byType(MafsPolyline), findsOneWidget);
    });
  });

  // =========================================================================
  // Comparison tests between Polygon and Polyline
  // =========================================================================

  group('Polygon vs Polyline comparison', () {
    testWidgets('polygon has default fillOpacity of 0.15', (tester) async {
      const polygon = MafsPolygon(
        points: [Offset(0, 0), Offset(1, 0), Offset(0.5, 1)],
      );

      expect(polygon.fillOpacity, 0.15);
    });

    testWidgets('polyline has default fillOpacity of 0', (tester) async {
      const polyline = MafsPolyline(
        points: [Offset(0, 0), Offset(1, 1)],
      );

      expect(polyline.fillOpacity, 0);
    });

    testWidgets('polygon closes path, polyline does not', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolygon(
            points: [Offset(0, 0), Offset(1, 0), Offset(0.5, 1)],
          ),
        ),
      );

      final polygonRender = tester.renderObject<RenderMafsPolygon>(
        find.byType(MafsPolygon),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsPolyline(
            points: [Offset(0, 0), Offset(1, 0), Offset(0.5, 1)],
          ),
        ),
      );

      final polylineRender = tester.renderObject<RenderMafsPolyline>(
        find.byType(MafsPolyline),
      );

      expect(polygonRender.closePath, true);
      expect(polylineRender.closePath, false);
    });
  });
}
