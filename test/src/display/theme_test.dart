import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafs_flutter/src/display/theme.dart';

void main() {
  group('MafsColors', () {
    test('all colors are defined', () {
      expect(MafsColors.foreground, isA<Color>());
      expect(MafsColors.background, isA<Color>());
      expect(MafsColors.red, isA<Color>());
      expect(MafsColors.orange, isA<Color>());
      expect(MafsColors.green, isA<Color>());
      expect(MafsColors.blue, isA<Color>());
      expect(MafsColors.indigo, isA<Color>());
      expect(MafsColors.violet, isA<Color>());
      expect(MafsColors.pink, isA<Color>());
      expect(MafsColors.yellow, isA<Color>());
    });
  });

  group('MafsThemeData', () {
    test('default constructor creates valid theme', () {
      const theme = MafsThemeData();
      expect(theme.foreground, MafsColors.foreground);
      expect(theme.background, MafsColors.background);
      expect(theme.red, MafsColors.red);
    });

    test('light theme constant exists', () {
      expect(MafsThemeData.light, isA<MafsThemeData>());
      expect(MafsThemeData.light.foreground, MafsColors.foreground);
    });

    test('dark theme constant exists', () {
      expect(MafsThemeData.dark, isA<MafsThemeData>());
      expect(MafsThemeData.dark.foreground, const Color(0xFFFFFFFF));
      expect(MafsThemeData.dark.background, const Color(0xFF1A1A1A));
    });

    test('effectiveGridColor returns gridColor or default', () {
      const themeWithGrid = MafsThemeData(gridColor: Color(0xFF00FF00));
      expect(themeWithGrid.effectiveGridColor, const Color(0xFF00FF00));

      const themeWithoutGrid = MafsThemeData();
      expect(themeWithoutGrid.effectiveGridColor.a, lessThan(1));
    });

    test('effectiveAxisColor returns axisColor or foreground', () {
      const themeWithAxis = MafsThemeData(axisColor: Color(0xFF00FF00));
      expect(themeWithAxis.effectiveAxisColor, const Color(0xFF00FF00));

      const themeWithoutAxis = MafsThemeData();
      expect(themeWithoutAxis.effectiveAxisColor, MafsColors.foreground);
    });

    test('effectiveLabelColor returns labelColor or foreground', () {
      const themeWithLabel = MafsThemeData(labelColor: Color(0xFF00FF00));
      expect(themeWithLabel.effectiveLabelColor, const Color(0xFF00FF00));

      const themeWithoutLabel = MafsThemeData();
      expect(themeWithoutLabel.effectiveLabelColor, MafsColors.foreground);
    });

    test('copyWith creates modified copy', () {
      const original = MafsThemeData();
      final modified = original.copyWith(red: const Color(0xFF000000));

      expect(original.red, MafsColors.red);
      expect(modified.red, const Color(0xFF000000));
      expect(modified.foreground, original.foreground);
    });

    test('equality works correctly', () {
      const theme1 = MafsThemeData();
      const theme2 = MafsThemeData();
      const theme3 = MafsThemeData(red: Color(0xFF000000));

      expect(theme1 == theme2, true);
      expect(theme1 == theme3, false);
    });

    test('hashCode is consistent', () {
      const theme1 = MafsThemeData();
      const theme2 = MafsThemeData();

      expect(theme1.hashCode, theme2.hashCode);
    });
  });

  group('MafsTheme widget', () {
    testWidgets('provides theme to descendants', (tester) async {
      const testTheme = MafsThemeData(red: Color(0xFF123456));

      MafsThemeData? retrievedTheme;

      await tester.pumpWidget(
        MafsTheme(
          data: testTheme,
          child: Builder(
            builder: (context) {
              retrievedTheme = MafsTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(retrievedTheme, testTheme);
    });

    testWidgets('of returns default theme when not in tree', (tester) async {
      MafsThemeData? retrievedTheme;

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            retrievedTheme = MafsTheme.of(context);
            return const SizedBox();
          },
        ),
      );

      expect(retrievedTheme, MafsThemeData.light);
    });

    testWidgets('maybeOf returns null when not in tree', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            expect(MafsTheme.maybeOf(context), isNull);
            return const SizedBox();
          },
        ),
      );
    });

    testWidgets('notifies dependents on change', (tester) async {
      var buildCount = 0;

      await tester.pumpWidget(
        MafsTheme(
          data: const MafsThemeData(),
          child: Builder(
            builder: (context) {
              MafsTheme.of(context);
              buildCount++;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(buildCount, 1);

      await tester.pumpWidget(
        MafsTheme(
          data: const MafsThemeData(red: Color(0xFF000000)),
          child: Builder(
            builder: (context) {
              MafsTheme.of(context);
              buildCount++;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(buildCount, 2);
    });
  });

  group('StrokeStyle', () {
    test('has solid and dashed values', () {
      expect(StrokeStyle.solid, isNotNull);
      expect(StrokeStyle.dashed, isNotNull);
      expect(StrokeStyle.values.length, 2);
    });
  });
}
