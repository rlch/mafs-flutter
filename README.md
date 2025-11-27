# Mafs Flutter

A Flutter library for creating interactive math visualizations. This is a port of the React [Mafs](https://mafs.dev) library.

**No Material or Cupertino dependencies** — uses only `dart:ui`, `rendering`, and `widgets` layers.

## Features

- 📊 **Function Plots** — Plot y=f(x), x=f(y), and parametric curves
- 🔷 **Shapes** — Points, circles, ellipses, polygons, polylines, vectors
- 📏 **Lines** — Segments, rays, and infinite lines with various styles
- 🏷️ **Labels** — Text and LaTeX mathematical notation
- 🎯 **Interaction** — Draggable points with optional constraints
- 🔄 **Transforms** — Translate, rotate, scale, and shear
- 🖱️ **Pan & Zoom** — Built-in gesture support
- 🎨 **Theming** — Customizable colors and styles

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  mafs_flutter: ^0.0.1
```

For LaTeX support, also add:

```yaml
dependencies:
  flutter_math_fork: ^0.7.2
```

## Quick Start

```dart
import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:mafs_flutter/mafs_flutter.dart';

class SineWaveDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Mafs(
      viewBox: const ViewBox(x: (-5, 5), y: (-2, 2)),
      pan: true,
      zoom: true,
      children: [
        Coordinates.cartesian(),
        Plot.ofX(
          y: (x) => math.sin(x),
          color: MafsColors.blue,
        ),
        const MafsText(x: 3, y: 1, text: 'y = sin(x)'),
      ],
    );
  }
}
```

## Components

### Display

| Component | Description |
|-----------|-------------|
| `MafsPoint` | A point at (x, y) coordinates |
| `MafsCircle` | A circle with center and radius |
| `MafsEllipse` | An ellipse with optional rotation |
| `MafsPolygon` | A closed polygon from vertices |
| `MafsPolyline` | An open polyline from vertices |
| `MafsVector` | A vector with arrow head |
| `MafsText` | Text label at coordinates |
| `MafsLaTeX` | LaTeX math notation (requires `flutter_math_fork`) |
| `MafsWidget` | Position any Flutter widget in math coordinates |

### Lines

```dart
// Line segment between two points
Line.segment(point1: Offset(0, 0), point2: Offset(2, 2))

// Infinite line through point with slope
Line.pointSlope(point: Offset(0, 1), slope: -1)

// Infinite line through two points
Line.throughPoints(point1: Offset(0, 0), point2: Offset(1, 1))

// Infinite line: ax + by + c = 0
Line.pointAngle(point: Offset(0, 0), angle: math.pi / 4)
```

### Plots

```dart
// y = f(x)
Plot.ofX(y: (x) => math.sin(x))

// x = f(y)
Plot.ofY(x: (y) => y * y)

// Parametric: (x(t), y(t))
Plot.parametric(
  xy: (t) => Offset(math.cos(t), math.sin(t)),
  domain: (0, 2 * math.pi),
)

// Vector field
Plot.vectorField(
  xy: (point) => Offset(-point.dy, point.dx),
)
```

### Coordinates

```dart
// Cartesian grid with axes
Coordinates.cartesian()

// Auto-scaling grid (adjusts to zoom level)
Coordinates.cartesian(auto: true)

// Polar coordinates
Coordinates.polar()
```

### Transforms

```dart
MafsTransform(
  translate: Offset(2, 0),
  rotate: math.pi / 4,  // 45 degrees
  scale: Offset(1.5, 1.5),
  child: MafsCircle(center: Offset.zero, radius: 1),
)
```

### Interaction

```dart
MovablePoint(
  point: _position,
  onMove: (p) => setState(() => _position = p),
  color: MafsColors.pink,
)

// Constrained to horizontal line at y=0
MovablePoint(
  point: _position,
  onMove: (p) => setState(() => _position = p),
  constrain: MovablePoint.horizontal(0),
)

// Constrained to a circle
MovablePoint(
  point: _position,
  onMove: (p) => setState(() => _position = p),
  constrain: (p) => /* return constrained point */,
)
```

### LaTeX

```dart
import 'package:flutter_math_fork/flutter_math.dart';

MafsLaTeX.builder(
  x: 0,
  y: 2,
  builder: (context, style) => Math.tex(
    r'\int_0^1 x^2 \, dx = \frac{1}{3}',
    textStyle: TextStyle(
      color: style.color,
      fontSize: style.fontSize,
    ),
  ),
)
```

### Custom Widgets

Position any Flutter widget in math coordinates:

```dart
// Fixed pixel size (doesn't scale with zoom)
MafsWidget(
  x: 1,
  y: 2,
  anchor: Anchor.tl,
  child: Container(
    padding: EdgeInsets.all(8),
    color: Colors.blue,
    child: Text('Label'),
  ),
)

// Size in math units (scales with zoom)
MafsWidget(
  x: 0,
  y: 0,
  width: 2,   // 2 math units wide
  height: 1,  // 1 math unit tall
  child: Image.asset('diagram.png'),
)
```

## Theming

```dart
Mafs(
  theme: MafsThemeData(
    background: Color(0xFFFFFFFF),
    foreground: Color(0xFF1A1A2E),
  ),
  children: [...],
)

// Use predefined colors
MafsColors.blue
MafsColors.red
MafsColors.green
MafsColors.pink
// ... and more
```

## ViewBox

Control the visible coordinate range:

```dart
Mafs(
  viewBox: ViewBox(
    x: (-10, 10),  // x from -10 to 10
    y: (-5, 5),   // y from -5 to 5
    padding: 0.5, // padding in math units
  ),
  preserveAspectRatio: PreserveAspectRatio.contain,
  children: [...],
)
```

## Example

See the [example](example/) directory for a complete demo app.

## Credits

This is a Flutter port of [Mafs](https://mafs.dev) by Steven Petryk.

## License

MIT
