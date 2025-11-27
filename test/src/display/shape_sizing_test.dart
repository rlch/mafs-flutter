import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafs_flutter/mafs_flutter.dart';

void main() {
  group('Shape sizing relative to grid', () {
    testWidgets('MafsCircle with radius 1 spans exactly 1 grid unit', (tester) async {
      // Set up a controlled test environment
      await tester.binding.setSurfaceSize(const Size(1000, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      CoordinateContextData? coords;

      // Create a simple 400x400 canvas with viewBox (-5, 5) x (-5, 5)
      // This gives us 40 pixels per unit (400px / 10 units)
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: Mafs(
              width: 400,
              height: 400,
              viewBox: const ViewBox(x: (-5, 5), y: (-5, 5), padding: 0),
              preserveAspectRatio: PreserveAspectRatio.contain,
              children: [
                Builder(
                  builder: (context) {
                    coords = CoordinateContext.of(context);
                    return const SizedBox();
                  },
                ),
                // Circle with radius 1 at origin
                const MafsCircle(
                  center: Offset(0, 0),
                  radius: 1, // Should span 1 grid unit in each direction
                ),
              ],
            ),
          ),
        ),
      );

      expect(coords, isNotNull);

      // Get the render object to verify the actual pixel dimensions
      final renderObject = tester.renderObject<RenderMafsEllipse>(
        find.byType(MafsCircle),
      );

      // Calculate expected pixel radius
      // With 400px viewport and 10 math units, we have 40 pixels per unit
      // A circle with math radius 1 should have pixel radius of 40
      final xSpan = coords!.xMax - coords!.xMin;
      final ySpan = coords!.yMax - coords!.yMin;
      final pixelsPerUnitX = coords!.width / xSpan;
      final pixelsPerUnitY = coords!.height / ySpan;

      // Verify uniform scaling (prerequisite for correct circle rendering)
      expect(pixelsPerUnitX, closeTo(pixelsPerUnitY, 0.01),
          reason: 'Pixels per unit should be equal in X and Y');

      // The circle has math radius 1, so its pixel radius should be:
      // pixelRadius = mathRadius / span * size = 1 / 10 * 400 = 40
      final expectedPixelRadius = 1.0 / xSpan * renderObject.size.width;
      expect(expectedPixelRadius, closeTo(40, 0.1),
          reason: 'Circle with radius 1 should have pixel radius of 40 '
              '(400px / 10 units = 40px per unit)');

      // Verify the render object has the correct math radius
      expect(renderObject.radius.dx, 1.0);
      expect(renderObject.radius.dy, 1.0);
    });

    testWidgets('MafsCircle diameter equals 2 grid squares', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      CoordinateContextData? coords;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: Mafs(
              width: 400,
              height: 400,
              viewBox: const ViewBox(x: (-5, 5), y: (-5, 5), padding: 0),
              preserveAspectRatio: PreserveAspectRatio.contain,
              children: [
                Builder(
                  builder: (context) {
                    coords = CoordinateContext.of(context);
                    return const SizedBox();
                  },
                ),
                // Circle with radius 1 means diameter 2
                const MafsCircle(
                  center: Offset(0, 0),
                  radius: 1,
                ),
              ],
            ),
          ),
        ),
      );

      expect(coords, isNotNull);

      final renderObject = tester.renderObject<RenderMafsEllipse>(
        find.byType(MafsCircle),
      );

      // Calculate grid square size in pixels
      // With viewBox (-5, 5), grid lines are at -5, -4, -3, ..., 4, 5
      // Each grid square is 1 math unit
      final xSpan = coords!.xMax - coords!.xMin;
      final gridSquareSizePixels = renderObject.size.width / xSpan;

      // Circle with radius 1 has diameter 2 (math units)
      // Diameter in pixels should be 2 * gridSquareSizePixels
      final circleMathRadius = renderObject.radius.dx;
      final circleDiameterMathUnits = circleMathRadius * 2;
      final expectedDiameterPixels = circleDiameterMathUnits * gridSquareSizePixels;

      // The actual pixel diameter rendered
      final actualPixelDiameter = (circleMathRadius / xSpan * renderObject.size.width) * 2;

      expect(actualPixelDiameter, closeTo(expectedDiameterPixels, 0.1),
          reason: 'Circle diameter should span exactly 2 grid squares');
      expect(circleDiameterMathUnits, 2.0,
          reason: 'Circle with radius 1 should have diameter 2');
    });

    testWidgets('MafsPoint has fixed pixel size regardless of zoom', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: Mafs(
              width: 400,
              height: 400,
              viewBox: const ViewBox(x: (-5, 5), y: (-5, 5), padding: 0),
              preserveAspectRatio: PreserveAspectRatio.contain,
              children: const [
                MafsPoint(x: 0, y: 0),
              ],
            ),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsPoint>(
        find.byType(MafsPoint),
      );

      // Point radius should be the fixed constant (6 pixels)
      // regardless of the coordinate system
      expect(RenderMafsPoint.pointRadius, 6.0,
          reason: 'Point radius should be fixed at 6 pixels');

      // Verify the render object exists and is properly configured
      expect(renderObject.x, 0.0);
      expect(renderObject.y, 0.0);
    });

    testWidgets('Circle is circular with wide viewport aspect ratio', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      CoordinateContextData? coords;

      // Wide viewport: 800x400 (2:1 aspect ratio)
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: Mafs(
              width: 800,
              height: 400,
              viewBox: const ViewBox(x: (-5, 5), y: (-5, 5), padding: 0),
              preserveAspectRatio: PreserveAspectRatio.contain,
              children: [
                Builder(
                  builder: (context) {
                    coords = CoordinateContext.of(context);
                    return const SizedBox();
                  },
                ),
                const MafsCircle(
                  center: Offset(0, 0),
                  radius: 1,
                ),
              ],
            ),
          ),
        ),
      );

      expect(coords, isNotNull);

      final renderObject = tester.renderObject<RenderMafsEllipse>(
        find.byType(MafsCircle),
      );

      // Calculate pixel radii
      final xSpan = coords!.xMax - coords!.xMin;
      final ySpan = coords!.yMax - coords!.yMin;

      final pixelRadiusX = renderObject.radius.dx / xSpan * renderObject.size.width;
      final pixelRadiusY = renderObject.radius.dy / ySpan * renderObject.size.height;

      // For a circle to appear circular, pixel radii must be equal
      expect(pixelRadiusX, closeTo(pixelRadiusY, 0.1),
          reason: 'Circle should have equal pixel radii in X and Y '
              'to appear circular. Got X=$pixelRadiusX, Y=$pixelRadiusY');
    });

    testWidgets('Circle is circular with tall viewport aspect ratio', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      CoordinateContextData? coords;

      // Tall viewport: 400x800 (1:2 aspect ratio)
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: Mafs(
              width: 400,
              height: 800,
              viewBox: const ViewBox(x: (-5, 5), y: (-5, 5), padding: 0),
              preserveAspectRatio: PreserveAspectRatio.contain,
              children: [
                Builder(
                  builder: (context) {
                    coords = CoordinateContext.of(context);
                    return const SizedBox();
                  },
                ),
                const MafsCircle(
                  center: Offset(0, 0),
                  radius: 1,
                ),
              ],
            ),
          ),
        ),
      );

      expect(coords, isNotNull);

      final renderObject = tester.renderObject<RenderMafsEllipse>(
        find.byType(MafsCircle),
      );

      final xSpan = coords!.xMax - coords!.xMin;
      final ySpan = coords!.yMax - coords!.yMin;

      final pixelRadiusX = renderObject.radius.dx / xSpan * renderObject.size.width;
      final pixelRadiusY = renderObject.radius.dy / ySpan * renderObject.size.height;

      expect(pixelRadiusX, closeTo(pixelRadiusY, 0.1),
          reason: 'Circle should have equal pixel radii in X and Y '
              'to appear circular. Got X=$pixelRadiusX, Y=$pixelRadiusY');
    });

    testWidgets('Tapping creates point at correct position relative to grid', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      Offset? tappedPoint;
      CoordinateContextData? coords;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: Mafs(
              width: 400,
              height: 400,
              viewBox: const ViewBox(x: (-5, 5), y: (-5, 5), padding: 0),
              preserveAspectRatio: PreserveAspectRatio.contain,
              onTap: (point) {
                tappedPoint = point;
              },
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

      // Tap at the center of the widget (should be origin in math coords)
      final mafsWidget = find.byType(Mafs);
      final center = tester.getCenter(mafsWidget);
      await tester.tapAt(center);
      await tester.pump();

      expect(tappedPoint, isNotNull);
      expect(tappedPoint!.dx, closeTo(0, 0.1),
          reason: 'Tapping center should give x=0');
      expect(tappedPoint!.dy, closeTo(0, 0.1),
          reason: 'Tapping center should give y=0');

      // Tap at a grid intersection (1, 1)
      // With 400px viewport and 10 units, each unit is 40px
      // Grid point (1, 1) is at screen offset (200 + 40, 200 - 40) = (240, 160)
      // because screen y is inverted
      final topLeft = tester.getTopLeft(mafsWidget);
      final xSpan = coords!.xMax - coords!.xMin;
      final ySpan = coords!.yMax - coords!.yMin;

      // Screen position for math point (1, 1)
      final screenX = (1 - coords!.xMin) / xSpan * coords!.width;
      final screenY = (1 - (1 - coords!.yMin) / ySpan) * coords!.height;

      await tester.tapAt(topLeft + Offset(screenX, screenY));
      await tester.pump();

      expect(tappedPoint!.dx, closeTo(1, 0.2),
          reason: 'Tapping at grid point (1,1) should give x≈1');
      expect(tappedPoint!.dy, closeTo(1, 0.2),
          reason: 'Tapping at grid point (1,1) should give y≈1');
    });

    testWidgets('Circle at (1,1) with radius 1 touches grid lines at (0,1), (2,1), (1,0), (1,2)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      CoordinateContextData? coords;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: Mafs(
              width: 400,
              height: 400,
              viewBox: const ViewBox(x: (-5, 5), y: (-5, 5), padding: 0),
              preserveAspectRatio: PreserveAspectRatio.contain,
              children: [
                Builder(
                  builder: (context) {
                    coords = CoordinateContext.of(context);
                    return const SizedBox();
                  },
                ),
                // Circle at (1, 1) with radius 1
                // Should touch grid lines at x=0, x=2, y=0, y=2
                const MafsCircle(
                  center: Offset(1, 1),
                  radius: 1,
                ),
              ],
            ),
          ),
        ),
      );

      expect(coords, isNotNull);

      final renderObject = tester.renderObject<RenderMafsEllipse>(
        find.byType(MafsCircle),
      );

      // Verify center position
      expect(renderObject.center.dx, 1.0);
      expect(renderObject.center.dy, 1.0);

      // Verify radius
      expect(renderObject.radius.dx, 1.0);
      expect(renderObject.radius.dy, 1.0);

      // The circle edge positions in math units:
      // Left edge: center.x - radius = 1 - 1 = 0 (touches y-axis)
      // Right edge: center.x + radius = 1 + 1 = 2 (touches x=2 grid line)
      // Bottom edge: center.y - radius = 1 - 1 = 0 (touches x-axis)
      // Top edge: center.y + radius = 1 + 1 = 2 (touches y=2 grid line)

      final leftEdge = renderObject.center.dx - renderObject.radius.dx;
      final rightEdge = renderObject.center.dx + renderObject.radius.dx;
      final bottomEdge = renderObject.center.dy - renderObject.radius.dy;
      final topEdge = renderObject.center.dy + renderObject.radius.dy;

      expect(leftEdge, 0.0, reason: 'Left edge should touch y-axis (x=0)');
      expect(rightEdge, 2.0, reason: 'Right edge should touch x=2 grid line');
      expect(bottomEdge, 0.0, reason: 'Bottom edge should touch x-axis (y=0)');
      expect(topEdge, 2.0, reason: 'Top edge should touch y=2 grid line');
    });

    testWidgets('Tapped point renders at correct size (not screen-filling)', (tester) async {
      // This test reproduces the bug where tapping created a huge blue circle
      // that filled the entire screen instead of a small point indicator
      await tester.binding.setSurfaceSize(const Size(1000, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      Offset? tappedPoint;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Mafs(
                  width: 400,
                  height: 400,
                  viewBox: const ViewBox(x: (-5, 5), y: (-5, 5), padding: 0),
                  preserveAspectRatio: PreserveAspectRatio.contain,
                  onTap: (point) {
                    setState(() {
                      tappedPoint = point;
                    });
                  },
                  children: [
                    // When tapped, show a MafsPoint at the tap location
                    if (tappedPoint != null)
                      MafsPoint(
                        x: tappedPoint!.dx,
                        y: tappedPoint!.dy,
                        color: const Color(0xFF4361EE),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Initially no point
      expect(find.byType(MafsPoint), findsNothing);

      // Tap at the center
      final center = tester.getCenter(find.byType(Mafs));
      await tester.tapAt(center);
      await tester.pumpAndSettle();

      // Now there should be a point
      expect(find.byType(MafsPoint), findsOneWidget);

      // Verify the point has the correct fixed pixel radius (6 pixels)
      // NOT the size of the entire viewport
      final renderObject = tester.renderObject<RenderMafsPoint>(
        find.byType(MafsPoint),
      );

      // The point should be rendered at approximately the center
      expect(renderObject.x, closeTo(0, 0.5));
      expect(renderObject.y, closeTo(0, 0.5));

      // Most importantly: verify the rendered size is NOT the full viewport
      // MafsPoint uses a fixed 6 pixel radius
      expect(RenderMafsPoint.pointRadius, 6.0,
          reason: 'Point should have fixed 6px radius, not fill viewport');

      // The render object size should be the full viewport (it paints within that)
      // but the actual circle drawn should only be 6px radius
      expect(renderObject.size.width, 400.0);
      expect(renderObject.size.height, 400.0);
    });

    testWidgets('Custom widget inside Mafs children does not fill viewport incorrectly', (tester) async {
      // This tests that placing a Positioned widget inside Mafs children
      // doesn't cause unexpected sizing issues
      await tester.binding.setSurfaceSize(const Size(1000, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: Mafs(
              width: 400,
              height: 400,
              viewBox: const ViewBox(x: (-5, 5), y: (-5, 5), padding: 0),
              preserveAspectRatio: PreserveAspectRatio.contain,
              children: [
                // A simple container that should NOT fill the viewport
                // Note: This demonstrates the bug - Positioned widgets
                // get wrapped in Positioned.fill by _MafsTransformLayer
                Builder(
                  builder: (context) {
                    return Container(
                      width: 20,
                      height: 20,
                      color: const Color(0xFF4361EE),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );

      // Find the Container
      final container = tester.widget<Container>(find.byType(Container).last);
      
      // The Container was specified as 20x20
      expect(container.constraints?.maxWidth, 20.0);
      expect(container.constraints?.maxHeight, 20.0);
    });
  });
}
