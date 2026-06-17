import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart' show compute;
import 'package:image/image.dart' as img;
import 'image_processor.dart';

class NativeDecodedImage implements DecodedImage {
  final img.Image image;

  NativeDecodedImage(this.image);

  @override
  int get width => image.width;

  @override
  int get height => image.height;

  @override
  Color getPixelColor(int x, int y) {
    final pixel = image.getPixel(x, y);
    return Color.fromARGB(
      255,
      pixel.r.toInt(),
      pixel.g.toInt(),
      pixel.b.toInt(),
    );
  }
}

Future<DecodedImage> decodeImageImpl(Uint8List bytes) async {
  final decoded = await compute(_decodeNative, bytes);
  if (decoded == null) {
    throw Exception('Failed to decode image');
  }
  return NativeDecodedImage(decoded);
}

img.Image? _decodeNative(Uint8List bytes) {
  return img.decodeImage(bytes);
}

Future<Uint8List> removeBackgroundImpl({
  required Uint8List bytes,
  required Color color,
  required double threshold,
  required double smoothness,
}) async {
  return compute(_removeBackgroundNative, {
    'bytes': bytes,
    'r': (color.r * 255).round().clamp(0, 255),
    'g': (color.g * 255).round().clamp(0, 255),
    'b': (color.b * 255).round().clamp(0, 255),
    'threshold': threshold,
    'smoothness': smoothness,
  });
}

Uint8List _removeBackgroundNative(Map<String, dynamic> params) {
  final Uint8List bytes = params['bytes'];
  final int bgR = params['r'];
  final int bgG = params['g'];
  final int bgB = params['b'];
  final double threshold = params['threshold'].toDouble();
  final double smoothness = params['smoothness'].toDouble();

  // Decode the image
  final img.Image? decodedImage = img.decodeImage(bytes);
  if (decodedImage == null) {
    throw Exception('Failed to decode image');
  }

  // Ensure the image has 4 channels (RGBA) to support transparency
  img.Image rgbaImage = decodedImage.numChannels == 4
      ? decodedImage
      : decodedImage.convert(numChannels: 4);

  final double thresholdMin = threshold;
  final double thresholdMax = threshold + smoothness;

  // Process pixels
  for (final pixel in rgbaImage) {
    final int r = pixel.r.toInt();
    final int g = pixel.g.toInt();
    final int b = pixel.b.toInt();

    // Calculate Euclidean distance in RGB space
    final double distance = math.sqrt(
      math.pow(r - bgR, 2) + math.pow(g - bgG, 2) + math.pow(b - bgB, 2),
    );

    if (distance < thresholdMin) {
      // Fully transparent
      pixel.a = 0;
    } else if (distance < thresholdMax && smoothness > 0) {
      // Semi-transparent gradient for antialiasing
      final double ratio = (distance - thresholdMin) / smoothness;
      final int originalAlpha = pixel.a.toInt();
      pixel.a = (originalAlpha * ratio).clamp(0, 255).round();
    }
  }

  // Re-encode to PNG to preserve transparency
  return Uint8List.fromList(img.encodePng(rgbaImage));
}
