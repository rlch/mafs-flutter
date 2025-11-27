import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafs_flutter/mafs_flutter.dart';

void main() {
  group('PolarCoordinates', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        _wrapInMafs(
          Coordinates.polar(),
        ),
      );

      expect(find.byType(PolarCoordinates), findsOneWidget);
    });

    testWidgets('renders with custom line spacing', (tester) async {
      await tester.pumpWidget(
        _wrapInMafs(
          Coordinates.polar(lines: 2),
        ),
      );

      expect(find.byType(PolarCoordinates), findsOneWidget);
    });

    testWidgets('renders with subdivisions', (tester) async {
      await tester.pumpWidget(
        _wrapInMafs(
          Coordinates.polar(subdivisions: 4),
        ),
      );

      expect(find.byType(PolarCoordinates), findsOneWidget);
    });

    testWidgets('can disable x-axis', (tester) async {
      await tester.pumpWidget(
        _wrapInMafs(
          Coordinates.polar(
            xAxis: null,
            yAxis: const AxisOptions(),
          ),
        ),
      );

      expect(find.byType(PolarCoordinates), findsOneWidget);
    });

    testWidgets('can disable y-axis', (tester) async {
      await tester.pumpWidget(
        _wrapInMafs(
          Coordinates.polar(
            xAxis: const AxisOptions(),
            yAxis: null,
          ),
        ),
      );

      expect(find.byType(PolarCoordinates), findsOneWidget);
    });

    testWidgets('can disable labels', (tester) async {
      await tester.pumpWidget(
        _wrapInMafs(
          Coordinates.polar(
            xAxis: const AxisOptions(labels: null),
            yAxis: const AxisOptions(labels: null),
          ),
        ),
      );

      expect(find.byType(PolarCoordinates), findsOneWidget);
    });

    testWidgets('can disable axes', (tester) async {
      await tester.pumpWidget(
        _wrapInMafs(
          Coordinates.polar(
            xAxis: const AxisOptions(axis: false),
            yAxis: const AxisOptions(axis: false),
          ),
        ),
      );

      expect(find.byType(PolarCoordinates), findsOneWidget);
    });

    testWidgets('renders when origin is outside viewport', (tester) async {
      // When viewing a region that doesn't include the origin,
      // polar coordinates should still render correctly
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 500,
              height: 500,
              child: Mafs(
                width: 500,
                height: 500,
                // ViewBox that doesn't include origin
                viewBox: const ViewBox(x: (5, 15), y: (5, 15), padding: 0),
                children: [
                  Coordinates.polar(),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PolarCoordinates), findsOneWidget);
    });
  });
}

Widget _wrapInMafs(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Center(
      child: SizedBox(
        width: 500,
        height: 500,
        child: Mafs(
          width: 500,
          height: 500,
          viewBox: const ViewBox(x: (-5, 5), y: (-5, 5), padding: 0),
          children: [child],
        ),
      ),
    ),
  );
}
