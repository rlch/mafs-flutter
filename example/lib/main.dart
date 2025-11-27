import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mafs_flutter/mafs_flutter.dart';

void main() {
  runApp(const ExampleApp());
}

/// Example app demonstrating mafs_flutter.
///
/// Note: This uses [WidgetsApp] instead of MaterialApp to demonstrate
/// that mafs_flutter has no Material dependency.
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'Mafs Flutter Example',
      color: const Color(0xFF4361EE),
      builder: (context, child) => const ExampleScreen(),
    );
  }
}

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen>
    with SingleTickerProviderStateMixin {
  // Toggle states for different component categories
  bool _showPlots = true;
  bool _showShapes = false;
  bool _showLabels = true;
  bool _showInteractive = true;
  bool _showAnimations = false;

  // Interactive point positions
  Offset _movablePoint1 = const Offset(2, 1);
  Offset _movablePoint2 = const Offset(-1, -1);

  // Animation controller for animated demos
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF5F5F7),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Text(
                'Mafs Flutter',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Interactive Math Visualizations',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 12),

              // Toggle buttons (compact row)
              _buildToggleRow(),
              const SizedBox(height: 12),

              // Mafs visualization
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        final t = _animationController.value * 2 * math.pi;
                        return _buildMafs(t);
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Instructions
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _HintItem(icon: '👆', text: 'Drag to pan'),
                    _HintItem(icon: '🔍', text: 'Pinch to zoom'),
                    _HintItem(icon: '⬤', text: 'Drag points'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMafs(double t) {
    return Mafs(
      viewBox: const ViewBox(x: (-4, 4), y: (-3, 3)),
      pan: true,
      zoom: true,
      children: [
        Coordinates.cartesian(auto: true),

        // === Animations ===
        if (_showAnimations) ...[
          // Rotating triangle
          MafsTransform(
            rotate: t,
            child: const MafsPolygon(
              points: [
                Offset(0, 1.5),
                Offset(-1.3, -0.75),
                Offset(1.3, -0.75),
              ],
              color: MafsColors.violet,
              fillOpacity: 0.3,
            ),
          ),

          // Orbiting point
          MafsPoint(
            x: 2.5 * math.cos(t),
            y: 2.5 * math.sin(t),
            color: MafsColors.pink,
          ),

          // Orbit path
          const MafsCircle(
            center: Offset.zero,
            radius: 2.5,
            color: MafsColors.pink,
            fillOpacity: 0,
            strokeOpacity: 0.3,
          ),

          // Animated sine wave (phase shift)
          Plot.ofX(
            y: (x) => math.sin(x + t) * 0.8,
            color: MafsColors.green,
            weight: 2.5,
          ),

          // Pulsing circle
          MafsCircle(
            center: const Offset(-2.5, 1.5),
            radius: 0.4 + 0.2 * math.sin(t * 2),
            color: MafsColors.orange,
            fillOpacity: 0.4,
          ),

          // Lissajous curve (parametric)
          Plot.parametric(
            xy: (s) => Offset(
              2 * math.sin(3 * s + t),
              2 * math.sin(2 * s),
            ),
            domain: (0, 2 * math.pi),
            color: MafsColors.blue,
            weight: 2,
          ),

          // Animated vector
          MafsVector(
            tail: const Offset(-2.5, -1.5),
            tip: Offset(
              -2.5 + 1.5 * math.cos(t * 1.5),
              -1.5 + 1.5 * math.sin(t * 1.5),
            ),
            color: MafsColors.red,
            weight: 2,
          ),
        ],

        // === Plots ===
        if (_showPlots) ...[
          // Sine wave
          Plot.ofX(
            y: (x) => math.sin(x),
            color: MafsColors.blue,
            weight: 2.5,
          ),
          // Parabola
          Plot.ofX(
            y: (x) => x * x / 4 - 1,
            color: MafsColors.red,
            weight: 2,
          ),
        ],

        // === Shapes ===
        if (_showShapes) ...[
          const MafsCircle(
            center: Offset(-2.5, 1.5),
            radius: 0.8,
            color: MafsColors.pink,
          ),
          MafsEllipse(
            center: const Offset(2.5, 1.5),
            radius: const Offset(1, 0.5),
            angle: math.pi / 6,
            color: MafsColors.orange,
          ),
          const MafsPolygon(
            points: [
              Offset(-3, -1.5),
              Offset(-2, -0.5),
              Offset(-1, -1.5),
            ],
            color: MafsColors.green,
            fillOpacity: 0.3,
          ),
          const MafsVector(
            tip: Offset(1.5, 2),
            color: MafsColors.violet,
            weight: 2,
          ),
        ],

        // === Labels (LaTeX + Text) ===
        if (_showLabels) ...[
          // LaTeX labels for functions
          MafsLaTeX.builder(
            x: 2.5,
            y: 1,
            anchor: Anchor.cl,
            builder: (context, style) => Math.tex(
              r'y = \sin(x)',
              textStyle: TextStyle(
                color: MafsColors.blue,
                fontSize: style.fontSize,
              ),
            ),
          ),
          MafsLaTeX.builder(
            x: -2.5,
            y: -2,
            anchor: Anchor.tc,
            builder: (context, style) => Math.tex(
              r'y = \frac{x^2}{4} - 1',
              textStyle: TextStyle(
                color: MafsColors.red,
                fontSize: style.fontSize,
              ),
            ),
          ),
          // Origin label
          const MafsText(
            x: 0,
            y: 0,
            text: 'O',
            attach: CardinalDirection.sw,
            attachDistance: 8,
            size: 14,
          ),
        ],

        // === Interactive ===
        if (_showInteractive) ...[
          // Movable points
          MovablePoint(
            point: _movablePoint1,
            onMove: (p) => setState(() => _movablePoint1 = p),
            color: MafsColors.pink,
          ),
          MovablePoint(
            point: _movablePoint2,
            onMove: (p) => setState(() => _movablePoint2 = p),
            color: MafsColors.blue,
          ),
          // Line between points
          Line.segment(
            point1: _movablePoint1,
            point2: _movablePoint2,
            color: MafsColors.foreground,
            opacity: 0.4,
            style: StrokeStyle.dashed,
          ),
          // Distance label
          MafsLaTeX.builder(
            x: (_movablePoint1.dx + _movablePoint2.dx) / 2,
            y: (_movablePoint1.dy + _movablePoint2.dy) / 2 + 0.3,
            builder: (context, style) {
              final dx = _movablePoint1.dx - _movablePoint2.dx;
              final dy = _movablePoint1.dy - _movablePoint2.dy;
              final dist = math.sqrt(dx * dx + dy * dy);
              return Math.tex(
                'd = ${dist.toStringAsFixed(2)}',
                textStyle: TextStyle(
                  color: style.color,
                  fontSize: 14,
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildToggleRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ToggleChip(
          label: 'Plots',
          isActive: _showPlots,
          color: MafsColors.blue,
          onTap: () => setState(() => _showPlots = !_showPlots),
        ),
        _ToggleChip(
          label: 'Shapes',
          isActive: _showShapes,
          color: MafsColors.pink,
          onTap: () => setState(() => _showShapes = !_showShapes),
        ),
        _ToggleChip(
          label: 'Labels',
          isActive: _showLabels,
          color: MafsColors.indigo,
          onTap: () => setState(() => _showLabels = !_showLabels),
        ),
        _ToggleChip(
          label: 'Interactive',
          isActive: _showInteractive,
          color: MafsColors.orange,
          onTap: () => setState(() => _showInteractive = !_showInteractive),
        ),
        _ToggleChip(
          label: 'Animations',
          isActive: _showAnimations,
          color: MafsColors.green,
          onTap: () => setState(() => _showAnimations = !_showAnimations),
        ),
      ],
    );
  }
}

/// Hint item showing an icon and text.
class _HintItem extends StatelessWidget {
  const _HintItem({required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

/// A compact toggle chip widget.
class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.12) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? color.withValues(alpha: 0.5) : const Color(0xFFD1D5DB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? color : const Color(0xFF9CA3AF),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? color : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
