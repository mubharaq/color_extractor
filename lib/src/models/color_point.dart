import 'dart:math';

/// A point in 3D RGB color space.
class ColorPoint {
  /// Creates a color point with the given red, green, and blue values.
  ColorPoint(this.r, this.g, this.b);

  /// Red channel value.
  final double r;

  /// Green channel value.
  final double g;

  /// Blue channel value.
  final double b;

  /// Calculates the Euclidean distance between this color point and another.
  double distanceTo(ColorPoint other) {
    return sqrt(
      (r - other.r) * (r - other.r) +
          (g - other.g) * (g - other.g) +
          (b - other.b) * (b - other.b),
    );
  }

  /// Returns the average color point from a list of color points.
  /// If the list is empty, returns a black color point (0, 0, 0).
  // ignore: prefer_constructors_over_static_methods
  static ColorPoint average(List<ColorPoint> points) {
    if (points.isEmpty) return ColorPoint(0, 0, 0);
    final total = points.fold<List<double>>(
      [0, 0, 0],
      (sum, p) => [sum[0] + p.r, sum[1] + p.g, sum[2] + p.b],
    );

    final count = points.length.toDouble();
    return ColorPoint(total[0] / count, total[1] / count, total[2] / count);
  }
}
