import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../vec.dart';

/// Camera state for pan and zoom interactions.
///
/// This manages the transformation state that results from user gestures
/// like panning and pinching to zoom.
class CameraState {
  /// Creates a camera state.
  CameraState({
    this.offset = Offset.zero,
    this.scale = 1.0,
  });

  /// The current pan offset.
  Offset offset;

  /// The current zoom scale.
  double scale;

  /// Converts this camera state to a transformation matrix.
  Matrix2D get matrix {
    return MatrixBuilder()
        .translate(offset.dx, offset.dy)
        .scale(1 / scale, 1 / scale)
        .build();
  }

  /// Creates a copy of this state.
  CameraState copy() {
    return CameraState(offset: offset, scale: scale);
  }
}

/// A controller for camera pan and zoom interactions.
///
/// This is modeled after the useCamera hook from the original Mafs.
class CameraController extends ChangeNotifier {
  /// Creates a camera controller.
  CameraController({
    this.minZoom = 1.0,
    this.maxZoom = 1.0,
  })  : _state = CameraState(),
        _baseState = CameraState();

  /// The minimum zoom scale (zoom out limit).
  ///
  /// Should be in the range (0, 1].
  final double minZoom;

  /// The maximum zoom scale (zoom in limit).
  ///
  /// Should be in the range [1, ∞).
  final double maxZoom;

  CameraState _state;
  CameraState _baseState;

  /// The current camera state.
  CameraState get state => _state;

  /// The transformation matrix for the current camera state.
  Matrix2D get matrix => _state.matrix;

  /// The current pan offset.
  Offset get offset => _state.offset;

  /// The current zoom scale.
  double get scale => _state.scale;

  /// Sets the base state for relative movements.
  ///
  /// Call this at the start of a gesture to establish a reference point
  /// for subsequent [move] calls.
  void setBase() {
    _baseState = _state.copy();
  }

  /// Move the camera by the given deltas relative to the base state.
  ///
  /// [pan] is the pan offset delta in math coordinates.
  /// [zoom] specifies a zoom operation with a focal point and scale factor.
  void move({
    Offset? pan,
    ({Offset at, double scale})? zoom,
  }) {
    var newOffset = _baseState.offset;
    var newScale = _baseState.scale;

    // Apply pan
    if (pan != null) {
      newOffset = Offset(
        newOffset.dx + pan.dx,
        newOffset.dy + pan.dy,
      );
    }

    // Apply zoom
    if (zoom != null) {
      // Clamp the new scale to the allowed range
      newScale = (newScale * zoom.scale).clamp(minZoom, maxZoom);

      // Calculate the scale delta that was actually applied
      final actualScaleDelta = newScale / _baseState.scale;

      // Adjust the offset to zoom towards the focal point
      final focalPoint = zoom.at;
      newOffset = Offset(
        focalPoint.dx + (newOffset.dx - focalPoint.dx) * actualScaleDelta,
        focalPoint.dy + (newOffset.dy - focalPoint.dy) * actualScaleDelta,
      );
    }

    _state = CameraState(offset: newOffset, scale: newScale);
    notifyListeners();
  }

  /// Directly set the camera offset.
  void setOffset(Offset offset) {
    _state.offset = offset;
    notifyListeners();
  }

  /// Directly set the camera scale.
  void setScale(double scale) {
    _state.scale = scale.clamp(minZoom, maxZoom);
    notifyListeners();
  }

  /// Reset the camera to its initial state.
  void reset() {
    _state = CameraState();
    _baseState = CameraState();
    notifyListeners();
  }
}
