import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafs_flutter/src/context/coordinate_context.dart';
import 'package:mafs_flutter/src/context/pane_context.dart';

void main() {
  group('PaneContextData', () {
    test('stores pane values', () {
      const data = PaneContextData(
        xPanes: [(-4.0, 0.0), (0.0, 4.0)],
        yPanes: [(-4.0, 0.0), (0.0, 4.0)],
        xPaneRange: (-4.0, 4.0),
        yPaneRange: (-4.0, 4.0),
      );

      expect(data.xPanes.length, 2);
      expect(data.yPanes.length, 2);
      expect(data.xPaneRange, (-4.0, 4.0));
      expect(data.yPaneRange, (-4.0, 4.0));
    });

    test('empty constant exists', () {
      expect(PaneContextData.empty.xPanes, isEmpty);
      expect(PaneContextData.empty.yPanes, isEmpty);
    });

    test('equality works correctly', () {
      const data1 = PaneContextData(
        xPanes: [(-4.0, 0.0), (0.0, 4.0)],
        yPanes: [(-4.0, 0.0), (0.0, 4.0)],
        xPaneRange: (-4.0, 4.0),
        yPaneRange: (-4.0, 4.0),
      );
      const data2 = PaneContextData(
        xPanes: [(-4.0, 0.0), (0.0, 4.0)],
        yPanes: [(-4.0, 0.0), (0.0, 4.0)],
        xPaneRange: (-4.0, 4.0),
        yPaneRange: (-4.0, 4.0),
      );
      const data3 = PaneContextData(
        xPanes: [(-8.0, 0.0), (0.0, 8.0)],
        yPanes: [(-4.0, 0.0), (0.0, 4.0)],
        xPaneRange: (-8.0, 8.0),
        yPaneRange: (-4.0, 4.0),
      );

      expect(data1 == data2, true);
      expect(data1 == data3, false);
    });

    test('toString returns readable format', () {
      const data = PaneContextData(
        xPanes: [(-4.0, 0.0)],
        yPanes: [(-4.0, 0.0)],
        xPaneRange: (-4.0, 4.0),
        yPaneRange: (-4.0, 4.0),
      );

      expect(data.toString(), contains('PaneContextData'));
    });
  });

  group('PaneContext widget', () {
    testWidgets('provides data to descendants', (tester) async {
      const testData = PaneContextData(
        xPanes: [(-4.0, 0.0), (0.0, 4.0)],
        yPanes: [(-4.0, 0.0), (0.0, 4.0)],
        xPaneRange: (-4.0, 4.0),
        yPaneRange: (-4.0, 4.0),
      );

      PaneContextData? retrievedData;

      await tester.pumpWidget(
        PaneContext(
          data: testData,
          child: Builder(
            builder: (context) {
              retrievedData = PaneContext.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(retrievedData, testData);
    });

    testWidgets('of throws when not in tree', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            expect(
              () => PaneContext.of(context),
              throwsA(isA<FlutterError>()),
            );
            return const SizedBox();
          },
        ),
      );
    });

    testWidgets('maybeOf returns null when not in tree', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            expect(PaneContext.maybeOf(context), isNull);
            return const SizedBox();
          },
        ),
      );
    });
  });

  group('PaneManager', () {
    testWidgets('computes panes from coordinate context', (tester) async {
      PaneContextData? paneData;

      await tester.pumpWidget(
        CoordinateContext(
          data: const CoordinateContextData(
            xMin: -5,
            xMax: 5,
            yMin: -3,
            yMax: 3,
            width: 800,
            height: 600,
          ),
          child: PaneManager(
            child: Builder(
              builder: (context) {
                paneData = PaneContext.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(paneData, isNotNull);
      expect(paneData!.xPanes, isNotEmpty);
      expect(paneData!.yPanes, isNotEmpty);

      // Verify panes cover the coordinate range
      expect(paneData!.xPaneRange.$1, lessThanOrEqualTo(-5));
      expect(paneData!.xPaneRange.$2, greaterThanOrEqualTo(5));
      expect(paneData!.yPaneRange.$1, lessThanOrEqualTo(-3));
      expect(paneData!.yPaneRange.$2, greaterThanOrEqualTo(3));
    });

    testWidgets('panes are contiguous intervals', (tester) async {
      PaneContextData? paneData;

      await tester.pumpWidget(
        CoordinateContext(
          data: const CoordinateContextData(
            xMin: -5,
            xMax: 5,
            yMin: -3,
            yMax: 3,
            width: 800,
            height: 600,
          ),
          child: PaneManager(
            child: Builder(
              builder: (context) {
                paneData = PaneContext.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // Verify xPanes are contiguous
      for (var i = 0; i < paneData!.xPanes.length - 1; i++) {
        final current = paneData!.xPanes[i];
        final next = paneData!.xPanes[i + 1];
        expect(current.$2, closeTo(next.$1, 0.0001));
      }

      // Verify yPanes are contiguous
      for (var i = 0; i < paneData!.yPanes.length - 1; i++) {
        final current = paneData!.yPanes[i];
        final next = paneData!.yPanes[i + 1];
        expect(current.$2, closeTo(next.$1, 0.0001));
      }
    });

    testWidgets('updates panes when coordinates change', (tester) async {
      PaneContextData? paneData1;
      PaneContextData? paneData2;

      await tester.pumpWidget(
        CoordinateContext(
          data: const CoordinateContextData(
            xMin: -5,
            xMax: 5,
            yMin: -3,
            yMax: 3,
            width: 800,
            height: 600,
          ),
          child: PaneManager(
            child: Builder(
              builder: (context) {
                paneData1 = PaneContext.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // Change to much larger view
      await tester.pumpWidget(
        CoordinateContext(
          data: const CoordinateContextData(
            xMin: -50,
            xMax: 50,
            yMin: -30,
            yMax: 30,
            width: 800,
            height: 600,
          ),
          child: PaneManager(
            child: Builder(
              builder: (context) {
                paneData2 = PaneContext.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // Pane ranges should be different
      expect(paneData1, isNot(equals(paneData2)));
      expect(paneData2!.xPaneRange.$2 - paneData2!.xPaneRange.$1,
          greaterThan(paneData1!.xPaneRange.$2 - paneData1!.xPaneRange.$1));
    });
  });
}
