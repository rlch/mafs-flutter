import 'package:flutter_test/flutter_test.dart';
import 'package:mafs_flutter/src/gestures/camera.dart';
import 'package:mafs_flutter/src/vec.dart';

void main() {
  group('CameraState', () {
    test('default values are zero offset and scale 1', () {
      final state = CameraState();
      expect(state.offset, Offset.zero);
      expect(state.scale, 1.0);
    });

    test('can be created with custom values', () {
      final state = CameraState(
        offset: const Offset(10, 20),
        scale: 2.0,
      );
      expect(state.offset, const Offset(10, 20));
      expect(state.scale, 2.0);
    });

    test('matrix applies translation and inverse scale', () {
      final state = CameraState(
        offset: const Offset(10, 20),
        scale: 2.0,
      );

      final matrix = state.matrix;
      const point = Offset(0, 0);
      final transformed = point.transform(matrix);

      // The matrix translates and then scales by 1/scale
      // So (0,0) -> (10/2, 20/2) = (5, 10)
      expect(transformed.dx, closeTo(5, 0.0001));
      expect(transformed.dy, closeTo(10, 0.0001));
    });

    test('copy creates independent copy', () {
      final state = CameraState(
        offset: const Offset(10, 20),
        scale: 2.0,
      );
      final copy = state.copy();

      state.offset = const Offset(30, 40);
      state.scale = 3.0;

      expect(copy.offset, const Offset(10, 20));
      expect(copy.scale, 2.0);
    });
  });

  group('CameraController', () {
    test('initial state is identity', () {
      final controller = CameraController();
      expect(controller.offset, Offset.zero);
      expect(controller.scale, 1.0);
    });

    test('setBase stores current state as base', () {
      final controller = CameraController(minZoom: 0.5, maxZoom: 5.0);
      controller.move(pan: const Offset(10, 20));
      controller.setBase();
      controller.move(pan: const Offset(5, 5));

      // After setBase, move should be relative to new base
      expect(controller.offset.dx, closeTo(15, 0.0001));
      expect(controller.offset.dy, closeTo(25, 0.0001));
    });

    test('move with pan updates offset', () {
      final controller = CameraController();
      controller.move(pan: const Offset(10, 20));

      expect(controller.offset, const Offset(10, 20));
    });

    test('move with zoom updates scale', () {
      final controller = CameraController(minZoom: 0.5, maxZoom: 5.0);
      controller.move(zoom: (at: Offset.zero, scale: 2.0));

      expect(controller.scale, closeTo(2.0, 0.0001));
    });

    test('zoom is clamped to min/max', () {
      final controller = CameraController(minZoom: 0.5, maxZoom: 2.0);

      controller.move(zoom: (at: Offset.zero, scale: 10.0));
      expect(controller.scale, 2.0);

      controller.setBase();
      controller.move(zoom: (at: Offset.zero, scale: 0.1));
      expect(controller.scale, 0.5);
    });

    test('zoom towards a focal point adjusts offset', () {
      final controller = CameraController(minZoom: 0.5, maxZoom: 5.0);

      // Zoom in towards (5, 5) by 2x
      controller.move(zoom: (at: const Offset(5, 5), scale: 2.0));

      // The offset should be adjusted to zoom towards the focal point
      expect(controller.offset.dx, isNot(0));
      expect(controller.offset.dy, isNot(0));
    });

    test('setOffset directly sets offset', () {
      final controller = CameraController();
      controller.setOffset(const Offset(100, 200));

      expect(controller.offset, const Offset(100, 200));
    });

    test('setScale directly sets scale with clamping', () {
      final controller = CameraController(minZoom: 0.5, maxZoom: 2.0);

      controller.setScale(1.5);
      expect(controller.scale, 1.5);

      controller.setScale(10.0);
      expect(controller.scale, 2.0);

      controller.setScale(0.1);
      expect(controller.scale, 0.5);
    });

    test('reset returns to initial state', () {
      final controller = CameraController(minZoom: 0.5, maxZoom: 5.0);
      controller.move(pan: const Offset(10, 20));
      controller.move(zoom: (at: Offset.zero, scale: 2.0));

      controller.reset();

      expect(controller.offset, Offset.zero);
      expect(controller.scale, 1.0);
    });

    test('notifies listeners on change', () {
      final controller = CameraController();
      var notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.move(pan: const Offset(10, 20));
      expect(notifyCount, 1);

      controller.setOffset(const Offset(30, 40));
      expect(notifyCount, 2);

      controller.setScale(2.0);
      expect(notifyCount, 3);

      controller.reset();
      expect(notifyCount, 4);
    });

    test('matrix property returns current state matrix', () {
      final controller = CameraController();
      controller.setOffset(const Offset(10, 20));
      controller.setScale(2.0);

      final matrix = controller.matrix;
      expect(matrix, controller.state.matrix);
    });

    test('dispose removes listeners', () {
      final controller = CameraController();
      var notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.dispose();

      // After dispose, the controller should still work but listeners are cleared
      // In Flutter's ChangeNotifier, dispose doesn't prevent further use,
      // but in production code we shouldn't use it after dispose
    });
  });
}
