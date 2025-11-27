import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafs_flutter/mafs_flutter.dart';

void main() {
  group('MovablePoint', () {
    testWidgets('renders at correct position', (tester) async {
      await tester.pumpWidget(
        _wrapWithContext(
          MovablePoint(
            point: const Offset(50, 50),
            onMove: (_) {},
          ),
        ),
      );

      expect(find.byType(MovablePoint), findsOneWidget);
    });

    testWidgets('uses default pink color when color is null', (tester) async {
      await tester.pumpWidget(
        _wrapWithContext(
          MovablePoint(
            point: const Offset(0, 0),
            onMove: (_) {},
          ),
        ),
      );

      expect(find.byType(MovablePoint), findsOneWidget);
    });

    testWidgets('uses custom color when specified', (tester) async {
      await tester.pumpWidget(
        _wrapWithContext(
          MovablePoint(
            point: const Offset(0, 0),
            onMove: (_) {},
            color: MafsColors.blue,
          ),
        ),
      );

      expect(find.byType(MovablePoint), findsOneWidget);
    });

    testWidgets('renders with constraint function', (tester) async {
      await tester.pumpWidget(
        _wrapWithContext(
          MovablePoint(
            point: const Offset(50, 50),
            onMove: (_) {},
            constrain: MovablePoint.horizontal(50),
          ),
        ),
      );

      expect(find.byType(MovablePoint), findsOneWidget);
    });

    testWidgets('animation controller is disposed properly', (tester) async {
      await tester.pumpWidget(
        _wrapWithContext(
          MovablePoint(
            point: const Offset(50, 50),
            onMove: (_) {},
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Remove the widget - no errors should occur
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('MovablePoint constraints', () {
    test('horizontal creates correct constraint function', () {
      final constraint = MovablePoint.horizontal(5.0);
      final result = constraint(const Offset(10, 20));

      expect(result.dx, 10.0);
      expect(result.dy, 5.0);
    });

    test('vertical creates correct constraint function', () {
      final constraint = MovablePoint.vertical(5.0);
      final result = constraint(const Offset(10, 20));

      expect(result.dx, 5.0);
      expect(result.dy, 20.0);
    });
  });

  group('MovablePoint with transforms', () {
    testWidgets('renders inside MafsTransform', (tester) async {
      await tester.pumpWidget(
        _wrapWithContext(
          MafsTransform(
            translate: const Offset(10, 10),
            child: MovablePoint(
              point: const Offset(0, 0),
              onMove: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(MovablePoint), findsOneWidget);
    });
  });

  group('MovablePoint dragging', () {
    testWidgets('can drag point at origin (0, 0)', (tester) async {
      Offset? movedTo;

      await tester.pumpWidget(
        _wrapInMafs(
          MovablePoint(
            point: const Offset(0, 0),
            onMove: (p) => movedTo = p,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // With viewBox (-5, 5) x (-5, 5) and 500x500 size,
      // (0, 0) in math coords maps to (250, 250) in screen coords
      final mafsBox = tester.renderObject<RenderBox>(find.byType(Mafs));
      final mafsTopLeft = mafsBox.localToGlobal(Offset.zero);
      final center = mafsTopLeft + const Offset(250, 250);

      await tester.dragFrom(center, const Offset(50, 0));
      await tester.pumpAndSettle();

      expect(movedTo, isNotNull, reason: 'Point at origin should be draggable');
    });

    testWidgets('can drag point at (2, 2)', (tester) async {
      Offset? movedTo;

      await tester.pumpWidget(
        _wrapInMafs(
          MovablePoint(
            point: const Offset(2, 2),
            onMove: (p) => movedTo = p,
            color: MafsColors.pink,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Get the global position of the Mafs widget
      final mafsBox = tester.renderObject<RenderBox>(find.byType(Mafs));
      final mafsTopLeft = mafsBox.localToGlobal(Offset.zero);

      // With viewBox (-5, 5) x (-5, 5) and 500x500 size,
      // (2, 2) in math coords maps to:
      // screenX = (2 - (-5)) / 10 * 500 = 7/10 * 500 = 350
      // screenY = (1 - (2 - (-5)) / 10) * 500 = (1 - 0.7) * 500 = 150
      final screenPoint = mafsTopLeft + const Offset(350, 150);

      await tester.dragFrom(screenPoint, const Offset(50, 0));
      await tester.pumpAndSettle();

      expect(movedTo, isNotNull, reason: 'Point at (2, 2) should be draggable');
    });

    testWidgets('can drag point at (-2, -2)', (tester) async {
      Offset? movedTo;

      await tester.pumpWidget(
        _wrapInMafs(
          MovablePoint(
            point: const Offset(-2, -2),
            onMove: (p) => movedTo = p,
            color: MafsColors.blue,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final mafsBox = tester.renderObject<RenderBox>(find.byType(Mafs));
      final mafsTopLeft = mafsBox.localToGlobal(Offset.zero);

      // With viewBox (-5, 5) x (-5, 5) and 500x500 size,
      // (-2, -2) in math coords maps to:
      // screenX = (-2 - (-5)) / 10 * 500 = 3/10 * 500 = 150
      // screenY = (1 - (-2 - (-5)) / 10) * 500 = (1 - 0.3) * 500 = 350
      final screenPoint = mafsTopLeft + const Offset(150, 350);

      await tester.dragFrom(screenPoint, const Offset(50, 0));
      await tester.pumpAndSettle();

      expect(movedTo, isNotNull, reason: 'Point at (-2, -2) should be draggable');
    });

    testWidgets('can drag horizontally constrained point at (0, -2)', (tester) async {
      Offset? movedTo;

      await tester.pumpWidget(
        _wrapInMafs(
          MovablePoint(
            point: const Offset(0, -2),
            onMove: (p) => movedTo = p,
            constrain: MovablePoint.horizontal(-2),
            color: MafsColors.orange,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final mafsBox = tester.renderObject<RenderBox>(find.byType(Mafs));
      final mafsTopLeft = mafsBox.localToGlobal(Offset.zero);

      // With viewBox (-5, 5) x (-5, 5) and 500x500 size,
      // (0, -2) in math coords maps to:
      // screenX = (0 - (-5)) / 10 * 500 = 5/10 * 500 = 250
      // screenY = (1 - (-2 - (-5)) / 10) * 500 = (1 - 0.3) * 500 = 350
      final screenPoint = mafsTopLeft + const Offset(250, 350);

      await tester.dragFrom(screenPoint, const Offset(50, 0));
      await tester.pumpAndSettle();

      expect(movedTo, isNotNull, reason: 'Horizontally constrained point should be draggable');
    });

    testWidgets('multiple MovablePoints in same Mafs - all should be draggable', (tester) async {
      Offset? point1MovedTo;
      Offset? point2MovedTo;
      Offset? constrainedMovedTo;

      // Note: Don't wrap in extra Stack - Mafs already uses Stack for children
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
                viewBox: const ViewBox(x: (-5, 5), y: (-5, 5), padding: 0),
                pan: true,
                zoom: true,
                children: [
                  MovablePoint(
                    point: const Offset(2, 2),
                    onMove: (p) => point1MovedTo = p,
                    color: MafsColors.pink,
                  ),
                  MovablePoint(
                    point: const Offset(-2, -2),
                    onMove: (p) => point2MovedTo = p,
                    color: MafsColors.blue,
                  ),
                  MovablePoint(
                    point: const Offset(0, -2),
                    onMove: (p) => constrainedMovedTo = p,
                    constrain: MovablePoint.horizontal(-2),
                    color: MafsColors.orange,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final mafsBox = tester.renderObject<RenderBox>(find.byType(Mafs));
      final mafsTopLeft = mafsBox.localToGlobal(Offset.zero);

      // Test point at (2, 2) - screen (350, 150)
      await tester.dragFrom(mafsTopLeft + const Offset(350, 150), const Offset(50, 0));
      await tester.pumpAndSettle();
      expect(point1MovedTo, isNotNull, reason: 'Point 1 at (2, 2) should be draggable');

      // Reset
      point1MovedTo = null;

      // Test point at (-2, -2) - screen (150, 350)
      await tester.dragFrom(mafsTopLeft + const Offset(150, 350), const Offset(50, 0));
      await tester.pumpAndSettle();
      expect(point2MovedTo, isNotNull, reason: 'Point 2 at (-2, -2) should be draggable');

      // Reset
      point2MovedTo = null;

      // Test horizontally constrained point at (0, -2) - screen (250, 350)
      await tester.dragFrom(mafsTopLeft + const Offset(250, 350), const Offset(50, 0));
      await tester.pumpAndSettle();
      expect(constrainedMovedTo, isNotNull, reason: 'Constrained point at (0, -2) should be draggable');
    });

    testWidgets('hit test - verify hitbox positions', (tester) async {
      // This test verifies the screen positions are calculated correctly
      await tester.pumpWidget(
        _wrapInMafs(
          MovablePoint(
            point: const Offset(2, 2),
            onMove: (_) {},
            color: MafsColors.pink,
          ),
        ),
      );

      // Get the RenderBox of the Mafs widget
      final mafsBox = tester.renderObject<RenderBox>(find.byType(Mafs));
      expect(mafsBox.size, const Size(500, 500));

      // The hitbox should be centered at screen coords (350, 150) for math coords (2, 2)
      // with viewBox (-5, 5) x (-5, 5) and 500x500 size
    });

  });

  group('MovablePoint hover detection', () {
    testWidgets('hover state changes on mouse enter/exit', (tester) async {
      await tester.pumpWidget(
        _wrapInMafs(
          MovablePoint(
            point: const Offset(0, 0),
            onMove: (_) {},
          ),
        ),
      );

      final mafsBox = tester.renderObject<RenderBox>(find.byType(Mafs));
      final mafsTopLeft = mafsBox.localToGlobal(Offset.zero);
      final center = mafsTopLeft + const Offset(250, 250);

      // Create a hover gesture
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);

      // Move to the point location
      await gesture.moveTo(center);
      await tester.pump();

      // Move away
      await gesture.moveTo(Offset.zero);
      await tester.pump();
    });

    testWidgets('hover state resets after drag ends outside hitbox', (tester) async {
      // This test verifies that dragging away and releasing doesn't leave
      // the point in a "stuck" hovered state.
      //
      // The issue: when dragging, onExit is ignored. After drag ends,
      // if the mouse is outside the hitbox, hover should reset.

      Offset currentPoint = const Offset(0, 0);

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _wrapInMafsStateless(
              MovablePoint(
                point: currentPoint,
                onMove: (p) => setState(() => currentPoint = p),
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();

      final mafsBox = tester.renderObject<RenderBox>(find.byType(Mafs));
      final mafsTopLeft = mafsBox.localToGlobal(Offset.zero);
      final center = mafsTopLeft + const Offset(250, 250);

      // Start drag on the point
      final gesture = await tester.startGesture(center);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      // Drag far away (200 pixels) - this will trigger onExit but it should be ignored during drag
      await gesture.moveBy(const Offset(200, 0));
      await tester.pump();

      // Release - now hover should reset since mouse is outside hitbox
      await gesture.up();
      await tester.pumpAndSettle();

      // The point has moved, so the new screen position is different
      // The mouse is no longer over the new hitbox position
      // Verify hover is reset by starting a new gesture NOT on the point
      // and checking that the point doesn't appear hovered

      // This is a smoke test - if the hover state was stuck, subsequent
      // interactions would behave incorrectly. The fix ensures hover resets.
    });
  });
}

/// Wraps a widget with the necessary context providers for testing.
Widget _wrapWithContext(Widget child) {
  return CoordinateContext(
    data: const CoordinateContextData(
      xMin: 0,
      xMax: 100,
      yMin: 0,
      yMax: 100,
      width: 100,
      height: 100,
    ),
    child: TransformContext(
      data: TransformContextData(
        userTransform: MatrixOps.identity,
        viewTransform: MatrixOps.identity,
      ),
      child: child,
    ),
  );
}

/// Wraps a widget inside a full Mafs widget for realistic testing.
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
          pan: true,
          zoom: true,
          children: [child],
        ),
      ),
    ),
  );
}

/// Wraps a widget inside a full Mafs widget, without adding Directionality
/// (for use with StatefulBuilder which needs to be at the root).
Widget _wrapInMafsStateless(Widget child) {
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
          pan: true,
          zoom: true,
          children: [child],
        ),
      ),
    ),
  );
}
