part of 'index.dart';

/// Scroll bar configuration.
class ScrollBarConfiguration {
  /// Color of the scroll bar thumb.
  final Color thumbColor;

  /// Color of the scroll bar track.
  final Color trackColor;

  /// Color of the scroll bar thumb when hovered.
  final Color? hoverColor;

  /// Border radius of the scroll bar thumb in pixels.
  final double? radius;

  /// Width of the scroll bar thumb in pixels (for vertical scrollbar).
  final double width;

  /// Height of the scroll bar thumb in pixels (for horizontal scrollbar).
  final double height;

  const ScrollBarConfiguration({
    required this.thumbColor,
    required this.trackColor,
    this.width = 4,
    this.height = 4,
    this.hoverColor,
    this.radius,
  });
}
