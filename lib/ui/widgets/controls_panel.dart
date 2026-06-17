import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme.dart';

/// Sidebar or bottom panel for image adjustments and settings controls.
class ControlsPanel extends StatelessWidget {
  final String? fileName;
  final double imageWidth;
  final double imageHeight;
  final String viewMode;
  final ValueChanged<String> onViewModeChanged;
  final Color selectedColor;
  final bool isEyedropperActive;
  final VoidCallback onToggleEyedropper;
  final double threshold;
  final ValueChanged<double> onThresholdChanged;
  final ValueChanged<double> onThresholdChangeEnd;
  final double smoothness;
  final ValueChanged<double> onSmoothnessChanged;
  final ValueChanged<double> onSmoothnessChangeEnd;
  final String previewBackground;
  final ValueChanged<String> onBackgroundChanged;
  final Uint8List? processedBytes;
  final VoidCallback onExport;
  final VoidCallback onPickImage;

  const ControlsPanel({
    super.key,
    required this.fileName,
    required this.imageWidth,
    required this.imageHeight,
    required this.viewMode,
    required this.onViewModeChanged,
    required this.selectedColor,
    required this.isEyedropperActive,
    required this.onToggleEyedropper,
    required this.threshold,
    required this.onThresholdChanged,
    required this.onThresholdChangeEnd,
    required this.smoothness,
    required this.onSmoothnessChanged,
    required this.onSmoothnessChangeEnd,
    required this.previewBackground,
    required this.onBackgroundChanged,
    required this.processedBytes,
    required this.onExport,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File Name & Details
          if (fileName != null) ...[
            Text(
              fileName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Resolution: ${imageWidth.toInt()} x ${imageHeight.toInt()}',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // View Mode Toggle Tabs
          const Text(
            'VIEW MODE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'split',
                label: Text('Compare'),
                icon: Icon(Icons.compare_arrows_rounded),
              ),
              ButtonSegment(
                value: 'processed',
                label: Text('Result'),
                icon: Icon(Icons.done_all_rounded),
              ),
            ],
            selected: {viewMode},
            onSelectionChanged: (selection) {
              onViewModeChanged(selection.first);
            },
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
          ),
          const SizedBox(height: 24),

          // Color Picker Section
          const Text(
            'COLOR TO REMOVE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Color Display Box
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selectedColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.surfaceLight,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: selectedColor.withAlpha(50),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RGB(${(selectedColor.r * 255).round()}, ${(selectedColor.g * 255).round()}, ${(selectedColor.b * 255).round()})',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Target Background Color',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Eyedropper Button
                IconButton(
                  tooltip: 'Eyedropper tool',
                  icon: Icon(
                    Icons.colorize_rounded,
                    color: isEyedropperActive ? AppTheme.primary : Colors.white,
                  ),
                  onPressed: onToggleEyedropper,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Parameters Sliders
          const Text(
            'ADJUSTMENTS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 16),

          // Tolerance Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tolerance'),
              Text(
                threshold.toInt().toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: threshold,
            min: 0.0,
            max: 200.0,
            onChanged: onThresholdChanged,
            onChangeEnd: onThresholdChangeEnd,
          ),
          const SizedBox(height: 16),

          // Smoothness Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Smoothness'),
              Text(
                smoothness.toInt().toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondary,
                ),
              ),
            ],
          ),
          Slider(
            value: smoothness,
            min: 0.0,
            max: 150.0,
            onChanged: onSmoothnessChanged,
            onChangeEnd: onSmoothnessChangeEnd,
          ),
          const SizedBox(height: 24),

          // Background Previews
          const Text(
            'BACKGROUND CHECK',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildBackgroundOption(
                'transparent',
                Icons.grid_on_rounded,
                'Grid',
              ),
              const SizedBox(width: 8),
              _buildBackgroundOption('white', Icons.wb_sunny_rounded, 'Light'),
              const SizedBox(width: 8),
              _buildBackgroundOption('black', Icons.nightlight_round, 'Dark'),
            ],
          ),
          const SizedBox(height: 36),

          // Action Buttons
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: processedBytes != null
                  ? AppTheme.primaryGradient
                  : null,
              color: processedBytes == null ? AppTheme.surfaceLight : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: processedBytes != null ? onExport : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                minimumSize: const Size.fromHeight(56),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_rounded),
                  SizedBox(width: 10),
                  Text('Save Transparent PNG'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onPickImage,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open),
                SizedBox(width: 10),
                Text('Open Another Image'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundOption(String value, IconData icon, String label) {
    final bool isSelected = previewBackground == value;

    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected
              ? AppTheme.primary.withAlpha(30)
              : Colors.transparent,
          side: BorderSide(
            color: isSelected ? AppTheme.primary : AppTheme.surfaceLight,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () => onBackgroundChanged(value),
        child: Column(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
