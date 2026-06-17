import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:background_remover/core/image_processor.dart';
import 'checkerboard.dart';
import 'split_slider.dart';

/// The central workspace area displaying original and/or processed images, with supporting comparison sliders.
class PreviewArea extends StatelessWidget {
  final Uint8List originalBytes;
  final Uint8List? processedBytes;
  final DecodedImage? decodedImg;
  final double imageWidth;
  final double imageHeight;
  final String viewMode;
  final String previewBackground;
  final bool isEyedropperActive;
  final bool isProcessing;
  final String loadingStatus;
  final void Function(Offset localOffset, Size containerSize) onPickColorAt;

  const PreviewArea({
    super.key,
    required this.originalBytes,
    required this.processedBytes,
    required this.decodedImg,
    required this.imageWidth,
    required this.imageHeight,
    required this.viewMode,
    required this.previewBackground,
    required this.isEyedropperActive,
    required this.isProcessing,
    required this.loadingStatus,
    required this.onPickColorAt,
  });

  @override
  Widget build(BuildContext context) {
    final imageRatio = (imageWidth > 0 && imageHeight > 0)
        ? (imageWidth / imageHeight)
        : 1.0;

    return Stack(
      children: [
        // Checkerboard / Solid color backgrounds
        Positioned.fill(
          child: previewBackground == 'transparent'
              ? const Checkerboard()
              : Container(
                  color: previewBackground == 'white'
                      ? Colors.white
                      : Colors.black,
                ),
        ),

        // Image representation
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final Size containerSize = Size(
                  constraints.maxWidth,
                  constraints.maxHeight,
                );

                final Widget originalImgWidget = Image.memory(
                  originalBytes,
                  fit: BoxFit.contain,
                );

                final Widget processedImgWidget = processedBytes != null
                    ? Image.memory(processedBytes!, fit: BoxFit.contain)
                    : const Center(child: CircularProgressIndicator());

                return MouseRegion(
                  cursor: isEyedropperActive
                      ? SystemMouseCursors.precise
                      : MouseCursor.defer,
                  child: GestureDetector(
                    onTapUp: (details) {
                      if (isEyedropperActive) {
                        onPickColorAt(details.localPosition, containerSize);
                      }
                    },
                    child: Builder(
                      builder: (context) {
                        if (isEyedropperActive) {
                          // Always show original image during eyedropper selection
                          return Center(
                            child: AspectRatio(
                              aspectRatio: imageRatio,
                              child: Stack(
                                children: [
                                  Positioned.fill(child: originalImgWidget),
                                  // Eyedropper instruction overlay
                                  Positioned.fill(
                                    child: Container(
                                      color: Colors.black.withAlpha(100),
                                      child: const Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.colorize,
                                              size: 40,
                                              color: Colors.white,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Tap anywhere to pick background color',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                shadows: [
                                                  Shadow(
                                                    blurRadius: 4,
                                                    color: Colors.black,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // Normal View Modes
                        switch (viewMode) {
                          case 'original':
                            return Center(
                              child: AspectRatio(
                                aspectRatio: imageRatio,
                                child: originalImgWidget,
                              ),
                            );
                          case 'processed':
                            return Center(
                              child: AspectRatio(
                                aspectRatio: imageRatio,
                                child: processedImgWidget,
                              ),
                            );
                          case 'split':
                          default:
                            return SplitSlider(
                              original: originalImgWidget,
                              processed: processedImgWidget,
                              aspectRatio: imageRatio,
                            );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Indicator when processing
        if (isProcessing)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(200),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    loadingStatus.isNotEmpty ? loadingStatus : 'Processing...',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
