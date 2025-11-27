import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafs_flutter/src/context/coordinate_context.dart';

void main() {
  group('CoordinateContextData', () {
    test('stores all coordinate values', () {
      const data = CoordinateContextData(
        xMin: -5,
        xMax: 5,
        yMin: -3,
        yMax: 3,
        width: 800,
        height: 600,
      );

      expect(data.xMin, -5);
      expect(data.xMax, 5);
      expect(data.yMin, -3);
      expect(data.yMax, 3);
      expect(data.width, 800);
      expect(data.height, 600);
    });

    test('equality works correctly', () {
      const data1 = CoordinateContextData(
        xMin: -5,
        xMax: 5,
        yMin: -3,
        yMax: 3,
        width: 800,
        height: 600,
      );
      const data2 = CoordinateContextData(
        xMin: -5,
        xMax: 5,
        yMin: -3,
        yMax: 3,
        width: 800,
        height: 600,
      );
      const data3 = CoordinateContextData(
        xMin: -10,
        xMax: 5,
        yMin: -3,
        yMax: 3,
        width: 800,
        height: 600,
      );

      expect(data1 == data2, true);
      expect(data1 == data3, false);
    });

    test('hashCode is consistent', () {
      const data1 = CoordinateContextData(
        xMin: -5,
        xMax: 5,
        yMin: -3,
        yMax: 3,
        width: 800,
        height: 600,
      );
      const data2 = CoordinateContextData(
        xMin: -5,
        xMax: 5,
        yMin: -3,
        yMax: 3,
        width: 800,
        height: 600,
      );

      expect(data1.hashCode, data2.hashCode);
    });

    test('toString returns readable format', () {
      const data = CoordinateContextData(
        xMin: -5,
        xMax: 5,
        yMin: -3,
        yMax: 3,
        width: 800,
        height: 600,
      );

      expect(data.toString(), contains('CoordinateContextData'));
      expect(data.toString(), contains('-5'));
      expect(data.toString(), contains('800'));
    });
  });

  group('CoordinateContext widget', () {
    testWidgets('provides data to descendants', (tester) async {
      const testData = CoordinateContextData(
        xMin: -5,
        xMax: 5,
        yMin: -3,
        yMax: 3,
        width: 800,
        height: 600,
      );

      CoordinateContextData? retrievedData;

      await tester.pumpWidget(
        CoordinateContext(
          data: testData,
          child: Builder(
            builder: (context) {
              retrievedData = CoordinateContext.of(context);
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
              () => CoordinateContext.of(context),
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
            expect(CoordinateContext.maybeOf(context), isNull);
            return const SizedBox();
          },
        ),
      );
    });

    testWidgets('notifies dependents on change', (tester) async {
      var buildCount = 0;

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
          child: Builder(
            builder: (context) {
              CoordinateContext.of(context);
              buildCount++;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(buildCount, 1);

      // Update with different data
      await tester.pumpWidget(
        CoordinateContext(
          data: const CoordinateContextData(
            xMin: -10,
            xMax: 10,
            yMin: -6,
            yMax: 6,
            width: 800,
            height: 600,
          ),
          child: Builder(
            builder: (context) {
              CoordinateContext.of(context);
              buildCount++;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(buildCount, 2);
    });

    testWidgets('updateShouldNotify returns false when data is unchanged', (tester) async {
      // Test that the updateShouldNotify method works correctly
      const data = CoordinateContextData(
        xMin: -5,
        xMax: 5,
        yMin: -3,
        yMax: 3,
        width: 800,
        height: 600,
      );

      const widget1 = CoordinateContext(
        data: data,
        child: SizedBox(),
      );
      const widget2 = CoordinateContext(
        data: data,
        child: SizedBox(),
      );

      // updateShouldNotify should return false for identical data
      expect(widget1.updateShouldNotify(widget2), false);

      const differentData = CoordinateContextData(
        xMin: -10,
        xMax: 10,
        yMin: -3,
        yMax: 3,
        width: 800,
        height: 600,
      );
      const widget3 = CoordinateContext(
        data: differentData,
        child: SizedBox(),
      );

      // updateShouldNotify should return true for different data
      expect(widget1.updateShouldNotify(widget3), true);
    });
  });

  group('CoordinateAspect fine-grained dependencies', () {
    testWidgets('updateShouldNotifyDependent works correctly for aspects', (tester) async {
      // Test the updateShouldNotifyDependent method directly
      const data1 = CoordinateContextData(
        xMin: -5,
        xMax: 5,
        yMin: -3,
        yMax: 3,
        width: 800,
        height: 600,
      );
      const data2 = CoordinateContextData(
        xMin: -10,
        xMax: 10,
        yMin: -3,  // Same yBounds
        yMax: 3,
        width: 800,
        height: 600,
      );

      const widget1 = CoordinateContext(
        data: data1,
        child: SizedBox(),
      );
      const widget2 = CoordinateContext(
        data: data2,
        child: SizedBox(),
      );

      // Should notify for xBounds aspect since x changed
      expect(
        widget2.updateShouldNotifyDependent(widget1, {CoordinateAspect.xBounds}),
        true,
      );

      // Should NOT notify for yBounds aspect since y didn't change
      expect(
        widget2.updateShouldNotifyDependent(widget1, {CoordinateAspect.yBounds}),
        false,
      );

      // Should NOT notify for dimensions aspect since width/height didn't change
      expect(
        widget2.updateShouldNotifyDependent(widget1, {CoordinateAspect.dimensions}),
        false,
      );

      // Now test when dimensions change
      const data3 = CoordinateContextData(
        xMin: -5,
        xMax: 5,
        yMin: -3,
        yMax: 3,
        width: 1024,  // Different width
        height: 768,  // Different height
      );
      const widget3 = CoordinateContext(
        data: data3,
        child: SizedBox(),
      );

      // Should notify for dimensions aspect
      expect(
        widget3.updateShouldNotifyDependent(widget1, {CoordinateAspect.dimensions}),
        true,
      );

      // Should NOT notify for bounds aspects since they didn't change
      expect(
        widget3.updateShouldNotifyDependent(widget1, {CoordinateAspect.xBounds}),
        false,
      );
      expect(
        widget3.updateShouldNotifyDependent(widget1, {CoordinateAspect.yBounds}),
        false,
      );
    });
  });
}
