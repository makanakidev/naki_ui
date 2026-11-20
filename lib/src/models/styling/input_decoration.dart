part of 'index.dart';

/// The border, label, hint, and helper text styles used to
/// decorate a Naki input component.
class InputDecoration {
  /// Style of the input value.
  final TextStyle? inputStyle;

  /// Label text displayed above the component.
  final String? labelText;

  /// The typography style to use for [labelText].
  final TextStyle? labelStyle;

  /// Hint text displayed below the component.
  final String? helperText;

  /// Typography style to use for [helperText].
  final TextStyle? helperStyle;

  /// The placeholder text displayed in the component,
  /// when input value is empty.
  final String? placeholderText;

  /// Color of the placeholder text.
  final Color? placeholderColor;

  /// Border decoration of the component.
  final BorderData? border;

  /// Color of the border when hovered.
  final Color? hoverBorderColor;

  /// Color of the border when focused.
  final Color? focusBorderColor;

  /// Style of the error message
  /// (only font size and color applicable).
  final TextStyle? errorStyle;

  /// Padding of the input component.
  final EdgeInsets? padding;

  /// Margin of the input component.
  final EdgeInsets? margin;

  /// Creates an [InputDecoration] instance.
  const InputDecoration({
    this.labelText,
    this.labelStyle,
    this.helperText,
    this.helperStyle,
    this.placeholderText,
    this.placeholderColor,
    this.border,
    this.hoverBorderColor,
    this.focusBorderColor,
    this.errorStyle,
    this.inputStyle,
    this.padding,
    this.margin,
  });

  InputDecoration copyWith({
    String? labelText,
    TextStyle? labelStyle,
    String? helperText,
    TextStyle? helperStyle,
    String? placeholderText,
    Color? placeholderColor,
    BorderData? border,
    Color? hoverBorderColor,
    Color? focusBorderColor,
    TextStyle? errorStyle,
    TextStyle? inputStyle,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return InputDecoration(
      labelText: labelText ?? this.labelText,
      labelStyle: labelStyle ?? this.labelStyle,
      helperText: helperText ?? this.helperText,
      helperStyle: helperStyle ?? this.helperStyle,
      placeholderText: placeholderText ?? this.placeholderText,
      placeholderColor: placeholderColor ?? this.placeholderColor,
      border: border ?? this.border,
      hoverBorderColor: hoverBorderColor ?? this.hoverBorderColor,
      focusBorderColor: focusBorderColor ?? this.focusBorderColor,
      errorStyle: errorStyle ?? this.errorStyle,
      inputStyle: inputStyle ?? this.inputStyle,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputDecoration &&
          runtimeType == other.runtimeType &&
          inputStyle == other.inputStyle &&
          labelText == other.labelText &&
          labelStyle == other.labelStyle &&
          helperText == other.helperText &&
          helperStyle == other.helperStyle &&
          placeholderText == other.placeholderText &&
          placeholderColor == other.placeholderColor &&
          border == other.border &&
          hoverBorderColor == other.hoverBorderColor &&
          focusBorderColor == other.focusBorderColor &&
          errorStyle == other.errorStyle &&
          padding == other.padding &&
          margin == other.margin;

  @override
  int get hashCode => Object.hashAll([
    inputStyle,
    labelText,
    labelStyle,
    helperText,
    helperStyle,
    placeholderText,
    placeholderColor,
    border,
    hoverBorderColor,
    focusBorderColor,
    errorStyle,
    padding,
    margin,
  ]);
}
