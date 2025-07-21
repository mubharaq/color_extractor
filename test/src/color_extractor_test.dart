// ignore_for_file: prefer_const_constructors

import 'package:color_extractor/color_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DominantColor', () {
    test('can be instantiated', () {
      expect(ColorExtractor(), isNotNull);
    });
  });
}
