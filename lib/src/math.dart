import 'dart:math' as math;

/// An interval represented as (min, max).
typedef Interval = (double min, double max);

/// Anchor positions for alignment.
///
/// Format: vertical (t=top, c=center, b=bottom) + horizontal (l=left, c=center, r=right)
enum Anchor {
  /// Top-left
  tl,

  /// Top-center
  tc,

  /// Top-right
  tr,

  /// Center-left
  cl,

  /// Center-center
  cc,

  /// Center-right
  cr,

  /// Bottom-left
  bl,

  /// Bottom-center
  bc,

  /// Bottom-right
  br,
}

/// Round a [value] to the specified [precision] decimal places.
double round(double value, [int precision = 0]) {
  final multiplier = math.pow(10, precision);
  return (value * multiplier).round() / multiplier;
}

/// Round a value to the nearest power of 10.
///
/// Example: 350 -> 100, 3500 -> 1000
double roundToNearestPowerOf10(double value) {
  if (value <= 0) return 1;
  return math.pow(10, (math.log(value) / math.ln10).floor()).toDouble();
}

/// Find the value in [options] closest to [value].
///
/// Returns a record with the closest value and its index.
({double value, int index}) pickClosestToValue(
  double value,
  List<double> options,
) {
  assert(options.isNotEmpty, 'Options list cannot be empty');

  var closestIndex = 0;
  var closestDistance = (options[0] - value).abs();

  for (var i = 1; i < options.length; i++) {
    final distance = (options[i] - value).abs();
    if (distance < closestDistance) {
      closestDistance = distance;
      closestIndex = i;
    }
  }

  return (value: options[closestIndex], index: closestIndex);
}

/// Generate a list of numbers from [min] to [max] (inclusive) with [step].
///
/// The final value in the list will be [max] or the closest value that
/// doesn't exceed [max].
List<double> range(double min, double max, [double step = 1]) {
  final result = <double>[];

  for (var i = min; i < max - step / 2; i += step) {
    result.add(i);
  }

  if (result.isEmpty) {
    result.add(min);
    if (max != min) result.add(max);
    return result;
  }

  final computedMax = result.last + step;
  if ((max - computedMax).abs() < step / 1e6) {
    result.add(max);
  } else {
    result.add(computedMax);
  }

  return result;
}

/// Clamp a [number] between [min] and [max].
double clamp(double number, double min, double max) {
  return number.clamp(min, max);
}

/// Given an [anchor] and a bounding box, compute the x and y coordinates
/// such that rendering an element at those coordinates will align it with
/// the anchor.
///
/// Returns (actualX, actualY).
(double, double) computeAnchor(
  Anchor anchor,
  double x,
  double y,
  double width,
  double height,
) {
  double actualX = x;
  double actualY = y;

  switch (anchor) {
    case Anchor.tl:
      actualX = x;
      actualY = y;
    case Anchor.tc:
      actualX = x - width / 2;
      actualY = y;
    case Anchor.tr:
      actualX = x - width;
      actualY = y;
    case Anchor.cl:
      actualX = x;
      actualY = y + height / 2;
    case Anchor.cc:
      actualX = x - width / 2;
      actualY = y + height / 2;
    case Anchor.cr:
      actualX = x - width;
      actualY = y + height / 2;
    case Anchor.bl:
      actualX = x;
      actualY = y + height;
    case Anchor.bc:
      actualX = x - width / 2;
      actualY = y + height;
    case Anchor.br:
      actualX = x - width;
      actualY = y + height;
  }

  return (actualX, actualY);
}
