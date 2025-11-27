import 'package:flutter/widgets.dart';

/// Default theme colors for Mafs visualizations.
///
/// These are designed to work well on both light and dark backgrounds.
abstract final class MafsColors {
  /// Default foreground color (dark gray).
  static const Color foreground = Color(0xFF1A1A1A);

  /// Default background color (white).
  static const Color background = Color(0xFFFFFFFF);

  /// Red color for emphasis.
  static const Color red = Color(0xFFE63946);

  /// Orange color for emphasis.
  static const Color orange = Color(0xFFF4A261);

  /// Green color for emphasis.
  static const Color green = Color(0xFF2A9D8F);

  /// Blue color for emphasis.
  static const Color blue = Color(0xFF4361EE);

  /// Indigo color for emphasis.
  static const Color indigo = Color(0xFF7209B7);

  /// Violet color for emphasis.
  static const Color violet = Color(0xFF9B5DE5);

  /// Pink color for emphasis.
  static const Color pink = Color(0xFFF72585);

  /// Yellow color for emphasis.
  static const Color yellow = Color(0xFFFFC300);
}

/// Theme data for Mafs visualizations.
@immutable
class MafsThemeData {
  /// Creates Mafs theme data with the specified colors.
  const MafsThemeData({
    this.foreground = MafsColors.foreground,
    this.background = MafsColors.background,
    this.red = MafsColors.red,
    this.orange = MafsColors.orange,
    this.green = MafsColors.green,
    this.blue = MafsColors.blue,
    this.indigo = MafsColors.indigo,
    this.violet = MafsColors.violet,
    this.pink = MafsColors.pink,
    this.yellow = MafsColors.yellow,
    this.gridColor,
    this.axisColor,
    this.labelColor,
  });

  /// The default light theme.
  static const light = MafsThemeData();

  /// A dark theme variant.
  static const dark = MafsThemeData(
    foreground: Color(0xFFFFFFFF),
    background: Color(0xFF1A1A1A),
  );

  /// The foreground (default element) color.
  final Color foreground;

  /// The background color.
  final Color background;

  /// Red accent color.
  final Color red;

  /// Orange accent color.
  final Color orange;

  /// Green accent color.
  final Color green;

  /// Blue accent color.
  final Color blue;

  /// Indigo accent color.
  final Color indigo;

  /// Violet accent color.
  final Color violet;

  /// Pink accent color.
  final Color pink;

  /// Yellow accent color.
  final Color yellow;

  /// Color for grid lines. Defaults to [foreground] with reduced opacity.
  final Color? gridColor;

  /// Color for axis lines. Defaults to [foreground].
  final Color? axisColor;

  /// Color for axis labels. Defaults to [foreground].
  final Color? labelColor;

  /// Get the grid color, falling back to foreground with opacity.
  Color get effectiveGridColor => gridColor ?? foreground.withValues(alpha: 0.1);

  /// Get the axis color, falling back to foreground.
  Color get effectiveAxisColor => axisColor ?? foreground;

  /// Get the label color, falling back to foreground.
  Color get effectiveLabelColor => labelColor ?? foreground;

  /// Creates a copy of this theme with the given fields replaced.
  MafsThemeData copyWith({
    Color? foreground,
    Color? background,
    Color? red,
    Color? orange,
    Color? green,
    Color? blue,
    Color? indigo,
    Color? violet,
    Color? pink,
    Color? yellow,
    Color? gridColor,
    Color? axisColor,
    Color? labelColor,
  }) {
    return MafsThemeData(
      foreground: foreground ?? this.foreground,
      background: background ?? this.background,
      red: red ?? this.red,
      orange: orange ?? this.orange,
      green: green ?? this.green,
      blue: blue ?? this.blue,
      indigo: indigo ?? this.indigo,
      violet: violet ?? this.violet,
      pink: pink ?? this.pink,
      yellow: yellow ?? this.yellow,
      gridColor: gridColor ?? this.gridColor,
      axisColor: axisColor ?? this.axisColor,
      labelColor: labelColor ?? this.labelColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MafsThemeData &&
        other.foreground == foreground &&
        other.background == background &&
        other.red == red &&
        other.orange == orange &&
        other.green == green &&
        other.blue == blue &&
        other.indigo == indigo &&
        other.violet == violet &&
        other.pink == pink &&
        other.yellow == yellow &&
        other.gridColor == gridColor &&
        other.axisColor == axisColor &&
        other.labelColor == labelColor;
  }

  @override
  int get hashCode => Object.hash(
        foreground,
        background,
        red,
        orange,
        green,
        blue,
        indigo,
        violet,
        pink,
        yellow,
        gridColor,
        axisColor,
        labelColor,
      );
}

/// An inherited widget that provides [MafsThemeData] to descendants.
class MafsTheme extends InheritedWidget {
  /// Creates a Mafs theme widget.
  const MafsTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The theme data provided to descendants.
  final MafsThemeData data;

  /// Retrieves the [MafsThemeData] from the nearest ancestor [MafsTheme].
  ///
  /// Returns [MafsThemeData.light] if no [MafsTheme] is found.
  static MafsThemeData of(BuildContext context) {
    return maybeOf(context) ?? MafsThemeData.light;
  }

  /// Retrieves the [MafsThemeData] from the nearest ancestor [MafsTheme],
  /// or null if none is found.
  static MafsThemeData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MafsTheme>()?.data;
  }

  @override
  bool updateShouldNotify(MafsTheme oldWidget) {
    return data != oldWidget.data;
  }
}

/// Common stroke styles for Mafs elements.
enum StrokeStyle {
  /// A solid line.
  solid,

  /// A dashed line.
  dashed,
}

/// Mixin that provides common styling properties for filled shapes.
mixin FilledStyle {
  /// The fill/stroke color.
  Color? get color;

  /// The stroke weight in pixels.
  double get weight;

  /// The fill opacity (0.0 to 1.0).
  double get fillOpacity;

  /// The stroke opacity (0.0 to 1.0).
  double get strokeOpacity;

  /// The stroke style (solid or dashed).
  StrokeStyle get strokeStyle;
}

/// Mixin that provides common styling properties for stroked shapes.
mixin StrokedStyle {
  /// The stroke color.
  Color? get color;

  /// The stroke opacity (0.0 to 1.0).
  double get opacity;

  /// The stroke weight in pixels.
  double get weight;

  /// The stroke style (solid or dashed).
  StrokeStyle get style;
}
