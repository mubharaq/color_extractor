import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:color_extractor/src/utils/utils.dart';
import 'package:http/http.dart' as http;

/// {@template color_extractor}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
class ColorExtractor {
  /// {@macro color_extractor}
  const ColorExtractor();

  /// Extracts the dominant colors from an image path.
  ///
  /// [imagePath] is the path to the image file.
  /// [k] is the number of dominant colors to find.
  /// [maxIterations] is the maximum number of iterations to run the algorithm.
  /// [tolerance] is the tolerance for the algorithm to converge.
  Future<List<Color>> extractColorsFromPath(
    String imagePath, {
    int k = 5,
    int maxIterations = 50,
    double tolerance = 1.0,
  }) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) {
        throw Exception('File not found at $imagePath');
      }

      final bytes = await file.readAsBytes();
      final pixels = await extractPixels(bytes);
      return findDominantColors(
        pixels,
        k,
        maxIterations: maxIterations,
        tolerance: tolerance,
      );
    } catch (e) {
      log('Failed to extract from file: $e');
      return [];
    }
  }

  /// Extracts the dominant colors from an image URL.
  ///
  /// [imageUrl] is the URL of the image.
  /// [k] is the number of dominant colors to find.
  /// [maxIterations] is the maximum number of iterations to run the algorithm.
  /// [tolerance] is the tolerance for the algorithm to converge.
  Future<List<Color>> extractColorsFromNetwork(
    String imageUrl, {
    int k = 5,
    int maxIterations = 50,
    double tolerance = 1.0,
  }) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch image from network: $imageUrl');
      }

      final bytes = response.bodyBytes;
      final pixels = await extractPixels(bytes);
      return findDominantColors(
        pixels,
        k,
        maxIterations: maxIterations,
        tolerance: tolerance,
      );
    } catch (e) {
      log('Failed to extract from network: $e');
      return [];
    }
  }

  /// Extracts the dominant colors from a list of bytes.
  ///
  /// [bytes] is the list of bytes of the image.
  /// [k] is the number of dominant colors to find.
  /// [maxIterations] is the maximum number of iterations to run the algorithm.
  /// [tolerance] is the tolerance for the algorithm to converge.
  Future<List<Color>> extractColorsFromBytes(
    Uint8List bytes, {
    int k = 5,
    int maxIterations = 50,
    double tolerance = 1.0,
  }) async {
    try {
      final pixels = await extractPixels(bytes);
      return findDominantColors(
        pixels,
        k,
        maxIterations: maxIterations,
        tolerance: tolerance,
      );
    } catch (e) {
      log('Failed to extract from bytes: $e');
      return [];
    }
  }
}
