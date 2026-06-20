import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:background_remover/l10n/app_localizations.dart';
import '../../core/enums.dart';
import '../theme.dart';
import 'custom_color_picker_dialog.dart';

/// Sidebar or bottom panel for image adjustments and settings controls.
class ControlsPanel extends StatelessWidget {
  final String? fileName;
  final double imageWidth;
  final double imageHeight;
  final ViewMode viewMode;
  final ValueChanged<ViewMode> onViewModeChanged;
  final Color selectedColor;
  final bool isEyedropperActive;
  final VoidCallback onToggleEyedropper;
  final double threshold;
  final ValueChanged<double> onThresholdChanged;
  final ValueChanged<double> onThresholdChangeEnd;
  final double smoothness;
  final ValueChanged<double> onSmoothnessChanged;
  final ValueChanged<double> onSmoothnessChangeEnd;
  final PreviewBackground previewBackground;
  final ValueChanged<PreviewBackground> onBackgroundChanged;
  final Color customPreviewColor;
  final ValueChanged<Color> onCustomColorChanged;
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
    required this.customPreviewColor,
    required this.onCustomColorChanged,
    required this.processedBytes,
    required this.onExport,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
              l10n.resolution(imageWidth.toInt(), imageHeight.toInt()),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // View Mode Toggle Tabs
          Text(
            l10n.viewMode,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<ViewMode>(
            segments: [
              ButtonSegment(
                value: ViewMode.split,
                label: Text(l10n.compare),
                icon: const Icon(Icons.compare_arrows_rounded),
              ),
              ButtonSegment(
                value: ViewMode.processed,
                label: Text(l10n.result),
                icon: const Icon(Icons.done_all_rounded),
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
          Text(
            l10n.colorToRemove,
            style: const TextStyle(
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
                      Text(
                        l10n.targetBgColor,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Eyedropper Button
                IconButton(
                  tooltip: l10n.eyedropperTooltip,
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
          Text(
            l10n.adjustments,
            style: const TextStyle(
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
              Text(l10n.tolerance),
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
              Text(l10n.smoothness),
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
          Text(
            l10n.bgCheck,
            style: const TextStyle(
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
                PreviewBackground.transparent,
                Icons.grid_on_rounded,
                l10n.grid,
              ),
              const SizedBox(width: 8),
              _buildBackgroundOption(
                PreviewBackground.white,
                Icons.wb_sunny_rounded,
                l10n.light,
              ),
              const SizedBox(width: 8),
              _buildBackgroundOption(
                PreviewBackground.black,
                Icons.nightlight_round,
                l10n.dark,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.chromaKey,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChromaCircle(
                context,
                PreviewBackground.red,
                const Color(0xFFEF4444),
                l10n.red,
              ),
              _buildChromaCircle(
                context,
                PreviewBackground.green,
                const Color(0xFF22C55E),
                l10n.green,
              ),
              _buildChromaCircle(
                context,
                PreviewBackground.blue,
                const Color(0xFF3B82F6),
                l10n.blue,
              ),
              _buildChromaCircle(
                context,
                PreviewBackground.white,
                Colors.white,
                l10n.white,
              ),
              _buildChromaCircle(
                context,
                PreviewBackground.black,
                Colors.black,
                l10n.black,
              ),
              _buildCustomChromaCircle(context),
            ],
          ),
          const SizedBox(height: 30),

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
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.download_rounded),
                    const SizedBox(width: 10),
                    Text(l10n.savePng),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onPickImage,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_open),
                  const SizedBox(width: 10),
                  Text(l10n.openImage),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundOption(
    PreviewBackground value,
    IconData icon,
    String label,
  ) {
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

  Widget _buildChromaCircle(
    BuildContext context,
    PreviewBackground value,
    Color color,
    String tooltip,
  ) {
    final bool isSelected = previewBackground == value;

    return Tooltip(
      message: AppLocalizations.of(context).previewOnBg(tooltip),
      child: GestureDetector(
        onTap: () => onBackgroundChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.white : AppTheme.surfaceLight,
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: color.withAlpha(50),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: isSelected
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
              : null,
        ),
      ),
    );
  }

  Widget _buildCustomChromaCircle(BuildContext context) {
    final bool isSelected = previewBackground == PreviewBackground.custom;

    return Tooltip(
      message: AppLocalizations.of(context).customBgTooltip,
      child: GestureDetector(
        onTap: () => _openColorPicker(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isSelected ? customPreviewColor : AppTheme.surfaceDark,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.white : AppTheme.surfaceLight,
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: customPreviewColor.withAlpha(50),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Icon(
            Icons.palette_rounded,
            color: isSelected
                ? (customPreviewColor.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white)
                : AppTheme.textSecondary,
            size: 14,
          ),
        ),
      ),
    );
  }

  Future<void> _openColorPicker(BuildContext context) async {
    final Color? pickedColor = await showDialog<Color>(
      context: context,
      builder: (context) =>
          CustomColorPickerDialog(initialColor: customPreviewColor),
    );
    if (pickedColor != null) {
      onCustomColorChanged(pickedColor);
      onBackgroundChanged(PreviewBackground.custom);
    }
  }
}
