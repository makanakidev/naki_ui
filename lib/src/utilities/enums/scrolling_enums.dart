part of 'index.dart';

/// The direction of scrolling.
enum ScrollDirection {
  /// Scroll along the horizontal ScrollDirection.
  horizontal,

  /// Scroll along the vertical ScrollDirection.
  vertical,
}

/// Determines the scrolling physics behavior.
enum ScrollPhysicsType {
  /// Standard browser scrolling behavior.
  adaptive('adaptive'),

  /// Prevents scrolling.
  neverScrollable('never_scrollable'),

  /// Allows scrolling beyond content bounds with bounce (iOS-like).
  bouncing('bouncing'),

  /// Clamps scrolling strictly to content bounds (Android-like).
  clamping('clamping'),

  /// Snaps scrolling to the nearest item.
  snapping('snapping')
  ;

  /// The CSS value representing the scrolling physics type.
  final String value;
  const ScrollPhysicsType(this.value);
}

/// Defines the alignment of items in a carousel view.
enum CarouselAlignment {
  /// Align items to the start of the scroll view.
  start,

  /// Center items within the scroll view.
  center,

  /// Align items to the end of the scroll view.
  end,
}

/// Alignment of content within a table row cell.
enum TableRowCellAlignment {
  /// Align cell content to the left edge.
  left,

  /// Align cell content to the right edge.
  right,

  /// Justify cell content.
  justify,

  /// Align cell content to the start edge.
  start,

  /// Align cell content to the end edge.
  end,

  /// Align cell content to the center edge.
  center,
}

/// Alignment for table header cells.
enum TableHeaderCellAlignment {
  /// Align cell content to the left edge.
  left,

  /// Align cell content to the right edge.
  right,

  /// Justify cell content.
  justify,

  /// Align cell content to the start edge.
  start,

  /// Align cell content to the end edge.
  end,

  /// Align cell content to the center edge.
  center,
}
