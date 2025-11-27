import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafs_flutter/src/context/span_context.dart';

void main() {
  group('SpanContextData', () {
    test('stores span values', () {
      const data = SpanContextData(xSpan: 10, ySpan: 6);
      expect(data.xSpan, 10);
      expect(data.ySpan, 6);
    });

    test('equality works correctly', () {
      const data1 = SpanContextData(xSpan: 10, ySpan: 6);
      const data2 = SpanContextData(xSpan: 10, ySpan: 6);
      const data3 = SpanContextData(xSpan: 20, ySpan: 6);

      expect(data1 == data2, true);
      expect(data1 == data3, false);
    });

    test('hashCode is consistent', () {
      const data1 = SpanContextData(xSpan: 10, ySpan: 6);
      const data2 = SpanContextData(xSpan: 10, ySpan: 6);

      expect(data1.hashCode, data2.hashCode);
    });

    test('toString returns readable format', () {
      const data = SpanContextData(xSpan: 10, ySpan: 6);
      expect(data.toString(), contains('SpanContextData'));
      expect(data.toString(), contains('10'));
      expect(data.toString(), contains('6'));
    });
  });

  group('SpanContext widget', () {
    testWidgets('provides data to descendants', (tester) async {
      const testData = SpanContextData(xSpan: 10, ySpan: 6);

      SpanContextData? retrievedData;

      await tester.pumpWidget(
        SpanContext(
          data: testData,
          child: Builder(
            builder: (context) {
              retrievedData = SpanContext.of(context);
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
              () => SpanContext.of(context),
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
            expect(SpanContext.maybeOf(context), isNull);
            return const SizedBox();
          },
        ),
      );
    });

    testWidgets('notifies dependents on change', (tester) async {
      var buildCount = 0;

      await tester.pumpWidget(
        SpanContext(
          data: const SpanContextData(xSpan: 10, ySpan: 6),
          child: Builder(
            builder: (context) {
              SpanContext.of(context);
              buildCount++;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(buildCount, 1);

      // Update with different data
      await tester.pumpWidget(
        SpanContext(
          data: const SpanContextData(xSpan: 20, ySpan: 12),
          child: Builder(
            builder: (context) {
              SpanContext.of(context);
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
      const data = SpanContextData(xSpan: 10, ySpan: 6);

      const widget1 = SpanContext(
        data: data,
        child: SizedBox(),
      );
      const widget2 = SpanContext(
        data: data,
        child: SizedBox(),
      );

      // updateShouldNotify should return false for identical data
      expect(widget1.updateShouldNotify(widget2), false);

      const differentData = SpanContextData(xSpan: 20, ySpan: 12);
      const widget3 = SpanContext(
        data: differentData,
        child: SizedBox(),
      );

      // updateShouldNotify should return true for different data
      expect(widget1.updateShouldNotify(widget3), true);
    });
  });
}
