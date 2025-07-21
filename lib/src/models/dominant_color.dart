import 'package:flutter_color_extractor/src/models/color_point.dart';

/// A dominant color in 3D RGB color space.
class DominantColor {
  /// Creates a dominant color with the given color point and percentage.
  DominantColor(this.color, this.percentage);

  /// The color point of the dominant color.
  final ColorPoint color;

  /// The percentage of the dominant color in the image analysed.
  final int percentage;
}
