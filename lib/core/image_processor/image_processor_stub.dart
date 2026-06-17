import 'dart:typed_data';
import 'dart:ui';
import 'image_processor.dart';

Future<DecodedImage> decodeImageImpl(Uint8List bytes) {
  throw UnsupportedError('decodeImageImpl is not supported on this platform');
}

Future<Uint8List> removeBackgroundImpl({
  required Uint8List bytes,
  required Color color,
  required double threshold,
  required double smoothness,
}) {
  throw UnsupportedError(
    'removeBackgroundImpl is not supported on this platform',
  );
}
