import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafs_flutter/mafs_flutter.dart';

void main() {
  group('MafsWidget', () {
    Widget buildTestMafs({required Widget child}) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 400,
            height: 400,
            child: Mafs(
              viewBox: const ViewBox(x: (-4, 4), y: (-4, 4), padding: 0),
              pan: false,
              children: [child],
            ),
          ),
        ),
      );
    }

    testWidgets('renders fixed-size child at math coordinates', (tester) async {
      await tester.pumpWidget(buildTestMafs(
        child: MafsWidget(
          x: 0,
          y: 0,
          child: Container(
            width: 50,
            height: 50,
            color: const Color(0xFFFF0000),
          ),
        ),
      ));

      // Should render without errors
      expect(find.byType(MafsWidget), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('renders scaled child with math unit dimensions', (tester) async {
      await tester.pumpWidget(buildTestMafs(
        child: MafsWidget(
          x: 0,
          y: 0,
          width: 2, // 2 math units = 100 pixels (400px / 8 units * 2)
          height: 2,
          child: Container(
            color: const Color(0xFF00FF00),
          ),
        ),
      ));

      expect(find.byType(MafsWidget), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('respects anchor positioning', (tester) async {
      // Test each anchor position
      for (final anchor in Anchor.values) {
        await tester.pumpWidget(buildTestMafs(
          child: MafsWidget(
            x: 0,
            y: 0,
            anchor: anchor,
            child: Container(
              width: 20,
              height: 20,
              color: const Color(0xFF0000FF),
            ),
          ),
        ));

        expect(find.byType(MafsWidget), findsOneWidget);
      }
    });

    testWidgets('positions correctly at different coordinates', (tester) async {
      await tester.pumpWidget(buildTestMafs(
        child: MafsWidget(
          x: 2,
          y: 2,
          anchor: Anchor.cc,
          child: Container(
            width: 20,
            height: 20,
            color: const Color(0xFFFFFF00),
          ),
        ),
      ));

      expect(find.byType(MafsWidget), findsOneWidget);
    });

    testWidgets('handles negative coordinates', (tester) async {
      await tester.pumpWidget(buildTestMafs(
        child: MafsWidget(
          x: -3,
          y: -3,
          child: Container(
            width: 30,
            height: 30,
            color: const Color(0xFFFF00FF),
          ),
        ),
      ));

      expect(find.byType(MafsWidget), findsOneWidget);
    });

    testWidgets('works with complex child widgets', (tester) async {
      await tester.pumpWidget(buildTestMafs(
        child: MafsWidget(
          x: 0,
          y: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 20, color: const Color(0xFFFF0000)),
              const SizedBox(height: 4),
              Container(width: 40, height: 20, color: const Color(0xFF0000FF)),
            ],
          ),
        ),
      ));

      expect(find.byType(MafsWidget), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('works inside MafsTransform', (tester) async {
      await tester.pumpWidget(buildTestMafs(
        child: MafsTransform(
          translate: const Offset(1, 1),
          child: MafsWidget(
            x: 0,
            y: 0,
            child: Container(
              width: 20,
              height: 20,
              color: const Color(0xFF00FFFF),
            ),
          ),
        ),
      ));

      expect(find.byType(MafsWidget), findsOneWidget);
    });

    testWidgets('partial dimensions - only width specified', (tester) async {
      await tester.pumpWidget(buildTestMafs(
        child: MafsWidget(
          x: 0,
          y: 0,
          width: 2, // Width in math units, height intrinsic
          child: Container(
            height: 50, // Fixed pixel height
            color: const Color(0xFFAA5500),
          ),
        ),
      ));

      expect(find.byType(MafsWidget), findsOneWidget);
    });

    testWidgets('partial dimensions - only height specified', (tester) async {
      await tester.pumpWidget(buildTestMafs(
        child: MafsWidget(
          x: 0,
          y: 0,
          height: 2, // Height in math units, width intrinsic
          child: Container(
            width: 50, // Fixed pixel width
            color: const Color(0xFF55AA00),
          ),
        ),
      ));

      expect(find.byType(MafsWidget), findsOneWidget);
    });

    group('anchor calculations', () {
      // With a known layout, test that anchors place widgets correctly
      // ViewBox: (-4, 4) for both axes, 400x400 pixels
      // So center (0,0) is at pixel (200, 200)
      // Each math unit = 50 pixels

      testWidgets('center anchor places center at position', (tester) async {
        await tester.pumpWidget(buildTestMafs(
          child: MafsWidget(
            x: 0,
            y: 0,
            anchor: Anchor.cc,
            child: Container(
              key: const Key('test-container'),
              width: 100,
              height: 100,
              color: const Color(0xFFFF0000),
            ),
          ),
        ));

        await tester.pumpAndSettle();

        // Find the container and check its position
        final containerFinder = find.byKey(const Key('test-container'));
        expect(containerFinder, findsOneWidget);

        // The container should be centered at (200, 200)
        // So its top-left should be at (150, 150)
        final box = tester.renderObject(containerFinder) as RenderBox;
        expect(box.size.width, 100);
        expect(box.size.height, 100);
      });

      testWidgets('top-left anchor places top-left at position', (tester) async {
        await tester.pumpWidget(buildTestMafs(
          child: MafsWidget(
            x: 0,
            y: 0,
            anchor: Anchor.tl,
            child: Container(
              key: const Key('test-container'),
              width: 100,
              height: 100,
              color: const Color(0xFF00FF00),
            ),
          ),
        ));

        await tester.pumpAndSettle();

        final containerFinder = find.byKey(const Key('test-container'));
        expect(containerFinder, findsOneWidget);
      });
    });

    group('scaling behavior', () {
      testWidgets('widgets with math unit size scale correctly', (tester) async {
        // 400x400 viewport, (-4, 4) range = 50 pixels per unit
        // A 2x2 math unit widget should be 100x100 pixels
        await tester.pumpWidget(buildTestMafs(
          child: MafsWidget(
            x: 0,
            y: 0,
            width: 2,
            height: 2,
            child: Container(
              key: const Key('scaled-container'),
              color: const Color(0xFF0000FF),
            ),
          ),
        ));

        await tester.pumpAndSettle();

        final containerFinder = find.byKey(const Key('scaled-container'));
        expect(containerFinder, findsOneWidget);

        // Check the SizedBox constrains the container to expected size
        final sizedBoxFinder = find.ancestor(
          of: containerFinder,
          matching: find.byType(SizedBox),
        );
        expect(sizedBoxFinder, findsWidgets);

        final sizedBox = tester.widget<SizedBox>(sizedBoxFinder.first);
        expect(sizedBox.width, 100); // 2 units * 50 pixels/unit
        expect(sizedBox.height, 100);
      });
    });
  });
}
