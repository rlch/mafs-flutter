# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2025-06-18

### Added

#### Core
- `Mafs` widget - Main container with pan and zoom support
- `ViewBox` - Configurable coordinate range with padding and aspect ratio options
- `CameraController` - Programmatic control of pan/zoom state

#### Display Components
- `MafsPoint` - Render points at specific coordinates
- `MafsCircle` - Circles with customizable fill and stroke
- `MafsEllipse` - Ellipses with rotation support
- `MafsPolygon` - Closed polygons from vertex list
- `MafsPolyline` - Open polylines from vertex list
- `MafsVector` - Vectors with arrow heads
- `MafsText` - Text labels with cardinal direction anchoring
- `MafsLaTeX` - LaTeX rendering support (requires `flutter_math_fork`)
- `MafsWidget` - Position any Flutter widget in math coordinates

#### Lines
- `Line.segment` - Line segment between two points
- `Line.throughPoints` - Infinite line through two points
- `Line.pointSlope` - Infinite line with point and slope
- `Line.pointAngle` - Infinite line with point and angle

#### Plots
- `Plot.ofX` - Plot y = f(x) functions
- `Plot.ofY` - Plot x = f(y) functions
- `Plot.parametric` - Parametric curves (x(t), y(t))
- Adaptive sampling for smooth curves at any zoom level

#### Coordinate Systems
- `Coordinates.cartesian` - Cartesian grid with axes and labels
- `Coordinates.polar` - Polar grid with concentric circles and radial lines
- Auto-scaling grid that adjusts to zoom level

#### Transforms
- `MafsTransform` - Apply geometric transformations to children
- Support for translate, rotate, scale, shear, and custom matrices
- Transforms compose when nested

#### Interaction
- `MovablePoint` - Draggable points with hover animations
- Constraint functions for horizontal, vertical, or custom paths

#### Theming
- `MafsTheme` - Customize colors and styles
- `MafsColors` - Predefined color palette matching original Mafs

#### Infrastructure
- No Material or Cupertino dependencies - uses only `dart:ui`, `rendering`, and `widgets`
- LeafRenderObjectWidget pattern for efficient rendering
- Comprehensive documentation with examples
- 519 tests covering all components

### Notes

This is the initial release of mafs_flutter, a Flutter port of the React [Mafs](https://mafs.dev) library by Steven Petryk.

[0.0.1]: https://github.com/rlch/mafs-flutter/releases/tag/v0.0.1
