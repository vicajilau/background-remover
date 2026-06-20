/// Represents the visual mode used to display and compare images.
enum ViewMode {
  /// Side-by-side comparison slider showing both original and processed images.
  split,

  /// Display only the original input image.
  original,

  /// Display only the processed image with its background removed.
  processed,
}

/// Represents the background style or color options for the image preview area.
enum PreviewBackground {
  /// Transparent background displayed as a checkerboard grid.
  transparent,

  /// Solid white background.
  white,

  /// Solid black background.
  black,

  /// Solid red chroma key background.
  red,

  /// Solid green chroma key background.
  green,

  /// Solid blue chroma key background.
  blue,

  /// Custom background color selected by the user.
  custom,
}
