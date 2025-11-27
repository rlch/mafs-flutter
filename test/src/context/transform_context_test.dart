import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafs_flutter/src/context/transform_context.dart';
import 'package:mafs_flutter/src/vec.dart';

void main() {
  group('TransformContextData', () {
    test('stores transform matrices', () {
      final data = TransformContextData(
        userTransform: MatrixOps.identity,
        viewTransform: MatrixOps.scale(2, 2),
      );

      expect(data.userTransform, MatrixOps.identity);
      expect(data.viewTransform, MatrixOps.scale(2, 2));
    });

    test('combinedTransform multiplies matrices', () {
      final userTransform = MatrixOps.translate(10, 20);
      final viewTransform = MatrixOps.scale(2, 2);

      final data = TransformContextData(
        userTransform: userTransform,
        viewTransform: viewTransform,
      );

      final combined = data.combinedTransform;
      const point = Offset(1, 1);
      final result = point.transform(combined);

      // First user transform: (1+10, 1+20) = (11, 21)
      // Then view transform: (11*2, 21*2) = (22, 42)
      expect(result.dx, closeTo(22, 0.0001));
      expect(result.dy, closeTo(42, 0.0001));
    });

    test('equality works correctly', () {
      final data1 = TransformContextData(
        userTransform: MatrixOps.identity,
        viewTransform: MatrixOps.scale(2, 2),
      );
      final data2 = TransformContextData(
        userTransform: MatrixOps.identity,
        viewTransform: MatrixOps.scale(2, 2),
      );
      final data3 = TransformContextData(
        userTransform: MatrixOps.translate(1, 1),
        viewTransform: MatrixOps.scale(2, 2),
      );

      expect(data1 == data2, true);
      expect(data1 == data3, false);
    });

    test('hashCode is consistent', () {
      final data1 = TransformContextData(
        userTransform: MatrixOps.identity,
        viewTransform: MatrixOps.scale(2, 2),
      );
      final data2 = TransformContextData(
        userTransform: MatrixOps.identity,
        viewTransform: MatrixOps.scale(2, 2),
      );

      expect(data1.hashCode, data2.hashCode);
    });

    test('toString returns readable format', () {
      final data = TransformContextData(
        userTransform: MatrixOps.identity,
        viewTransform: MatrixOps.scale(2, 2),
      );

      expect(data.toString(), contains('TransformContextData'));
    });
  });

  group('TransformContext widget', () {
    testWidgets('provides data to descendants', (tester) async {
      final testData = TransformContextData(
        userTransform: MatrixOps.identity,
        viewTransform: MatrixOps.scale(2, 2),
      );

      TransformContextData? retrievedData;

      await tester.pumpWidget(
        TransformContext(
          data: testData,
          child: Builder(
            builder: (context) {
              retrievedData = TransformContext.of(context);
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
              () => TransformContext.of(context),
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
            expect(TransformContext.maybeOf(context), isNull);
            return const SizedBox();
          },
        ),
      );
    });

    testWidgets('notifies dependents on change', (tester) async {
      var buildCount = 0;

      await tester.pumpWidget(
        TransformContext(
          data: TransformContextData(
            userTransform: MatrixOps.identity,
            viewTransform: MatrixOps.scale(2, 2),
          ),
          child: Builder(
            builder: (context) {
              TransformContext.of(context);
              buildCount++;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(buildCount, 1);

      // Update with different data
      await tester.pumpWidget(
        TransformContext(
          data: TransformContextData(
            userTransform: MatrixOps.translate(5, 5),
            viewTransform: MatrixOps.scale(2, 2),
          ),
          child: Builder(
            builder: (context) {
              TransformContext.of(context);
              buildCount++;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(buildCount, 2);
    });
  });

  group('TransformAspect fine-grained dependencies', () {
    testWidgets('updateShouldNotifyDependent works correctly for aspects',
        (tester) async {
      // Test the updateShouldNotifyDependent method directly
      final data1 = TransformContextData(
        userTransform: MatrixOps.identity,
        viewTransform: MatrixOps.scale(2, 2),
      );
      final data2 = TransformContextData(
        userTransform: MatrixOps.translate(10, 10),
        viewTransform: MatrixOps.scale(2, 2), // Same viewTransform
      );

      final widget1 = TransformContext(
        data: data1,
        child: const SizedBox(),
      );
      final widget2 = TransformContext(
        data: data2,
        child: const SizedBox(),
      );

      // Should notify for userTransform aspect since it changed
      expect(
        widget2.updateShouldNotifyDependent(widget1, {TransformAspect.userTransform}),
        true,
      );

      // Should NOT notify for viewTransform aspect since it didn't change
      expect(
        widget2.updateShouldNotifyDependent(widget1, {TransformAspect.viewTransform}),
        false,
      );

      // Now test when viewTransform changes
      final data3 = TransformContextData(
        userTransform: MatrixOps.identity,
        viewTransform: MatrixOps.scale(3, 3), // Different viewTransform
      );
      final widget3 = TransformContext(
        data: data3,
        child: const SizedBox(),
      );

      // Should notify for viewTransform aspect
      expect(
        widget3.updateShouldNotifyDependent(widget1, {TransformAspect.viewTransform}),
        true,
      );

      // Should NOT notify for userTransform aspect since it didn't change
      expect(
        widget3.updateShouldNotifyDependent(widget1, {TransformAspect.userTransform}),
        false,
      );
    });
  });
}
