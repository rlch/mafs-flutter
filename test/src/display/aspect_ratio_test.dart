import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafs_flutter/src/context/coordinate_context.dart';
import 'package:mafs_flutter/src/display/ellipse.dart';
import 'package:mafs_flutter/src/view/mafs.dart';

void main() {
  group('Aspect ratio consistency', () {
    testWidgets('RenderMafsEllipse size matches coordData dimensions', (tester) async {
      // Set a larger test surface
      await tester.binding.setSurfaceSize(const Size(1200, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      
      CoordinateContextData? coords;
      Size? renderObjectSize;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: Mafs(
              width: 400,
              height: 300,
              viewBox: const ViewBox(x: (-5, 5), y: (-5, 5), padding: 0),
              preserveAspectRatio: PreserveAspectRatio.contain,
              children: [
                Builder(
                  builder: (context) {
                    coords = CoordinateContext.of(context);
                    return const MafsEllipse(
                      center: Offset(0, 0),
                      radius: Offset(1, 1), // Circle
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );

      // Get the render object size
      final renderObject = tester.renderObject<RenderMafsEllipse>(
        find.byType(MafsEllipse),
      );
      renderObjectSize = renderObject.size;

      expect(coords, isNotNull);
      expect(renderObjectSize, isNotNull);
      
      final c = coords!;
      final s = renderObjectSize;
      
      // The key test: RenderObject size must match coordData dimensions
      // If they don't match, the aspect ratio will be wrong
      expect(s.width, closeTo(c.width, 0.01),
          reason: 'RenderObject width (${s.width}) should match coordData.width (${c.width})');
      expect(s.height, closeTo(c.height, 0.01),
          reason: 'RenderObject height (${s.height}) should match coordData.height (${c.height})');
    });

    testWidgets('Circle remains circular with preserveAspectRatio contain', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      
      CoordinateContextData? coords;
      Size? renderObjectSize;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: Mafs(
              width: 800,
              height: 400, // Wide aspect ratio (2:1)
              viewBox: const ViewBox(x: (-5, 5), y: (-5, 5), padding: 0),
              preserveAspectRatio: PreserveAspectRatio.contain,
              children: [
                Builder(
                  builder: (context) {
                    coords = CoordinateContext.of(context);
                    return const MafsEllipse(
                      center: Offset(0, 0),
                      radius: Offset(1, 1), // Circle - both radii are 1
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderMafsEllipse>(
        find.byType(MafsEllipse),
      );
      renderObjectSize = renderObject.size;

      expect(coords, isNotNull);
      expect(renderObjectSize, isNotNull);
      
      final c = coords!;
      final s = renderObjectSize;
      
      // Calculate what the pixel radii would be
      final xSpan = c.xMax - c.xMin;
      final ySpan = c.yMax - c.yMin;
      
      // For a circle with math radius 1, calculate pixel radii
      final pixelRadiusX = 1.0 / xSpan * s.width;
      final pixelRadiusY = 1.0 / ySpan * s.height;
      
      // For a circle to render as circular, pixel radii must be equal
      expect(pixelRadiusX, closeTo(pixelRadiusY, 0.1),
          reason: 'Circle pixel radius X ($pixelRadiusX) should equal Y ($pixelRadiusY) for circle to appear circular');
    });
    
    testWidgets('Mafs inside Expanded - circle should stay circular', (tester) async {
      // This tests the example app scenario
      await tester.binding.setSurfaceSize(const Size(800, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      
      CoordinateContextData? coords;
      Size? renderObjectSize;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              const SizedBox(height: 100), // Simulates header
              Expanded(
                child: Mafs(
                  // width: null means use constraints.maxWidth
                  // height: 500 is default - but Expanded gives more space
                  viewBox: const ViewBox(x: (-5, 5), y: (-5, 5)),
                  preserveAspectRatio: PreserveAspectRatio.contain,
                  children: [
                    Builder(
                      builder: (context) {
                        coords = CoordinateContext.of(context);
                        return const MafsEllipse(
                          center: Offset(0, 0),
                          radius: Offset(1, 1),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100), // Simulates footer
            ],
          ),
        ),
      );
      
      final renderObject = tester.renderObject<RenderMafsEllipse>(
        find.byType(MafsEllipse),
      );
      renderObjectSize = renderObject.size;

      expect(coords, isNotNull);
      expect(renderObjectSize, isNotNull);
      
      final c = coords!;
      final s = renderObjectSize;
      
      final xSpan = c.xMax - c.xMin;
      final ySpan = c.yMax - c.yMin;
      
      final pixelRadiusX = 1.0 / xSpan * s.width;
      final pixelRadiusY = 1.0 / ySpan * s.height;
      
      // Pixel radii must be equal for circle to appear circular
      expect(pixelRadiusX, closeTo(pixelRadiusY, 0.1),
          reason: 'Circle pixel radius X ($pixelRadiusX) should equal Y ($pixelRadiusY)');
    });
  });
}
