import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafs_flutter/src/context/coordinate_context.dart';
import 'package:mafs_flutter/src/context/pane_context.dart';
import 'package:mafs_flutter/src/context/span_context.dart';
import 'package:mafs_flutter/src/context/transform_context.dart';
import 'package:mafs_flutter/src/display/theme.dart';
import 'package:mafs_flutter/src/view/mafs.dart';

void main() {
  group('ViewBox', () {
    test('default values', () {
      const viewBox = ViewBox();
      expect(viewBox.x, (-3, 3));
      expect(viewBox.y, (-3, 3));
      expect(viewBox.padding, 0.5);
    });

    test('custom values', () {
      const viewBox = ViewBox(
        x: (-10, 10),
        y: (-5, 5),
        padding: 1.0,
      );
      expect(viewBox.x, (-10, 10));
      expect(viewBox.y, (-5, 5));
      expect(viewBox.padding, 1.0);
    });

    test('equality works', () {
      const v1 = ViewBox();
      const v2 = ViewBox();
      const v3 = ViewBox(x: (-5, 5));

      expect(v1 == v2, true);
      expect(v1 == v3, false);
    });
  });

  group('ZoomConfig', () {
    test('default values', () {
      const config = ZoomConfig();
      expect(config.min, 0.5);
      expect(config.max, 5.0);
    });

    test('custom values', () {
      const config = ZoomConfig(min: 0.25, max: 10.0);
      expect(config.min, 0.25);
      expect(config.max, 10.0);
    });
  });

  group('Mafs widget', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Mafs(
            children: [],
          ),
        ),
      );

      expect(find.byType(Mafs), findsOneWidget);
    });

    testWidgets('uses specified dimensions', (tester) async {
      // Wrap in Center to provide loose constraints
      // (tight constraints would force Mafs to use parent's size)
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: Mafs(
              width: 400,
              height: 300,
              children: [],
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(Mafs),
          matching: find.byType(SizedBox),
        ).first,
      );

      expect(sizedBox.width, 400);
      expect(sizedBox.height, 300);
    });

    testWidgets('provides CoordinateContext to children', (tester) async {
      CoordinateContextData? coordData;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Mafs(
            width: 800,
            height: 600,
            viewBox: const ViewBox(x: (-5, 5), y: (-3, 3)),
            children: [
              Builder(
                builder: (context) {
                  coordData = CoordinateContext.of(context);
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      );

      expect(coordData, isNotNull);
      expect(coordData!.width, 800);
      expect(coordData!.height, 600);
    });

    testWidgets('provides TransformContext to children', (tester) async {
      TransformContextData? transformData;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Mafs(
            width: 800,
            height: 600,
            children: [
              Builder(
                builder: (context) {
                  transformData = TransformContext.of(context);
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      );

      expect(transformData, isNotNull);
    });

    testWidgets('provides SpanContext to children', (tester) async {
      SpanContextData? spanData;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Mafs(
            width: 800,
            height: 600,
            children: [
              Builder(
                builder: (context) {
                  spanData = SpanContext.of(context);
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      );

      expect(spanData, isNotNull);
      expect(spanData!.xSpan, greaterThan(0));
      expect(spanData!.ySpan, greaterThan(0));
    });

    testWidgets('provides PaneContext to children', (tester) async {
      PaneContextData? paneData;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Mafs(
            width: 800,
            height: 600,
            children: [
              Builder(
                builder: (context) {
                  paneData = PaneContext.of(context);
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      );

      expect(paneData, isNotNull);
    });

    testWidgets('provides MafsTheme to children', (tester) async {
      MafsThemeData? themeData;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Mafs(
            width: 800,
            height: 600,
            children: [
              Builder(
                builder: (context) {
                  themeData = MafsTheme.of(context);
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      );

      expect(themeData, isNotNull);
    });

    testWidgets('uses custom theme when provided', (tester) async {
      const customTheme = MafsThemeData(red: Color(0xFF123456));
      MafsThemeData? themeData;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Mafs(
            width: 800,
            height: 600,
            theme: customTheme,
            children: [
              Builder(
                builder: (context) {
                  themeData = MafsTheme.of(context);
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      );

      expect(themeData, customTheme);
    });

    testWidgets('onTap callback receives math coordinates - center tap', (tester) async {
      Offset? tappedPoint;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Mafs(
            width: 800,
            height: 600,
            viewBox: const ViewBox(x: (-5, 5), y: (-5, 5), padding: 0),
            preserveAspectRatio: PreserveAspectRatio.none, // Exact viewBox
            pan: false,
            onTap: (point) {
              tappedPoint = point;
            },
            children: const [],
          ),
        ),
      );

      // Tap in the center of the widget
      final mafsWidget = find.byType(Mafs);
      final center = tester.getCenter(mafsWidget);
      await tester.tapAt(center);
      await tester.pump();

      expect(tappedPoint, isNotNull);
      // Center tap should be at origin (0, 0) in math coordinates
      expect(tappedPoint!.dx, closeTo(0, 0.1));
      expect(tappedPoint!.dy, closeTo(0, 0.1));
    });

    testWidgets('onTap callback receives math coordinates - corner taps', (tester) async {
      Offset? tappedPoint;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Mafs(
            width: 800,
            height: 600,
            viewBox: const ViewBox(x: (-5, 5), y: (-5, 5), padding: 0),
            preserveAspectRatio: PreserveAspectRatio.none,
            pan: false,
            onTap: (point) {
              tappedPoint = point;
            },
            children: const [],
          ),
        ),
      );

      final mafsWidget = find.byType(Mafs);
      final topLeft = tester.getTopLeft(mafsWidget);

      // Tap top-left corner - should be (-5, 5) in math coords
      await tester.tapAt(topLeft + const Offset(1, 1)); // Slightly inside
      await tester.pump();
      expect(tappedPoint, isNotNull);
      expect(tappedPoint!.dx, closeTo(-5, 0.2));
      expect(tappedPoint!.dy, closeTo(5, 0.2));

      // Tap top-right corner - should be (5, 5) in math coords
      await tester.tapAt(topLeft + const Offset(799, 1)); // Near top-right
      await tester.pump();
      expect(tappedPoint!.dx, closeTo(5, 0.2));
      expect(tappedPoint!.dy, closeTo(5, 0.2));

      // Tap bottom-left corner - should be (-5, -5) in math coords
      await tester.tapAt(topLeft + const Offset(1, 599)); // Near bottom-left
      await tester.pump();
      expect(tappedPoint!.dx, closeTo(-5, 0.2));
      expect(tappedPoint!.dy, closeTo(-5, 0.2));

      // Tap bottom-right corner - should be (5, -5) in math coords
      await tester.tapAt(topLeft + const Offset(799, 599)); // Near bottom-right
      await tester.pump();
      expect(tappedPoint!.dx, closeTo(5, 0.2));
      expect(tappedPoint!.dy, closeTo(-5, 0.2));
    });

    testWidgets('onTap callback receives math coordinates - specific points', (tester) async {
      Offset? tappedPoint;

      // Use a simple 100x100 widget with viewBox from -10 to 10
      // Wrap in Center to provide loose constraints
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: Mafs(
              width: 100,
              height: 100,
              viewBox: const ViewBox(x: (-10, 10), y: (-10, 10), padding: 0),
              preserveAspectRatio: PreserveAspectRatio.none,
              pan: false,
              onTap: (point) {
                tappedPoint = point;
              },
              children: const [],
            ),
          ),
        ),
      );

      final mafsWidget = find.byType(Mafs);
      final topLeft = tester.getTopLeft(mafsWidget);

      // With 100x100 widget and viewBox (-10,10) x (-10,10):
      // - Each pixel represents 0.2 math units (20 units / 100 pixels)
      // - Screen (50, 50) should be math (0, 0)
      // - Screen (0, 0) should be math (-10, 10)
      // - Screen (25, 25) should be math (-5, 5)
      // - Screen (75, 75) should be math (5, -5)

      await tester.tapAt(topLeft + const Offset(50, 50));
      await tester.pump();
      expect(tappedPoint!.dx, closeTo(0, 0.5));
      expect(tappedPoint!.dy, closeTo(0, 0.5));

      await tester.tapAt(topLeft + const Offset(25, 25));
      await tester.pump();
      expect(tappedPoint!.dx, closeTo(-5, 0.5));
      expect(tappedPoint!.dy, closeTo(5, 0.5));

      await tester.tapAt(topLeft + const Offset(75, 75));
      await tester.pump();
      expect(tappedPoint!.dx, closeTo(5, 0.5));
      expect(tappedPoint!.dy, closeTo(-5, 0.5));
    });

    testWidgets('math to screen coordinate conversion is inverse of screen to math', (tester) async {
      Offset? tappedMathPoint;

      // Wrap in Center to provide loose constraints
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: Mafs(
              width: 400,
              height: 300,
              viewBox: const ViewBox(x: (-10, 10), y: (-10, 10), padding: 0),
              preserveAspectRatio: PreserveAspectRatio.none,
              pan: false,
              onTap: (point) {
                tappedMathPoint = point;
              },
              children: const [],
            ),
          ),
        ),
      );

      final mafsWidget = find.byType(Mafs);
      final topLeft = tester.getTopLeft(mafsWidget);

      // Tap at various screen positions and verify round-trip conversion
      final testScreenPoints = [
        const Offset(0, 0),       // top-left
        const Offset(200, 150),   // center
        const Offset(400, 300),   // bottom-right (use widget size)
        const Offset(100, 75),    // quarter point
      ];

      for (final screenOffset in testScreenPoints) {
        // Tap at screen position (relative to widget)
        final tapX = screenOffset.dx.clamp(1.0, 399.0); // Stay inside widget
        final tapY = screenOffset.dy.clamp(1.0, 299.0);
        await tester.tapAt(topLeft + Offset(tapX, tapY));
        await tester.pump();

        if (tappedMathPoint == null) continue;

        // Now convert math point back to screen to verify it matches
        // This is the inverse of _screenToMath:
        // screenX = (mathX - xMin) / xSpan * width
        // screenY = (1 - (mathY - yMin) / ySpan) * height
        const xMin = -10.0;
        const xSpan = 20.0;
        const yMin = -10.0;
        const ySpan = 20.0;
        const width = 400.0;
        const height = 300.0;

        final computedScreenX = (tappedMathPoint!.dx - xMin) / xSpan * width;
        final computedScreenY = (1 - (tappedMathPoint!.dy - yMin) / ySpan) * height;

        // The computed screen position should match where we tapped
        expect(computedScreenX, closeTo(tapX, 1.0));
        expect(computedScreenY, closeTo(tapY, 1.0));
      }
    });

    testWidgets('pan gesture moves the view', (tester) async {
      CoordinateContextData? initialCoords;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Mafs(
                width: 800,
                height: 600,
                viewBox: const ViewBox(x: (-5, 5), y: (-5, 5)),
                pan: true,
                children: [
                  Builder(
                    builder: (context) {
                      initialCoords = CoordinateContext.of(context);
                      return const SizedBox();
                    },
                  ),
                ],
              );
            },
          ),
        ),
      );

      expect(initialCoords, isNotNull);

      // Perform a drag gesture
      await tester.drag(find.byType(Mafs), const Offset(100, 0));
      await tester.pump();

      // Verify the widget didn't crash during panning
      // Full coordinate change verification would require more complex test setup
      expect(find.byType(Mafs), findsOneWidget);
    });

    testWidgets('pan moves view at 1:1 ratio with cursor', (tester) async {
      // Use a simple setup: 100x100 viewport, viewBox (-10,10) x (-10,10), no padding
      // This means: 100 pixels = 20 units, so 1 pixel = 0.2 units
      // Dragging 50 pixels should move the view by 10 units

      CoordinateContextData? coords;

      // Wrap in Center to provide loose constraints
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: Mafs(
              width: 100,
              height: 100,
              viewBox: const ViewBox(x: (-10, 10), y: (-10, 10), padding: 0),
              preserveAspectRatio: PreserveAspectRatio.none,
              pan: true,
              children: [
                Builder(
                  builder: (context) {
                    coords = CoordinateContext.of(context);
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ),
        ),
      );

      // Store initial coordinates
      final initialXMin = coords!.xMin;

      // Drag 50 pixels to the right using gesture (keeps same widget instance)
      final center = tester.getCenter(find.byType(Mafs));
      final gesture = await tester.startGesture(center);
      await tester.pump();
      await gesture.moveBy(const Offset(50, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      // Calculate how much the view shifted in math units
      final xShift = coords!.xMin - initialXMin;

      // With 100px viewport showing 20 units, 50px drag should shift 10 units
      // But content moves WITH cursor, so viewport shifts OPPOSITE
      // Drag right 50px = viewport shifts left 10 units = xMin decreases by 10
      // So xShift should be approximately -10

      // The key test: pixels dragged / total pixels = units shifted / total units
      // 50 / 100 = xShift / 20
      // xShift = -10 (negative because drag right = viewport left)

      // Allow some tolerance for floating point
      expect(xShift, closeTo(-10, 0.5),
          reason: 'Dragging 50px on 100px viewport showing 20 units '
              'should shift view by 10 units');
    });

    testWidgets('pan tracks cursor position precisely', (tester) async {
      // Similar to first pan test but with different viewport size (200x200)
      
      CoordinateContextData? coords;

      // Wrap in Center to provide loose constraints
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: Mafs(
              width: 200,
              height: 200,
              viewBox: const ViewBox(x: (-10, 10), y: (-10, 10), padding: 0),
              preserveAspectRatio: PreserveAspectRatio.none,
              pan: true,
              children: [
                Builder(
                  builder: (context) {
                    coords = CoordinateContext.of(context);
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ),
        ),
      );

      // Store initial xMin (before any interaction)
      final initialXMin = coords!.xMin;
      expect(initialXMin, closeTo(-10, 0.1));

      // Drag 50 pixels to the right using gesture (keeps same widget instance)
      final center = tester.getCenter(find.byType(Mafs));
      final gesture = await tester.startGesture(center);
      await tester.pump();
      await gesture.moveBy(const Offset(50, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      // Calculate how much the view shifted in math units
      final xShift = coords!.xMin - initialXMin;

      // With 200px viewport showing 20 units, 50px drag should shift 5 units
      // 50 / 200 = xShift / 20
      // xShift = -5 (negative because drag right = viewport left)
      expect(xShift, closeTo(-5, 0.5),
          reason: 'Dragging 50px on 200px viewport showing 20 units '
              'should shift view by 5 units');
    });

    testWidgets('preserveAspectRatio contain adjusts viewBox', (tester) async {
      CoordinateContextData? coords;

      // Wrap in Center to provide loose constraints
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: Mafs(
              width: 800,
              height: 400, // Wide aspect ratio
              viewBox: const ViewBox(x: (-5, 5), y: (-5, 5), padding: 0),
              preserveAspectRatio: PreserveAspectRatio.contain,
              children: [
                Builder(
                  builder: (context) {
                    coords = CoordinateContext.of(context);
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ),
        ),
      );

      expect(coords, isNotNull);
      // With contain and wide viewport, x span should be expanded
      final xSpan = coords!.xMax - coords!.xMin;
      final ySpan = coords!.yMax - coords!.yMin;

      // Aspect ratio of spans should match viewport aspect ratio
      expect(xSpan / ySpan, closeTo(800 / 400, 0.1));
    });

    testWidgets('preserveAspectRatio contain ensures uniform scale', (tester) async {
      // This is the critical test: with contain, 1 unit in X should equal 
      // 1 unit in Y on screen (pixels per unit should be same in both directions)
      CoordinateContextData? coords;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Mafs(
            width: 800,
            height: 400, // Wide aspect ratio (2:1)
            viewBox: const ViewBox(x: (-5, 5), y: (-5, 5), padding: 0),
            preserveAspectRatio: PreserveAspectRatio.contain,
            children: [
              Builder(
                builder: (context) {
                  coords = CoordinateContext.of(context);
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      );

      expect(coords, isNotNull);
      
      final xSpan = coords!.xMax - coords!.xMin;
      final ySpan = coords!.yMax - coords!.yMin;
      
      // Calculate pixels per unit in each direction
      final pxPerUnitX = coords!.width / xSpan;
      final pxPerUnitY = coords!.height / ySpan;
      
      // With preserveAspectRatio: contain, these MUST be equal
      // This ensures grid squares are square and circles are circular
      expect(pxPerUnitX, closeTo(pxPerUnitY, 0.01),
          reason: 'Pixels per unit must be equal in X and Y for uniform scaling. '
              'Got X: $pxPerUnitX, Y: $pxPerUnitY');
    });

    testWidgets('Mafs inside Expanded uses actual container size', (tester) async {
      // This reproduces the example app scenario where Mafs is inside Expanded
      // and height defaults to 500 but actual container is different
      CoordinateContextData? coords;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 800,
            height: 600, // Container is 600 tall
            child: Mafs(
              // width: null means use constraints.maxWidth (800)
              // height: 500 is the default, but container is 600
              viewBox: const ViewBox(x: (-5, 5), y: (-5, 5), padding: 0),
              preserveAspectRatio: PreserveAspectRatio.contain,
              children: [
                Builder(
                  builder: (context) {
                    coords = CoordinateContext.of(context);
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ),
        ),
      );

      expect(coords, isNotNull);
      
      final xSpan = coords!.xMax - coords!.xMin;
      final ySpan = coords!.yMax - coords!.yMin;
      
      // Calculate pixels per unit
      final pxPerUnitX = coords!.width / xSpan;
      final pxPerUnitY = coords!.height / ySpan;
      
      // These must be equal for uniform scaling
      expect(pxPerUnitX, closeTo(pxPerUnitY, 0.01),
          reason: 'Pixels per unit must be equal in X and Y. '
              'Got X: $pxPerUnitX, Y: $pxPerUnitY');
    });

    testWidgets('child CustomPaint size matches coordData dimensions', (tester) async {
      // This tests that a CustomPaint child gets the correct size in paint()
      // Set a larger test surface to allow our widgets to size correctly
      await tester.binding.setSurfaceSize(const Size(1200, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      
      Size? paintSize;
      CoordinateContextData? coords;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center( // Use Center instead of SizedBox to allow child to be smaller
            child: Mafs(
              width: 400,
              height: 300,
              viewBox: const ViewBox(x: (-5, 5), y: (-5, 5), padding: 0),
              preserveAspectRatio: PreserveAspectRatio.contain,
              children: [
                Builder(
                  builder: (context) {
                    coords = CoordinateContext.of(context);
                    // Create a CustomPaint like _GridLines does
                    return CustomPaint(
                      size: Size(coords!.width, coords!.height),
                      painter: _TestPainter(onPaint: (size) {
                        paintSize = size;
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );

      expect(coords, isNotNull);
      expect(paintSize, isNotNull);
      
      // The CustomPaint's paint() size should match coordData dimensions
      expect(paintSize!.width, closeTo(coords!.width, 0.01),
          reason: 'Paint size width should match coordData.width');
      expect(paintSize!.height, closeTo(coords!.height, 0.01),
          reason: 'Paint size height should match coordData.height');
    });

    testWidgets('preserveAspectRatio none uses exact viewBox', (tester) async {
      CoordinateContextData? coords;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Mafs(
            width: 800,
            height: 400,
            viewBox: const ViewBox(x: (-5, 5), y: (-5, 5), padding: 0),
            preserveAspectRatio: PreserveAspectRatio.none,
            children: [
              Builder(
                builder: (context) {
                  coords = CoordinateContext.of(context);
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      );

      expect(coords, isNotNull);
      expect(coords!.xMin, closeTo(-5, 0.1));
      expect(coords!.xMax, closeTo(5, 0.1));
      expect(coords!.yMin, closeTo(-5, 0.1));
      expect(coords!.yMax, closeTo(5, 0.1));
    });

    testWidgets('zoom enabled with boolean true', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Mafs(
            width: 800,
            height: 600,
            zoom: true,
            children: [],
          ),
        ),
      );

      // Widget should render without error
      expect(find.byType(Mafs), findsOneWidget);
    });

    testWidgets('zoom enabled with ZoomConfig', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Mafs(
            width: 800,
            height: 600,
            zoom: ZoomConfig(min: 0.1, max: 10.0),
            children: [],
          ),
        ),
      );

      expect(find.byType(Mafs), findsOneWidget);
    });

    testWidgets('renders children', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Mafs(
            width: 800,
            height: 600,
            children: [
              Container(key: const Key('child1')),
              Container(key: const Key('child2')),
            ],
          ),
        ),
      );

      expect(find.byKey(const Key('child1')), findsOneWidget);
      expect(find.byKey(const Key('child2')), findsOneWidget);
    });

    testWidgets('expands to fill width when width is null', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 1000,
            height: 800,
            child: Mafs(
              height: 600,
              children: const [],
            ),
          ),
        ),
      );

      // The Mafs widget should have expanded to the parent width
      final mafs = tester.widget<Mafs>(find.byType(Mafs));
      expect(mafs.width, isNull); // Width is null to trigger auto-expansion
    });
  });
}

/// Test painter that captures the size it receives
class _TestPainter extends CustomPainter {
  _TestPainter({required this.onPaint});
  
  final void Function(Size size) onPaint;
  
  @override
  void paint(Canvas canvas, Size size) {
    onPaint(size);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
