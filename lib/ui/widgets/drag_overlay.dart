import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../theme.dart';

/// A premium glassmorphic overlay displayed when files are dragged over the window.
class DragOverlay extends StatelessWidget {
  const DragOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: AppTheme.surfaceDark.withAlpha(180),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppTheme.surface.withAlpha(120),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.primary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withAlpha(40),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.file_upload_rounded,
                      size: 64,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Drop your image here',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Supports PNG, JPG, JPEG, and WebP formats',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
