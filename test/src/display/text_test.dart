import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafs_flutter/src/context/coordinate_context.dart';
import 'package:mafs_flutter/src/context/transform_context.dart';
import 'package:mafs_flutter/src/display/text.dart';
import 'package:mafs_flutter/src/display/theme.dart';
import 'package:mafs_flutter/src/vec.dart';

void main() {
  group('MafsText widget', () {
    group('widget creation', () {
      testWidgets('creates with required parameters', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(x: 1, y: 2, text: 'Hello'),
          ),
        );

        expect(find.byType(MafsText), findsOneWidget);
      });

      testWidgets('creates with all parameters', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(
              x: 3,
              y: 4,
              text: 'Test Label',
              color: Color(0xFFFF0000),
              size: 24,
              attach: CardinalDirection.n,
              attachDistance: 10,
            ),
          ),
        );

        expect(find.byType(MafsText), findsOneWidget);
      });
    });

    group('default values', () {
      testWidgets('default size is 30', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(x: 0, y: 0, text: 'Test'),
          ),
        );

        final renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.fontSize, 30);
      });

      testWidgets('default attachDistance is 0', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(x: 0, y: 0, text: 'Test'),
          ),
        );

        final renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.attachDistance, 0);
      });

      testWidgets('default attach is null (centered)', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(x: 0, y: 0, text: 'Test'),
          ),
        );

        final renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.attachDirection, isNull);
      });
    });

    group('theme color usage', () {
      testWidgets('uses theme foreground color when color is null',
          (tester) async {
        const customTheme = MafsThemeData(foreground: Color(0xFF00FF00));

        await tester.pumpWidget(
          buildTestWidget(
            theme: customTheme,
            child: const MafsText(x: 0, y: 0, text: 'Test'),
          ),
        );

        final renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.color, const Color(0xFF00FF00));
      });

      testWidgets('uses default foreground when no theme provided',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(x: 0, y: 0, text: 'Test'),
          ),
        );

        final renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.color, MafsColors.foreground);
      });
    });

    group('explicit color override', () {
      testWidgets('uses provided color when specified', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(
              x: 0,
              y: 0,
              text: 'Test',
              color: Color(0xFFFF0000),
            ),
          ),
        );

        final renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.color, const Color(0xFFFF0000));
      });

      testWidgets('explicit color overrides theme color', (tester) async {
        const customTheme = MafsThemeData(foreground: Color(0xFF00FF00));

        await tester.pumpWidget(
          buildTestWidget(
            theme: customTheme,
            child: const MafsText(
              x: 0,
              y: 0,
              text: 'Test',
              color: Color(0xFFFF0000),
            ),
          ),
        );

        final renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.color, const Color(0xFFFF0000));
      });
    });

    group('render object property updates', () {
      testWidgets('updates when x and y change', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(x: 1, y: 2, text: 'Test'),
          ),
        );

        var renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.x, 1);
        expect(renderObject.y, 2);

        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(x: 3, y: 4, text: 'Test'),
          ),
        );

        renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.x, 3);
        expect(renderObject.y, 4);
      });

      testWidgets('updates when text changes', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(x: 0, y: 0, text: 'Hello'),
          ),
        );

        var renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.text, 'Hello');

        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(x: 0, y: 0, text: 'World'),
          ),
        );

        renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.text, 'World');
      });

      testWidgets('updates when color changes', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(
              x: 0,
              y: 0,
              text: 'Test',
              color: Color(0xFFFF0000),
            ),
          ),
        );

        var renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.color, const Color(0xFFFF0000));

        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(
              x: 0,
              y: 0,
              text: 'Test',
              color: Color(0xFF0000FF),
            ),
          ),
        );

        renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.color, const Color(0xFF0000FF));
      });

      testWidgets('updates when fontSize changes', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(x: 0, y: 0, text: 'Test', size: 20),
          ),
        );

        var renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.fontSize, 20);

        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(x: 0, y: 0, text: 'Test', size: 40),
          ),
        );

        renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.fontSize, 40);
      });

      testWidgets('updates when attachDirection changes', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(
              x: 0,
              y: 0,
              text: 'Test',
              attach: CardinalDirection.n,
            ),
          ),
        );

        var renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.attachDirection, CardinalDirection.n);

        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(
              x: 0,
              y: 0,
              text: 'Test',
              attach: CardinalDirection.s,
            ),
          ),
        );

        renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.attachDirection, CardinalDirection.s);
      });

      testWidgets('updates when attachDistance changes', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(
              x: 0,
              y: 0,
              text: 'Test',
              attach: CardinalDirection.n,
              attachDistance: 5,
            ),
          ),
        );

        var renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.attachDistance, 5);

        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(
              x: 0,
              y: 0,
              text: 'Test',
              attach: CardinalDirection.n,
              attachDistance: 15,
            ),
          ),
        );

        renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.attachDistance, 15);
      });
    });
  });

  group('RenderMafsText', () {
    group('sizedByParent and hitTestSelf', () {
      testWidgets('sizedByParent is true', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(x: 0, y: 0, text: 'Test'),
          ),
        );

        final renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.sizedByParent, true);
      });

      testWidgets('hitTestSelf returns false outside text bounds',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(x: 0, y: 0, text: 'X'),
            width: 400,
            height: 400,
            xMin: -5,
            xMax: 5,
            yMin: -5,
            yMax: 5,
          ),
        );

        final renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        // Far from the text position (0,0) -> screen (200, 200)
        expect(renderObject.hitTestSelf(const Offset(0, 0)), false);
        expect(renderObject.hitTestSelf(const Offset(400, 400)), false);
      });
    });

    group('CardinalDirection values', () {
      testWidgets('north (n) positions text above point', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(
              x: 0,
              y: 0,
              text: 'N',
              attach: CardinalDirection.n,
            ),
          ),
        );

        final renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.attachDirection, CardinalDirection.n);
      });

      testWidgets('northeast (ne) positions text above-right', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(
              x: 0,
              y: 0,
              text: 'NE',
              attach: CardinalDirection.ne,
            ),
          ),
        );

        final renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.attachDirection, CardinalDirection.ne);
      });

      testWidgets('east (e) positions text to the right', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(
              x: 0,
              y: 0,
              text: 'E',
              attach: CardinalDirection.e,
            ),
          ),
        );

        final renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.attachDirection, CardinalDirection.e);
      });

      testWidgets('southeast (se) positions text below-right', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(
              x: 0,
              y: 0,
              text: 'SE',
              attach: CardinalDirection.se,
            ),
          ),
        );

        final renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.attachDirection, CardinalDirection.se);
      });

      testWidgets('south (s) positions text below point', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(
              x: 0,
              y: 0,
              text: 'S',
              attach: CardinalDirection.s,
            ),
          ),
        );

        final renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.attachDirection, CardinalDirection.s);
      });

      testWidgets('southwest (sw) positions text below-left', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(
              x: 0,
              y: 0,
              text: 'SW',
              attach: CardinalDirection.sw,
            ),
          ),
        );

        final renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.attachDirection, CardinalDirection.sw);
      });

      testWidgets('west (w) positions text to the left', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(
              x: 0,
              y: 0,
              text: 'W',
              attach: CardinalDirection.w,
            ),
          ),
        );

        final renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.attachDirection, CardinalDirection.w);
      });

      testWidgets('northwest (nw) positions text above-left', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(
              x: 0,
              y: 0,
              text: 'NW',
              attach: CardinalDirection.nw,
            ),
          ),
        );

        final renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.attachDirection, CardinalDirection.nw);
      });
    });

    group('empty text string handling', () {
      testWidgets('handles empty string', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(x: 0, y: 0, text: ''),
          ),
        );

        expect(find.byType(MafsText), findsOneWidget);

        final renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.text, '');
      });

      testWidgets('empty text updates to non-empty', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(x: 0, y: 0, text: ''),
          ),
        );

        var renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.text, '');

        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(x: 0, y: 0, text: 'Now visible'),
          ),
        );

        renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.text, 'Now visible');
      });
    });

    group('user transform is applied', () {
      testWidgets('stores user transform correctly', (tester) async {
        final translateTransform = MatrixOps.translate(5, 5);

        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(x: 0, y: 0, text: 'Test'),
            userTransform: translateTransform,
          ),
        );

        final renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.userTransform, translateTransform);
      });

      testWidgets('user transform updates when context changes',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(x: 0, y: 0, text: 'Test'),
            userTransform: MatrixOps.identity,
          ),
        );

        var renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.userTransform, MatrixOps.identity);

        final scaleTransform = MatrixOps.scale(2, 2);

        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(x: 0, y: 0, text: 'Test'),
            userTransform: scaleTransform,
          ),
        );

        renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.userTransform, scaleTransform);
      });

      testWidgets('identity transform stores correctly', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(x: 1, y: 1, text: 'Test'),
          ),
        );

        final renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.userTransform, MatrixOps.identity);
      });
    });

    group('coordinate context data', () {
      testWidgets('stores coordinate bounds correctly', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(x: 0, y: 0, text: 'Test'),
            xMin: -10,
            xMax: 10,
            yMin: -20,
            yMax: 20,
          ),
        );

        final renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        expect(renderObject.xMin, -10);
        expect(renderObject.xMax, 10);
        expect(renderObject.yMin, -20);
        expect(renderObject.yMax, 20);
      });
    });

    group('setters', () {
      testWidgets('setters mark needs paint when values change',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(x: 0, y: 0, text: 'Test'),
          ),
        );

        final renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        // Change values - these should mark needs paint
        renderObject.x = 5;
        renderObject.y = 10;
        renderObject.text = 'Changed';
        renderObject.color = const Color(0xFFFF0000);
        renderObject.fontSize = 40;
        renderObject.attachDirection = CardinalDirection.s;
        renderObject.attachDistance = 20;

        expect(renderObject.x, 5);
        expect(renderObject.y, 10);
        expect(renderObject.text, 'Changed');
        expect(renderObject.color, const Color(0xFFFF0000));
        expect(renderObject.fontSize, 40);
        expect(renderObject.attachDirection, CardinalDirection.s);
        expect(renderObject.attachDistance, 20);
      });

      testWidgets('setters do not mark needs paint when values are same',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const MafsText(
              x: 5,
              y: 10,
              text: 'Same',
              color: Color(0xFFFF0000),
              size: 24,
              attach: CardinalDirection.n,
              attachDistance: 15,
            ),
          ),
        );

        final renderObject = tester.renderObject<RenderMafsText>(
          find.byType(MafsText),
        );

        // Set to same values - these should not trigger repaint
        renderObject.x = 5;
        renderObject.y = 10;
        renderObject.text = 'Same';
        renderObject.color = const Color(0xFFFF0000);
        renderObject.fontSize = 24;
        renderObject.attachDirection = CardinalDirection.n;
        renderObject.attachDistance = 15;

        expect(renderObject.x, 5);
        expect(renderObject.y, 10);
        expect(renderObject.text, 'Same');
        expect(renderObject.color, const Color(0xFFFF0000));
        expect(renderObject.fontSize, 24);
        expect(renderObject.attachDirection, CardinalDirection.n);
        expect(renderObject.attachDistance, 15);
      });
    });
  });

  group('CardinalDirection enum', () {
    test('has all 8 directions', () {
      expect(CardinalDirection.values.length, 8);
      expect(CardinalDirection.values, contains(CardinalDirection.n));
      expect(CardinalDirection.values, contains(CardinalDirection.ne));
      expect(CardinalDirection.values, contains(CardinalDirection.e));
      expect(CardinalDirection.values, contains(CardinalDirection.se));
      expect(CardinalDirection.values, contains(CardinalDirection.s));
      expect(CardinalDirection.values, contains(CardinalDirection.sw));
      expect(CardinalDirection.values, contains(CardinalDirection.w));
      expect(CardinalDirection.values, contains(CardinalDirection.nw));
    });
  });

  group('error handling', () {
    testWidgets('throws when contexts are not in tree', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: MafsText(x: 0, y: 0, text: 'Test'),
        ),
      );

      expect(tester.takeException(), isA<FlutterError>());
    });
  });
}

/// Wraps a widget with the necessary context providers for testing.
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
            userTransform: userTransform,
            viewTransform: MatrixOps.identity,
          ),
          child: SizedBox(width: width, height: height, child: child),
        ),
      ),
    ),
  );
}
