import 'package:color_extractor/src/models/color_point.dart';

/// A centroid in 3D RGB color space.
class Centroid {
  /// Creates a centroid with the given red, green, and blue values.
  Centroid(this.r, this.g, this.b);

  /// Red channel value.
  double r;

  /// Green channel value.
  double g;

  /// Blue channel value.
  double b;

  /// Number of pixels associated with this centroid.
  int pixelCount = 0;

  /// Returns the color point associated with this centroid.
  ColorPoint get color => ColorPoint(r, g, b);

  /// Updates the centroid's color from a given color point.
  void updateFrom(ColorPoint p) {
    r = p.r;
    g = p.g;
    b = p.b;
  }
}
