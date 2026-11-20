part of 'index.dart';

/// Styling configuration for SegmentedInput component.
class SegmentedInputStyle {
  /// Width of each individual segment box.
  final Dim? segmentWidth;

  /// Height of each individual segment box.
  final Dim? segmentHeight;

  /// Gap/spacing between segment boxes.
  final Dim? gap;

  /// Border decoration of each segment.
  final BorderData? border;

  /// Radius of segment corners.
  final BorderRadiusData? borderRadius;

  /// Border color of segment when hovered.
  final Color? hoverBorderColor;

  /// Border color of segment when focused.
  final Color? focusBorderColor;

  /// Border color of segment when validation fails.
  final Color? errorBorderColor;

  /// Background color of empty segments.
  final Color? backgroundColor;

  /// Background color of filled segments.
  final Color? filledBackgroundColor;

  /// Typography style for the text/digits inside segments.
  final TextStyle? textStyle;

  /// Shape variant of the segments (box, underline, circle).
  final SegmentedInputShape shape;

  /// Margin around the segmented input wrapper.
  final EdgeInsets? margin;

  /// Padding around each segment box.
  final EdgeInsets? padding;

  /// Creates a [SegmentedInputStyle] instance.
  const SegmentedInputStyle({
    this.segmentWidth,
    this.segmentHeight,
    this.gap,
    this.border,
    this.borderRadius,
    this.hoverBorderColor,
    this.focusBorderColor,
    this.errorBorderColor,
    this.backgroundColor,
    this.filledBackgroundColor,
    this.textStyle,
    this.shape = SegmentedInputShape.box,
    this.margin,
    this.padding,
  });

  /// Creates a copy of this [SegmentedInputStyle]
  /// with the given fields replaced.
  SegmentedInputStyle copyWith({
    Dim? segmentWidth,
    Dim? segmentHeight,
    Dim? gap,
    BorderData? border,
    BorderRadiusData? borderRadius,
    Color? hoverBorderColor,
    Color? focusBorderColor,
    Color? errorBorderColor,
    Color? backgroundColor,
    Color? filledBackgroundColor,
    TextStyle? textStyle,
    SegmentedInputShape? shape,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) {
    return SegmentedInputStyle(
      segmentWidth: segmentWidth ?? this.segmentWidth,
      segmentHeight: segmentHeight ?? this.segmentHeight,
      gap: gap ?? this.gap,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      hoverBorderColor: hoverBorderColor ?? this.hoverBorderColor,
      focusBorderColor: focusBorderColor ?? this.focusBorderColor,
      errorBorderColor: errorBorderColor ?? this.errorBorderColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      filledBackgroundColor:
          filledBackgroundColor ?? this.filledBackgroundColor,
      textStyle: textStyle ?? this.textStyle,
      shape: shape ?? this.shape,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SegmentedInputStyle &&
          runtimeType == other.runtimeType &&
          segmentWidth == other.segmentWidth &&
          segmentHeight == other.segmentHeight &&
          gap == other.gap &&
          border == other.border &&
          borderRadius == other.borderRadius &&
          hoverBorderColor == other.hoverBorderColor &&
          focusBorderColor == other.focusBorderColor &&
          errorBorderColor == other.errorBorderColor &&
          backgroundColor == other.backgroundColor &&
          filledBackgroundColor == other.filledBackgroundColor &&
          textStyle == other.textStyle &&
          shape == other.shape &&
          margin == other.margin &&
          padding == other.padding;

  @override
  int get hashCode => Object.hashAll([
    segmentWidth,
    segmentHeight,
    gap,
    border,
    borderRadius,
    hoverBorderColor,
    focusBorderColor,
    errorBorderColor,
    backgroundColor,
    filledBackgroundColor,
    textStyle,
    shape,
    margin,
    padding,
  ]);
}
