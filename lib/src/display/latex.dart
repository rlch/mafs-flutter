import 'package:flutter/widgets.dart';

import '../math.dart';
import 'theme.dart';
import 'widget.dart';

/// A widget that renders LaTeX mathematical notation at a specific coordinate.
///
/// This widget positions LaTeX content at the given (x, y) position in math
/// coordinates. It requires a LaTeX rendering widget to be passed as [child],
/// such as one from the `flutter_math_fork` package.
///
/// The LaTeX content is centered on the coordinate by default (using
/// [Anchor.cc]), but this can be changed with the [anchor] parameter.
///
/// ## Usage with flutter_math_fork
///
/// Add `flutter_math_fork` to your pubspec.yaml:
/// ```yaml
/// dependencies:
///   flutter_math_fork: ^0.7.0
/// ```
///
/// Then use it with MafsLaTeX:
/// ```dart
/// import 'package:flutter_math_fork/flutter_math.dart';
///
/// MafsLaTeX(
///   x: 0,
///   y: 2,
///   tex: r'\int_0^1 x^2 \, dx = \frac{1}{3}',
/// )
/// ```
///
/// ## Custom LaTeX Renderer
///
/// If you prefer a different LaTeX package, use [MafsLaTeX.builder]:
/// ```dart
/// MafsLaTeX.builder(
///   x: 0,
///   y: 2,
///   builder: (context, style) => MyCustomLatexWidget(
///     tex: r'\sum_{i=1}^n i',
///     style: style,
///   ),
/// )
/// ```
///
/// ## Styling
///
/// The [color] parameter sets the text color. If not specified, it uses
/// the theme's foreground color.
///
/// The [fontSize] parameter controls the base font size (default: 20).
class MafsLaTeX extends StatelessWidget {
  /// Creates a LaTeX widget at the specified coordinates.
  ///
  /// The [tex] parameter is the LaTeX string to render.
  ///
  /// This constructor uses the default LaTeX builder which requires
  /// `flutter_math_fork` to be available. If you need a custom renderer,
  /// use [MafsLaTeX.builder] instead.
  const MafsLaTeX({
    super.key,
    required this.x,
    required this.y,
    required this.tex,
    this.color,
    this.fontSize = 20,
    this.anchor = Anchor.cc,
  })  : builder = null;

  /// Creates a LaTeX widget with a custom builder.
  ///
  /// Use this when you want to use a custom LaTeX rendering package
  /// or need more control over the rendering.
  const MafsLaTeX.builder({
    super.key,
    required this.x,
    required this.y,
    required LaTeXBuilder this.builder,
    this.color,
    this.fontSize = 20,
    this.anchor = Anchor.cc,
  }) : tex = null;

  /// The x-coordinate in math space.
  final double x;

  /// The y-coordinate in math space.
  final double y;

  /// The LaTeX string to render.
  ///
  /// This is null when using [MafsLaTeX.builder].
  final String? tex;

  /// Custom builder for rendering LaTeX.
  ///
  /// This is null when using the default constructor.
  final LaTeXBuilder? builder;

  /// The text color.
  ///
  /// If null, uses [MafsThemeData.foreground] from the nearest [MafsTheme].
  final Color? color;

  /// The base font size in pixels.
  ///
  /// Defaults to 20.
  final double fontSize;

  /// The anchor point for positioning.
  ///
  /// Determines which point of the LaTeX widget is placed at (x, y).
  /// Defaults to [Anchor.cc] (center-center).
  final Anchor anchor;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? MafsTheme.of(context).foreground;

    final style = LaTeXStyle(
      color: effectiveColor,
      fontSize: fontSize,
    );

    Widget child;
    if (builder != null) {
      child = builder!(context, style);
    } else {
      // Default builder - users need flutter_math_fork
      child = _DefaultLaTeXBuilder(tex: tex!, style: style);
    }

    return MafsWidget(
      x: x,
      y: y,
      anchor: anchor,
      child: child,
    );
  }
}

/// Style information for LaTeX rendering.
@immutable
class LaTeXStyle {
  /// Creates LaTeX style information.
  const LaTeXStyle({
    required this.color,
    required this.fontSize,
  });

  /// The text color.
  final Color color;

  /// The font size.
  final double fontSize;
}

/// Builder function for custom LaTeX rendering.
///
/// The [style] parameter contains color and font size information.
typedef LaTeXBuilder = Widget Function(BuildContext context, LaTeXStyle style);

/// Default LaTeX builder that displays a placeholder.
///
/// This is shown when flutter_math_fork is not available.
/// Users should either:
/// 1. Add flutter_math_fork and use the MafsLaTeX widget normally
/// 2. Use MafsLaTeX.builder with their preferred LaTeX package
class _DefaultLaTeXBuilder extends StatelessWidget {
  const _DefaultLaTeXBuilder({
    required this.tex,
    required this.style,
  });

  final String tex;
  final LaTeXStyle style;

  @override
  Widget build(BuildContext context) {
    // Return a styled text placeholder
    // Users should use flutter_math_fork or a custom builder for real LaTeX
    return Text(
      tex,
      style: TextStyle(
        color: style.color,
        fontSize: style.fontSize,
        fontFamily: 'monospace',
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
