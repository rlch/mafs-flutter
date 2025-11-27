import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafs_flutter/mafs_flutter.dart';

void main() {
  group('MafsCircle', () {
    Widget buildTestWidget(Widget child) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: MafsTheme(
          data: const MafsThemeData(),
          child: CoordinateContext(
            data: const CoordinateContextData(
              xMin: -5,
              xMax: 5,
              yMin: -5,
              yMax: 5,
              width: 400,
              height: 400,
            ),
            child: TransformContext(
              data: TransformContextData(
                userTransform: MatrixOps.identity,
                viewTransform: MatrixBuilder().scale(40, -40).build(),
              ),
              child: SizedBox(
                width: 400,
                height: 400,
                child: child,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('creates widget with required parameters', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const MafsCircle(
            center: Offset(0, 0),
            radius: 1,
          ),
        ),
      );

      expect(find.byType(MafsCircle), findsOneWidget);
      expect(find.byType(MafsEllipse), findsOneWidget);
    });

    testWidgets('delegates to MafsEllipse with equal radii', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const MafsCircle(
            center: Offset(2, 3),
            radius: 5,
          ),
        ),
      );

      final ellipse = tester.widget<MafsEllipse>(find.byType(MafsEllipse));
      expect(ellipse.center, const Offset(2, 3));
      expect(ellipse.radius, const Offset(5, 5));
    });

    testWidgets('passes color to MafsEllipse', (tester) async {
      const testColor = Color(0xFF123456);

      await tester.pumpWidget(
        buildTestWidget(
          const MafsCircle(
            center: Offset(0, 0),
            radius: 1,
            color: testColor,
          ),
        ),
      );

      final ellipse = tester.widget<MafsEllipse>(find.byType(MafsEllipse));
      expect(ellipse.color, testColor);
    });

    testWidgets('passes weight to MafsEllipse', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const MafsCircle(
            center: Offset(0, 0),
            radius: 1,
            weight: 5,
          ),
        ),
      );

      final ellipse = tester.widget<MafsEllipse>(find.byType(MafsEllipse));
      expect(ellipse.weight, 5);
    });

    testWidgets('passes fillOpacity to MafsEllipse', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const MafsCircle(
            center: Offset(0, 0),
            radius: 1,
            fillOpacity: 0.5,
          ),
        ),
      );

      final ellipse = tester.widget<MafsEllipse>(find.byType(MafsEllipse));
      expect(ellipse.fillOpacity, 0.5);
    });

    testWidgets('passes strokeOpacity to MafsEllipse', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const MafsCircle(
            center: Offset(0, 0),
            radius: 1,
            strokeOpacity: 0.75,
          ),
        ),
      );

      final ellipse = tester.widget<MafsEllipse>(find.byType(MafsEllipse));
      expect(ellipse.strokeOpacity, 0.75);
    });

    testWidgets('passes strokeStyle to MafsEllipse', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const MafsCircle(
            center: Offset(0, 0),
            radius: 1,
            strokeStyle: StrokeStyle.dashed,
          ),
        ),
      );

      final ellipse = tester.widget<MafsEllipse>(find.byType(MafsEllipse));
      expect(ellipse.strokeStyle, StrokeStyle.dashed);
    });

    group('default values', () {
      testWidgets('weight defaults to 2', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const MafsCircle(
              center: Offset(0, 0),
              radius: 1,
            ),
          ),
        );

        final ellipse = tester.widget<MafsEllipse>(find.byType(MafsEllipse));
        expect(ellipse.weight, 2);
      });

      testWidgets('fillOpacity defaults to 0.15', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const MafsCircle(
              center: Offset(0, 0),
              radius: 1,
            ),
          ),
        );

        final ellipse = tester.widget<MafsEllipse>(find.byType(MafsEllipse));
        expect(ellipse.fillOpacity, 0.15);
      });

      testWidgets('strokeOpacity defaults to 1.0', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const MafsCircle(
              center: Offset(0, 0),
              radius: 1,
            ),
          ),
        );

        final ellipse = tester.widget<MafsEllipse>(find.byType(MafsEllipse));
        expect(ellipse.strokeOpacity, 1.0);
      });

      testWidgets('strokeStyle defaults to solid', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const MafsCircle(
              center: Offset(0, 0),
              radius: 1,
            ),
          ),
        );

        final ellipse = tester.widget<MafsEllipse>(find.byType(MafsEllipse));
        expect(ellipse.strokeStyle, StrokeStyle.solid);
      });

      testWidgets('color defaults to null (uses theme)', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const MafsCircle(
              center: Offset(0, 0),
              radius: 1,
            ),
          ),
        );

        final ellipse = tester.widget<MafsEllipse>(find.byType(MafsEllipse));
        expect(ellipse.color, isNull);
      });

      testWidgets('ellipse angle defaults to 0 (circle is symmetric)', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const MafsCircle(
              center: Offset(0, 0),
              radius: 1,
            ),
          ),
        );

        final ellipse = tester.widget<MafsEllipse>(find.byType(MafsEllipse));
        expect(ellipse.angle, 0);
      });
    });

    testWidgets('renders without errors in Mafs context', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Mafs(
            viewBox: const ViewBox(x: (-5, 5), y: (-5, 5)),
            children: const [
              MafsCircle(
                center: Offset(0, 0),
                radius: 2,
                color: MafsColors.blue,
              ),
            ],
          ),
        ),
      );

      expect(find.byType(MafsCircle), findsOneWidget);
      expect(find.byType(MafsEllipse), findsOneWidget);
    });

    testWidgets('renders multiple circles', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Mafs(
            viewBox: const ViewBox(x: (-5, 5), y: (-5, 5)),
            children: const [
              MafsCircle(
                center: Offset(-2, 0),
                radius: 1,
                color: MafsColors.red,
              ),
              MafsCircle(
                center: Offset(2, 0),
                radius: 1.5,
                color: MafsColors.blue,
              ),
            ],
          ),
        ),
      );

      expect(find.byType(MafsCircle), findsNWidgets(2));
      expect(find.byType(MafsEllipse), findsNWidgets(2));
    });

    testWidgets('updates when properties change', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const MafsCircle(
            center: Offset(0, 0),
            radius: 1,
          ),
        ),
      );

      var ellipse = tester.widget<MafsEllipse>(find.byType(MafsEllipse));
      expect(ellipse.radius, const Offset(1, 1));

      await tester.pumpWidget(
        buildTestWidget(
          const MafsCircle(
            center: Offset(1, 2),
            radius: 3,
            color: MafsColors.red,
          ),
        ),
      );

      ellipse = tester.widget<MafsEllipse>(find.byType(MafsEllipse));
      expect(ellipse.center, const Offset(1, 2));
      expect(ellipse.radius, const Offset(3, 3));
      expect(ellipse.color, MafsColors.red);
    });
  });
}
