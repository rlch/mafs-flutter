import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafs_flutter/mafs_flutter.dart';

void main() {
  group('CartesianCoordinates', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        _wrapInMafs(
          Coordinates.cartesian(),
        ),
      );

      expect(find.byType(CartesianCoordinates), findsOneWidget);
    });

    testWidgets('renders with custom axis options', (tester) async {
      await tester.pumpWidget(
        _wrapInMafs(
          Coordinates.cartesian(
            xAxis: const AxisOptions(lines: 2, subdivisions: 4),
            yAxis: const AxisOptions(lines: 1, subdivisions: 5),
          ),
        ),
      );

      expect(find.byType(CartesianCoordinates), findsOneWidget);
    });

    testWidgets('renders with auto-scaling', (tester) async {
      await tester.pumpWidget(
        _wrapInMafs(
          Coordinates.cartesian(auto: true),
        ),
      );

      // Auto-scaling uses CartesianCoordinates.auto() which creates a subclass
      // Just verify it renders without error
      expect(tester.takeException(), isNull);
    });

    testWidgets('can disable x-axis', (tester) async {
      await tester.pumpWidget(
        _wrapInMafs(
          Coordinates.cartesian(
            xAxis: null,
            yAxis: const AxisOptions(),
          ),
        ),
      );

      expect(find.byType(CartesianCoordinates), findsOneWidget);
    });

    testWidgets('can disable y-axis', (tester) async {
      await tester.pumpWidget(
        _wrapInMafs(
          Coordinates.cartesian(
            xAxis: const AxisOptions(),
            yAxis: null,
          ),
        ),
      );

      expect(find.byType(CartesianCoordinates), findsOneWidget);
    });

    testWidgets('renders with subdivisions', (tester) async {
      await tester.pumpWidget(
        _wrapInMafs(
          Coordinates.cartesian(
            subdivisions: 5,
          ),
        ),
      );

      expect(find.byType(CartesianCoordinates), findsOneWidget);
    });

    testWidgets('can disable labels', (tester) async {
      await tester.pumpWidget(
        _wrapInMafs(
          Coordinates.cartesian(
            xAxis: const AxisOptions(labels: null),
            yAxis: const AxisOptions(labels: null),
          ),
        ),
      );

      expect(find.byType(CartesianCoordinates), findsOneWidget);
    });

    testWidgets('can disable grid lines', (tester) async {
      await tester.pumpWidget(
        _wrapInMafs(
          Coordinates.cartesian(
            xAxis: const AxisOptions(lines: null),
            yAxis: const AxisOptions(lines: null),
          ),
        ),
      );

      expect(find.byType(CartesianCoordinates), findsOneWidget);
    });

    testWidgets('can disable axes', (tester) async {
      await tester.pumpWidget(
        _wrapInMafs(
          Coordinates.cartesian(
            xAxis: const AxisOptions(axis: false),
            yAxis: const AxisOptions(axis: false),
          ),
        ),
      );

      expect(find.byType(CartesianCoordinates), findsOneWidget);
    });
  });

  group('AxisOptions', () {
    test('has correct defaults', () {
      const options = AxisOptions();

      expect(options.axis, true);
      expect(options.lines, 1.0);
      expect(options.labels, isNotNull);
      expect(options.subdivisions, isNull);
    });

    test('copyWith creates copy with changed values', () {
      const original = AxisOptions(
        axis: true,
        lines: 1.0,
        subdivisions: 4,
      );

      final copy = original.copyWith(
        axis: false,
        lines: 2.0,
      );

      expect(copy.axis, false);
      expect(copy.lines, 2.0);
      expect(copy.subdivisions, 4); // Unchanged
    });
  });

  group('defaultLabelMaker', () {
    test('formats integers without decimals', () {
      expect(defaultLabelMaker(1.0), '1');
      expect(defaultLabelMaker(-5.0), '-5');
      expect(defaultLabelMaker(0.0), '0');
    });

    test('formats decimals with decimal point', () {
      expect(defaultLabelMaker(1.5), '1.5');
      expect(defaultLabelMaker(-2.25), '-2.25');
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
