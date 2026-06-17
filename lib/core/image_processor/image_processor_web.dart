import 'dart:async';
import 'dart:math' as math;
import 'dart:js_interop';
import 'dart:typed_data';
import 'dart:ui';
import 'package:web/web.dart' as web;
import 'image_processor.dart';

class WebDecodedImage implements DecodedImage {
  final int w;
  final int h;
  final Uint8ClampedList pixelData;

  WebDecodedImage({required this.w, required this.h, required this.pixelData});

  @override
  int get width => w;

  @override
  int get height => h;

  @override
  Color getPixelColor(int x, int y) {
    if (x < 0 || x >= w || y < 0 || y >= h) {
      return const Color(0x00000000);
    }
    final index = (y * w + x) * 4;
    return Color.fromARGB(
      255,
      pixelData[index],
      pixelData[index + 1],
      pixelData[index + 2],
    );
  }
}

Future<web.HTMLImageElement> _loadImageEl(Uint8List bytes) async {
  final completer = Completer<web.HTMLImageElement>();
  final jsArray = bytes.toJS;
  final blob = web.Blob([jsArray].toJS);
  final url = web.URL.createObjectURL(blob);

  final imgEl = web.document.createElement('img') as web.HTMLImageElement;
  imgEl.src = url;

  JSFunction? loadCallback;
  JSFunction? errorCallback;

  loadCallback = (web.Event event) {
    completer.complete(imgEl);
  }.toJS;

  errorCallback = (web.Event event) {
    completer.completeError(Exception('Failed to load image in browser'));
  }.toJS;

  imgEl.addEventListener('load', loadCallback);
  imgEl.addEventListener('error', errorCallback);

  try {
    await completer.future;
    return imgEl;
  } finally {
    imgEl.removeEventListener('load', loadCallback);
    imgEl.removeEventListener('error', errorCallback);
    web.URL.revokeObjectURL(url);
  }
}

Future<DecodedImage> decodeImageImpl(Uint8List bytes) async {
  final imgEl = await _loadImageEl(bytes);
  final w = imgEl.naturalWidth;
  final h = imgEl.naturalHeight;

  final canvas = web.document.createElement('canvas') as web.HTMLCanvasElement;
  canvas.width = w;
  canvas.height = h;

  final ctx = canvas.getContext('2d') as web.CanvasRenderingContext2D;
  ctx.drawImage(imgEl, 0, 0);

  final imageData = ctx.getImageData(0, 0, w, h);
  final pixelData = imageData.data.toDart;

  return WebDecodedImage(w: w, h: h, pixelData: pixelData);
}

Future<Uint8List> removeBackgroundImpl({
  required Uint8List bytes,
  required Color color,
  required double threshold,
  required double smoothness,
}) async {
  final imgEl = await _loadImageEl(bytes);
  final w = imgEl.naturalWidth;
  final h = imgEl.naturalHeight;

  final canvas = web.document.createElement('canvas') as web.HTMLCanvasElement;
  canvas.width = w;
  canvas.height = h;

  final ctx = canvas.getContext('2d') as web.CanvasRenderingContext2D;
  ctx.drawImage(imgEl, 0, 0);

  final imageData = ctx.getImageData(0, 0, w, h);
  final data = imageData.data.toDart; // Uint8ClampedList

  final bgR = (color.r * 255).round().clamp(0, 255);
  final bgG = (color.g * 255).round().clamp(0, 255);
  final bgB = (color.b * 255).round().clamp(0, 255);

  final double thresholdMin = threshold;
  final double thresholdMax = threshold + smoothness;

  final int len = data.length;
  for (int i = 0; i < len; i += 4) {
    final int r = data[i];
    final int g = data[i + 1];
    final int b = data[i + 2];

    final double diffR = (r - bgR).toDouble();
    final double diffG = (g - bgG).toDouble();
    final double diffB = (b - bgB).toDouble();
    final double distance = math.sqrt(
      diffR * diffR + diffG * diffG + diffB * diffB,
    );

    if (distance < thresholdMin) {
      data[i + 3] = 0;
    } else if (distance < thresholdMax && smoothness > 0) {
      final double ratio = (distance - thresholdMin) / smoothness;
      final int originalAlpha = data[i + 3];
      data[i + 3] = (originalAlpha * ratio).clamp(0, 255).round();
    }
  }

  ctx.putImageData(imageData, 0, 0);

  // Convert canvas back to PNG bytes
  final blobCompleter = Completer<web.Blob>();

  final toBlobCallback = (web.Blob? b) {
    if (b != null) {
      blobCompleter.complete(b);
    } else {
      blobCompleter.completeError(
        Exception('Failed to convert canvas to blob'),
      );
    }
  }.toJS;

  canvas.toBlob(toBlobCallback, 'image/png');

  final outBlob = await blobCompleter.future;

  // Read blob to Uint8List
  final reader = web.FileReader();
  final readerCompleter = Completer<void>();

  final loadEndCallback = (web.Event event) {
    readerCompleter.complete();
  }.toJS;

  reader.addEventListener('loadend', loadEndCallback);
  reader.readAsArrayBuffer(outBlob);

  try {
    await readerCompleter.future;
    final result = reader.result;
    if (result == null) {
      throw Exception('FileReader result was null');
    }
    final arrayBuffer = result as JSArrayBuffer;
    return arrayBuffer.toDart.asUint8List();
  } finally {
    reader.removeEventListener('loadend', loadEndCallback);
  }
}
