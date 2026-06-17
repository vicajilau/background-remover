import 'package:flutter/material.dart';
import '../theme.dart';

/// The initial screen content inviting the user to pick or drop an image.
class UploadPrompt extends StatelessWidget {
  final VoidCallback onPickImage;

  const UploadPrompt({super.key, required this.onPickImage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onPickImage,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480, maxHeight: 320),
              decoration: BoxDecoration(
                color: AppTheme.surface.withAlpha(200),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.primary.withAlpha(100),
                  width: 2,
                  style: BorderStyle.solid,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withAlpha(25),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24.0,
                  horizontal: 24.0,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.image_search_rounded,
                          size: 48,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Load Image to Remove Background',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Supports PNG, JPG, JPEG, and WebP',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: onPickImage,
                        icon: const Icon(Icons.file_upload),
                        label: const Text('Choose File'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
