import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafs_flutter/src/context/coordinate_context.dart';
import 'package:mafs_flutter/src/context/transform_context.dart';
import 'package:mafs_flutter/src/display/theme.dart';
import 'package:mafs_flutter/src/display/vector.dart';
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

  group('MafsVector widget', () {
    testWidgets('creates with required parameters', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tip: Offset(2, 3),
          ),
        ),
      );

      expect(find.byType(MafsVector), findsOneWidget);
    });

    testWidgets('creates with all parameters', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tail: Offset(1, 1),
            tip: Offset(3, 4),
            color: MafsColors.blue,
            opacity: 0.8,
            weight: 3,
            style: StrokeStyle.dashed,
          ),
        ),
      );

      expect(find.byType(MafsVector), findsOneWidget);
    });

    testWidgets('uses default values correctly', (tester) async {
      const vector = MafsVector(tip: Offset(1, 1));

      expect(vector.tail, Offset.zero);
      expect(vector.color, isNull);
      expect(vector.opacity, 1.0);
      expect(vector.weight, 2);
      expect(vector.style, StrokeStyle.solid);
    });

    testWidgets('uses theme foreground color when color is null', (tester) async {
      const customTheme = MafsThemeData(foreground: Color(0xFF123456));

      await tester.pumpWidget(
        buildTestWidget(
          theme: customTheme,
          child: const MafsVector(
            tip: Offset(1, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsVector>(
        find.byType(MafsVector),
      );

      expect(renderObject.color, const Color(0xFF123456));
    });

    testWidgets('uses explicit color over theme color', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tip: Offset(1, 1),
            color: MafsColors.red,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsVector>(
        find.byType(MafsVector),
      );

      expect(renderObject.color, MafsColors.red);
    });

    testWidgets('updates render object on property changes', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tip: Offset(1, 1),
            weight: 2,
          ),
        ),
      );

      var renderObject = tester.renderObject<RenderMafsVector>(
        find.byType(MafsVector),
      );
      expect(renderObject.weight, 2);

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tip: Offset(1, 1),
            weight: 5,
          ),
        ),
      );

      renderObject = tester.renderObject<RenderMafsVector>(
        find.byType(MafsVector),
      );
      expect(renderObject.weight, 5);
    });
  });

  group('RenderMafsVector', () {
    testWidgets('has correct arrow size', (tester) async {
      expect(RenderMafsVector.arrowSize, 8.0);
    });

    testWidgets('renders with solid stroke style', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tail: Offset(-2, -2),
            tip: Offset(2, 2),
            style: StrokeStyle.solid,
          ),
        ),
      );

      expect(find.byType(MafsVector), findsOneWidget);
    });

    testWidgets('renders with dashed stroke style', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tail: Offset(-2, -2),
            tip: Offset(2, 2),
            style: StrokeStyle.dashed,
          ),
        ),
      );

      expect(find.byType(MafsVector), findsOneWidget);
    });

    testWidgets('sizedByParent returns true', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tip: Offset(1, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsVector>(
        find.byType(MafsVector),
      );

      expect(renderObject.sizedByParent, true);
    });

    testWidgets('hitTestSelf returns false', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tip: Offset(1, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsVector>(
        find.byType(MafsVector),
      );

      expect(renderObject.hitTestSelf(Offset.zero), false);
    });
  });

  group('RenderMafsVector setters', () {
    testWidgets('tail setter triggers repaint', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tail: Offset(0, 0),
            tip: Offset(1, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsVector>(
        find.byType(MafsVector),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tail: Offset(1, 0),
            tip: Offset(1, 1),
          ),
        ),
      );

      expect(renderObject.tail, const Offset(1, 0));
    });

    testWidgets('tip setter triggers repaint', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tip: Offset(1, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsVector>(
        find.byType(MafsVector),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tip: Offset(2, 2),
          ),
        ),
      );

      expect(renderObject.tip, const Offset(2, 2));
    });

    testWidgets('color setter triggers repaint', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tip: Offset(1, 1),
            color: MafsColors.red,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsVector>(
        find.byType(MafsVector),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tip: Offset(1, 1),
            color: MafsColors.blue,
          ),
        ),
      );

      expect(renderObject.color, MafsColors.blue);
    });

    testWidgets('opacity setter triggers repaint', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tip: Offset(1, 1),
            opacity: 1.0,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsVector>(
        find.byType(MafsVector),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tip: Offset(1, 1),
            opacity: 0.5,
          ),
        ),
      );

      expect(renderObject.opacity, 0.5);
    });

    testWidgets('weight setter triggers repaint', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tip: Offset(1, 1),
            weight: 2,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsVector>(
        find.byType(MafsVector),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tip: Offset(1, 1),
            weight: 4,
          ),
        ),
      );

      expect(renderObject.weight, 4);
    });

    testWidgets('style setter triggers repaint', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tip: Offset(1, 1),
            style: StrokeStyle.solid,
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsVector>(
        find.byType(MafsVector),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tip: Offset(1, 1),
            style: StrokeStyle.dashed,
          ),
        ),
      );

      expect(renderObject.style, StrokeStyle.dashed);
    });
  });

  group('Vector directions', () {
    testWidgets('renders horizontal vector (pointing right)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tail: Offset(0, 0),
            tip: Offset(3, 0),
          ),
        ),
      );

      expect(find.byType(MafsVector), findsOneWidget);
    });

    testWidgets('renders horizontal vector (pointing left)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tail: Offset(3, 0),
            tip: Offset(0, 0),
          ),
        ),
      );

      expect(find.byType(MafsVector), findsOneWidget);
    });

    testWidgets('renders vertical vector (pointing up)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tail: Offset(0, 0),
            tip: Offset(0, 3),
          ),
        ),
      );

      expect(find.byType(MafsVector), findsOneWidget);
    });

    testWidgets('renders vertical vector (pointing down)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tail: Offset(0, 3),
            tip: Offset(0, 0),
          ),
        ),
      );

      expect(find.byType(MafsVector), findsOneWidget);
    });

    testWidgets('renders diagonal vector', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tail: Offset(-2, -2),
            tip: Offset(2, 2),
          ),
        ),
      );

      expect(find.byType(MafsVector), findsOneWidget);
    });

    testWidgets('handles zero-length vector gracefully', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tail: Offset(1, 1),
            tip: Offset(1, 1),
          ),
        ),
      );

      // Should not crash
      expect(find.byType(MafsVector), findsOneWidget);
    });

    testWidgets('handles very short vector', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const MafsVector(
            tail: Offset(0, 0),
            tip: Offset(0.0001, 0.0001),
          ),
        ),
      );

      // Should not crash
      expect(find.byType(MafsVector), findsOneWidget);
    });
  });

  group('Coordinate transformation', () {
    testWidgets('vector from origin renders correctly', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          xMin: -5,
          xMax: 5,
          yMin: -5,
          yMax: 5,
          width: 400,
          height: 400,
          child: const MafsVector(
            tip: Offset(2, 3),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsVector>(
        find.byType(MafsVector),
      );

      expect(renderObject.tail, Offset.zero);
      expect(renderObject.tip, const Offset(2, 3));
      expect(renderObject.xMin, -5);
      expect(renderObject.xMax, 5);
    });

    testWidgets('user transform is applied', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          userTransform: MatrixOps.translate(2, 2),
          child: const MafsVector(
            tip: Offset(1, 1),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsVector>(
        find.byType(MafsVector),
      );

      expect(renderObject.userTransform, MatrixOps.translate(2, 2));
    });
  });
}
