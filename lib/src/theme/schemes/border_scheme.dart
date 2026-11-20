part of '../theme.dart';

/// Represents customizable global border color and width variables.
class BorderScheme {
  /// Default border color.
  final Color? borderColor;

  /// Default border width.
  final Dim? borderWidth;

  /// Field hover border width.
  final Dim? fieldHoverBorderWidth;

  /// Focus border width.
  final Dim? focusBorderWidth;

  /// Error border width.
  final Dim? errorBorderWidth;

  const BorderScheme({
    this.borderColor,
    this.borderWidth,
    this.fieldHoverBorderWidth,
    this.focusBorderWidth,
    this.errorBorderWidth,
  });

  BorderScheme copyWith({
    Color? borderColor,
    Dim? borderWidth,
    Dim? fieldHoverBorderWidth,
    Dim? focusBorderWidth,
    Dim? errorBorderWidth,
  }) {
    return BorderScheme(
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      fieldHoverBorderWidth:
          fieldHoverBorderWidth ?? this.fieldHoverBorderWidth,
      focusBorderWidth: focusBorderWidth ?? this.focusBorderWidth,
      errorBorderWidth: errorBorderWidth ?? this.errorBorderWidth,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BorderScheme &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.fieldHoverBorderWidth == fieldHoverBorderWidth &&
        other.focusBorderWidth == focusBorderWidth &&
        other.errorBorderWidth == errorBorderWidth;
  }

  @override
  int get hashCode => Object.hash(
    borderColor,
    borderWidth,
    fieldHoverBorderWidth,
    focusBorderWidth,
    errorBorderWidth,
  );
}
