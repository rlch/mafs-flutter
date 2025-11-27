import 'package:flutter/widgets.dart';
import '../vec.dart';

/// Data class containing transformation matrices for Mafs rendering.
@immutable
class TransformContextData {
  /// Creates transform context data.
  const TransformContextData({
    required this.userTransform,
    required this.viewTransform,
  });

  /// The resulting transformation matrix from any user-provided transforms
  /// (via the Transform component).
  ///
  /// This represents transformations applied by the user to position/rotate/scale
  /// elements within the coordinate system.
  final Matrix2D userTransform;

  /// A transformation that maps "math" space to pixel space.
  ///
  /// This transforms coordinates from the mathematical coordinate system
  /// (where y increases upward) to screen coordinates (where y increases downward).
  final Matrix2D viewTransform;

  /// The combined transformation matrix (viewTransform * userTransform).
  ///
  /// Use this to transform a point from user space directly to pixel space.
  Matrix2D get combinedTransform => MatrixOps.mult(viewTransform, userTransform);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransformContextData &&
        other.userTransform == userTransform &&
        other.viewTransform == viewTransform;
  }

  @override
  int get hashCode => Object.hash(userTransform, viewTransform);

  @override
  String toString() {
    return 'TransformContextData(userTransform: $userTransform, '
        'viewTransform: $viewTransform)';
  }
}

/// Aspects of [TransformContext] that can be depended on independently.
enum TransformAspect {
  /// Depend on the user-provided transformation.
  userTransform,

  /// Depend on the view transformation (math space to pixel space).
  viewTransform,
}

/// An inherited widget that provides transformation matrices to descendants.
///
/// This is implemented as an [InheritedModel] to allow widgets to depend only
/// on specific transformation matrices, enabling fine-grained rebuilds.
class TransformContext extends InheritedModel<TransformAspect> {
  /// Creates a transform context.
  const TransformContext({
    super.key,
    required this.data,
    required super.child,
  });

  /// The transform context data.
  final TransformContextData data;

  /// Retrieves the [TransformContextData] from the nearest ancestor
  /// [TransformContext].
  ///
  /// If [aspect] is provided, the widget will only rebuild when that specific
  /// transformation changes.
  ///
  /// Throws a [FlutterError] if no [TransformContext] is found in the tree.
  static TransformContextData of(
    BuildContext context, {
    TransformAspect? aspect,
  }) {
    final result = maybeOf(context, aspect: aspect);
    if (result == null) {
      throw FlutterError.fromParts([
        ErrorSummary('TransformContext.of() called without a TransformContext in scope.'),
        ErrorDescription(
          'No TransformContext ancestor could be found starting from the context '
          'that was passed to TransformContext.of().',
        ),
        ErrorHint(
          'This usually means the widget is not inside a Mafs widget. '
          'Make sure your widget is a descendant of Mafs.',
        ),
        context.describeElement('The context used was'),
      ]);
    }
    return result;
  }

  /// Retrieves the [TransformContextData] from the nearest ancestor
  /// [TransformContext], or null if none is found.
  static TransformContextData? maybeOf(
    BuildContext context, {
    TransformAspect? aspect,
  }) {
    return InheritedModel.inheritFrom<TransformContext>(
      context,
      aspect: aspect,
    )?.data;
  }

  @override
  bool updateShouldNotify(TransformContext oldWidget) {
    return data != oldWidget.data;
  }

  @override
  bool updateShouldNotifyDependent(
    TransformContext oldWidget,
    Set<TransformAspect> dependencies,
  ) {
    if (dependencies.contains(TransformAspect.userTransform)) {
      if (data.userTransform != oldWidget.data.userTransform) {
        return true;
      }
    }
    if (dependencies.contains(TransformAspect.viewTransform)) {
      if (data.viewTransform != oldWidget.data.viewTransform) {
        return true;
      }
    }
    return false;
  }
}
