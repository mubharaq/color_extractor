import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:color_extractor/src/models/centroid.dart';
import 'package:color_extractor/src/models/color_point.dart';
import 'package:color_extractor/src/models/dominant_color.dart';
import 'package:image/image.dart' as img;

/// Extracts pixels and returns a list of ColorPoint objects.
///
/// [bytes] is the bytes of the image file.
/// [resizeTo] optionally resizes the image to the given width and height
/// (default is 128).
Future<List<ColorPoint>> extractPixels(
  Uint8List bytes, {
  int resizeTo = 128,
}) async {
  try {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception('Failed to decode image: $bytes');

    final resized = img.copyResize(decoded, width: resizeTo, height: resizeTo);
    final pixels = <ColorPoint>[];

    for (var y = 0; y < resized.height; y++) {
      for (var x = 0; x < resized.width; x++) {
        final pixel = resized.getPixel(x, y);
        pixels.add(
          ColorPoint(
            pixel.r.toDouble(),
            pixel.g.toDouble(),
            pixel.b.toDouble(),
          ),
        );
      }
    }

    return pixels;
  } catch (e) {
    throw Exception('Error extracting pixels from $bytes: $e');
  }
}

/// Finds the dominant colors in a list of ColorPoint objects.
///
/// [pixels] is the list of ColorPoint objects to find the dominant colors in.
/// [k] is the number of dominant colors to find.
/// [maxIterations] is the maximum number of iterations to run the algorithm.
/// [tolerance] is the tolerance for the algorithm to converge.
List<Color> findDominantColors(
  List<ColorPoint> pixels,
  int k, {
  int maxIterations = 50,
  double tolerance = 1.0,
}) {
  final rand = Random();
  final centroids = List.generate(
    k,
    (_) {
      final p = pixels[rand.nextInt(pixels.length)];
      return Centroid(p.r, p.g, p.b);
    },
  );

  var hasConverged = false;
  var iteration = 0;

  while (!hasConverged && iteration < maxIterations) {
    final assignments = List.generate(k, (_) => <ColorPoint>[]);
    for (final c in centroids) {
      c.pixelCount = 0;
    }

    for (final pixel in pixels) {
      var closest = 0;
      var minDist = double.infinity;

      for (var i = 0; i < centroids.length; i++) {
        final dist = pixel.distanceTo(centroids[i].color);
        if (dist < minDist) {
          minDist = dist;
          closest = i;
        }
      }

      assignments[closest].add(pixel);
      centroids[closest].pixelCount += 1;
    }

    hasConverged = true;

    for (var i = 0; i < k; i++) {
      if (assignments[i].isEmpty) continue;
      final newColor = ColorPoint.average(assignments[i]);
      final oldColor = centroids[i].color;
      final delta = newColor.distanceTo(oldColor);

      if (delta > tolerance) hasConverged = false;

      centroids[i].updateFrom(newColor);
    }

    iteration++;
  }

  final totalPixels = pixels.length;
  final dominantColors = centroids
      .map(
        (c) => DominantColor(
          c.color,
          ((c.pixelCount / totalPixels) * 100).round(),
        ),
      )
      .toList()
    ..sort((a, b) => b.percentage.compareTo(a.percentage));
  return dominantColors
      .map(
        (c) => Color.fromARGB(
          255,
          c.color.r.toInt(),
          c.color.g.toInt(),
          c.color.b.toInt(),
        ),
      )
      .toList();
}
