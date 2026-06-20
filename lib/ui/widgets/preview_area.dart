import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:background_remover/core/image_processor.dart';
import 'package:background_remover/l10n/app_localizations.dart';
import '../../core/enums.dart';
import 'checkerboard.dart';
import 'split_slider.dart';

/// The central workspace area displaying original and/or processed images, with zoom, pan, and comparison support.
class PreviewArea extends StatefulWidget {
  final Uint8List originalBytes;
  final Uint8List? processedBytes;
  final DecodedImage? decodedImg;
  final double imageWidth;
  final double imageHeight;
  final ViewMode viewMode;
  final PreviewBackground previewBackground;
  final Color customPreviewColor;
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
    required this.customPreviewColor,
    required this.isEyedropperActive,
    required this.isProcessing,
    required this.loadingStatus,
    required this.onPickColorAt,
  });

  @override
  State<PreviewArea> createState() => _PreviewAreaState();
}

class _PreviewAreaState extends State<PreviewArea>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _zoomAnimation;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _transformationController.addListener(_onTransformationChanged);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    // Use a small epsilon to avoid float inaccuracies triggering zoom state
    final isZoomed = scale > 1.05;
    if (isZoomed != _isZoomed) {
      setState(() {
        _isZoomed = isZoomed;
      });
    }
  }

  @override
  void didUpdateWidget(PreviewArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewMode != widget.viewMode ||
        oldWidget.originalBytes != widget.originalBytes) {
      _resetZoom();
    }
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  void _handleDoubleTap(Offset position) {
    final double currentScale = _transformationController.value
        .getMaxScaleOnAxis();
    final Matrix4 endMatrix;

    if (currentScale > 1.1) {
      endMatrix = Matrix4.identity();
    } else {
      // Zoom in to 3.0 centered on the double-tap position
      const double targetScale = 3.0;
      final double x = -position.dx * (targetScale - 1.0);
      final double y = -position.dy * (targetScale - 1.0);

      final translation = Matrix4.translationValues(x, y, 0.0);
      final scale = Matrix4.diagonal3Values(targetScale, targetScale, 1.0);
      endMatrix = translation * scale;
    }

    _zoomAnimation =
        Matrix4Tween(
          begin: _transformationController.value,
          end: endMatrix,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOutCubic,
          ),
        );

    _animationController.addListener(_onZoomAnimationUpdate);
    _animationController.forward(from: 0).then((_) {
      _animationController.removeListener(_onZoomAnimationUpdate);
    });
  }

  void _onZoomAnimationUpdate() {
    if (_zoomAnimation != null) {
      _transformationController.value = _zoomAnimation!.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageRatio = (widget.imageWidth > 0 && widget.imageHeight > 0)
        ? (widget.imageWidth / widget.imageHeight)
        : 1.0;

    return ClipRect(
      child: Stack(
        children: [
          // Checkerboard / Solid color backgrounds
          Positioned.fill(
            child: widget.previewBackground == PreviewBackground.transparent
                ? const Checkerboard()
                : Container(
                    color: switch (widget.previewBackground) {
                      PreviewBackground.white => Colors.white,
                      PreviewBackground.black => Colors.black,
                      PreviewBackground.red => const Color(
                        0xFFEF4444,
                      ), // Tailwind Red 500
                      PreviewBackground.green => const Color(
                        0xFF22C55E,
                      ), // Tailwind Green 500
                      PreviewBackground.blue => const Color(
                        0xFF3B82F6,
                      ), // Tailwind Blue 500
                      PreviewBackground.custom => widget.customPreviewColor,
                      _ => Colors.transparent,
                    },
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
                    widget.originalBytes,
                    fit: BoxFit.contain,
                  );

                  final Widget processedImgWidget =
                      widget.processedBytes != null
                      ? Image.memory(
                          widget.processedBytes!,
                          fit: BoxFit.contain,
                        )
                      : const Center(child: CircularProgressIndicator());

                  return MouseRegion(
                    cursor: widget.isEyedropperActive
                        ? SystemMouseCursors.precise
                        : MouseCursor.defer,
                    child: GestureDetector(
                      onTapUp: (details) {
                        if (widget.isEyedropperActive) {
                          widget.onPickColorAt(
                            details.localPosition,
                            containerSize,
                          );
                        }
                      },
                      child: Builder(
                        builder: (context) {
                          if (widget.isEyedropperActive) {
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
                                        color: Colors.black.withValues(
                                          alpha: 0.4,
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.colorize,
                                                size: 40,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                AppLocalizations.of(
                                                  context,
                                                ).tapToPickColor,
                                                style: const TextStyle(
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
                          switch (widget.viewMode) {
                            case ViewMode.original:
                              return Center(
                                child: AspectRatio(
                                  aspectRatio: imageRatio,
                                  child: GestureDetector(
                                    onDoubleTapDown: (details) =>
                                        _handleDoubleTap(details.localPosition),
                                    child: InteractiveViewer(
                                      transformationController:
                                          _transformationController,
                                      clipBehavior: Clip.none,
                                      maxScale: 8.0,
                                      child: originalImgWidget,
                                    ),
                                  ),
                                ),
                              );
                            case ViewMode.processed:
                              return Center(
                                child: AspectRatio(
                                  aspectRatio: imageRatio,
                                  child: GestureDetector(
                                    onDoubleTapDown: (details) =>
                                        _handleDoubleTap(details.localPosition),
                                    child: InteractiveViewer(
                                      transformationController:
                                          _transformationController,
                                      clipBehavior: Clip.none,
                                      maxScale: 8.0,
                                      child: processedImgWidget,
                                    ),
                                  ),
                                ),
                              );
                            case ViewMode.split:
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

          // Zoom Instruction Tooltip (Fades out when zoomed or during split/eyedropper modes)
          if (widget.viewMode != ViewMode.split &&
              !widget.isEyedropperActive &&
              widget.processedBytes != null)
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _isZoomed ? 0.0 : 0.7,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          theme.platform == TargetPlatform.iOS ||
                                  theme.platform == TargetPlatform.android
                              ? AppLocalizations.of(context).zoomTooltipMobile
                              : AppLocalizations.of(context).zoomTooltipDesktop,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Indicator when processing
          if (widget.isProcessing)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
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
                      widget.loadingStatus.isNotEmpty
                          ? widget.loadingStatus
                          : AppLocalizations.of(context).processing,
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
      ),
    );
  }
}
