import 'package:flutter/material.dart';

/// A custom clipper to show either the left or right portion of a widget.
class _SplitClipper extends CustomClipper<Rect> {
  final double splitRatio;
  final bool clipLeft; // If true, keeps left side. If false, keeps right side.

  _SplitClipper({required this.splitRatio, required this.clipLeft});

  @override
  Rect getClip(Size size) {
    if (clipLeft) {
      return Rect.fromLTRB(0, 0, size.width * splitRatio, size.height);
    } else {
      return Rect.fromLTRB(size.width * splitRatio, 0, size.width, size.height);
    }
  }

  @override
  bool shouldReclip(covariant _SplitClipper oldClipper) {
    return oldClipper.splitRatio != splitRatio ||
        oldClipper.clipLeft != clipLeft;
  }
}

/// A widget that displays two overlapping children (typically original and processed images)
/// and allows the user to slide a divider horizontally to compare them.
class SplitSlider extends StatefulWidget {
  final Widget original;
  final Widget processed;
  final double aspectRatio;

  const SplitSlider({
    super.key,
    required this.original,
    required this.processed,
    required this.aspectRatio,
  });

  @override
  State<SplitSlider> createState() => _SplitSliderState();
}

class _SplitSliderState extends State<SplitSlider> {
  double _splitRatio = 0.5; // Starts in the middle
  bool _isHovering = false;
  bool _isDragging = false;

  void _handleDrag(DragUpdateDetails details, double width) {
    setState(() {
      _splitRatio = (_splitRatio + details.delta.dx / width).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInteractive = _isHovering || _isDragging;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the actual size of the comparison container based on aspect ratio
        final containerWidth = constraints.maxWidth;
        final containerHeight = containerWidth / widget.aspectRatio;

        // If the height is too large for the parent constraints, shrink to fit height
        double finalWidth = containerWidth;
        double finalHeight = containerHeight;
        if (containerHeight > constraints.maxHeight &&
            constraints.maxHeight > 0) {
          finalHeight = constraints.maxHeight;
          finalWidth = finalHeight * widget.aspectRatio;
        }

        return Center(
          child: SizedBox(
            width: finalWidth,
            height: finalHeight,
            child: GestureDetector(
              onHorizontalDragStart: (_) => setState(() => _isDragging = true),
              onHorizontalDragUpdate: (details) =>
                  _handleDrag(details, finalWidth),
              onHorizontalDragEnd: (_) => setState(() => _isDragging = false),
              onHorizontalDragCancel: () => setState(() => _isDragging = false),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. Original Image (Right side / Clipped Background)
                  Positioned.fill(
                    child: ClipRect(
                      clipper: _SplitClipper(
                        splitRatio: _splitRatio,
                        clipLeft: false,
                      ),
                      child: widget.original,
                    ),
                  ),

                  // 2. Processed Image (Left side / Clipped Foreground)
                  Positioned.fill(
                    child: ClipRect(
                      clipper: _SplitClipper(
                        splitRatio: _splitRatio,
                        clipLeft: true,
                      ),
                      child: widget.processed,
                    ),
                  ),

                  // 3. Slider Divider Line
                  Positioned(
                    left: finalWidth * _splitRatio - 1.5,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 3,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4. Slider Handle Button with Micro-animations
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOutCubic,
                    left: finalWidth * _splitRatio - (isInteractive ? 23 : 20),
                    top: finalHeight / 2 - (isInteractive ? 23 : 20),
                    width: isInteractive ? 46 : 40,
                    height: isInteractive ? 46 : 40,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.resizeLeftRight,
                      onEnter: (_) => setState(() => _isHovering = true),
                      onExit: (_) => setState(() => _isHovering = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isInteractive
                                ? theme.primaryColor
                                : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isInteractive
                                  ? theme.primaryColor.withValues(alpha: 0.4)
                                  : Colors.black.withAlpha(80),
                              blurRadius: isInteractive ? 14 : 8,
                              offset: Offset(0, isInteractive ? 4 : 2),
                            ),
                          ],
                        ),
                        child: RotatedBox(
                          quarterTurns: 1,
                          child: Icon(
                            Icons.unfold_more_rounded,
                            color: isInteractive
                                ? theme.primaryColor
                                : theme.primaryColor.withValues(alpha: 0.8),
                            size: isInteractive ? 26 : 24,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 5. Floating Labels (Original / Processed) that fade on interaction
                  Positioned(
                    top: 12,
                    left: 12,
                    child: AnimatedOpacity(
                      opacity: isInteractive ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'PROCESSED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 12,
                    right: 12,
                    child: AnimatedOpacity(
                      opacity: isInteractive ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'ORIGINAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
