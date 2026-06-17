import 'dart:typed_data';
import 'dart:ui';

import 'image_processor_stub.dart'
    if (dart.library.js_interop) 'image_processor_web.dart'
    if (dart.library.io) 'image_processor_native.dart';

abstract class DecodedImage {
  int get width;
  int get height;
  Color getPixelColor(int x, int y);
}

class ImageProcessor {
  /// Decodes image bytes to a platform-optimized representation.
  /// On Native, uses package:image.
  /// On Web, uses browser's HTML canvas.
  static Future<DecodedImage> decodeImage(Uint8List bytes) {
    return decodeImageImpl(bytes);
  }

  /// Processes the image to remove background color with specified threshold and smoothness.
  /// On Native, runs in an isolate via compute.
  /// On Web, runs asynchronously on browser's HTML canvas.
  static Future<Uint8List> removeBackground({
    required Uint8List bytes,
    required Color color,
    required double threshold,
    required double smoothness,
  }) {
    return removeBackgroundImpl(
      bytes: bytes,
      color: color,
      threshold: threshold,
      smoothness: smoothness,
    );
  }
}
