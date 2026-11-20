part of '../theme.dart';

// /////////////////////////////////////////////////////////////////////////////
// NAKI THEME CONFIG (USER MODIFIABLE)
// /////////////////////////////////////////////////////////////////////////////

/// Normalizes a list of font family names by adding quotes to font names that contain spaces.
String _normaliseFontFamily(List<String> fonts) {
  return fonts
      .map(
        (f) => f.contains(' ') && !f.startsWith('"') && !f.startsWith("'")
            ? '"$f"'
            : f,
      )
      .join(', ');
}

/// Represents customizable base and semantic color variables.
class ColorSeed {
  /// Primary color.
  final Color? primary;

  /// Secondary color.
  final Color? secondary;

  /// Accent color.
  final Color? accent;

  /// Accent green color.
  final Color? green;

  /// Accent yellow color.
  final Color? yellow;

  /// Accent red color.
  final Color? red;

  /// Base text color.
  final Color? baseTextColor;

  /// Default text placeholder color.
  final Color? placeholderColor;

  /// Muted background/foreground color.
  final Color? mutedColor;

  /// Subtitle or secondary text color.
  final Color? subtitleColor;

  /// Selected item color for dropdowns and list items.
  final Color? selectedItemColor;

  /// Selected text background color.
  final Color? selectedTextBackgroundColor;

  /// Selected text color.
  final Color? selectedTextColor;

  /// Selected item background color for dropdown items.
  final Color? selectedItemBackgroundColor;

  /// Root background color.
  final Color? backgroundColor;

  /// Error state color.
  final Color? errorColor;

  /// Success state color.
  final Color? successColor;

  /// Warning state color.
  final Color? warningColor;

  /// Info state color.
  final Color? infoColor;

  /// Weak background color for error callouts.
  final Color? errorWeakColor;

  /// Weak background color for success callouts.
  final Color? successWeakColor;

  /// Weak background color for warning callouts.
  final Color? warningWeakColor;

  /// Weak background color for info callouts.
  final Color? infoWeakColor;

  /// Secondary surface background color variation.
  final Color? surfaceVariantColor;

  /// Muted background color for container surfaces.
  final Color? surfaceMutedColor;

  /// Border color for focused components.
  final Color? focusBorderColor;

  /// Hover color for components.
  final Color? hoverColor;

  /// Background color for disabled components.
  final Color? disabledBackgroundColor;

  /// Color for disabled components.
  final Color? disabledColor;

  const ColorSeed({
    this.primary,
    this.secondary,
    this.accent,
    this.green,
    this.yellow,
    this.red,
    this.baseTextColor,
    this.placeholderColor,
    this.mutedColor,
    this.subtitleColor,
    this.selectedItemColor,
    this.selectedTextBackgroundColor,
    this.selectedTextColor,
    this.selectedItemBackgroundColor,
    this.backgroundColor,
    this.errorColor,
    this.successColor,
    this.warningColor,
    this.infoColor,
    this.errorWeakColor,
    this.successWeakColor,
    this.warningWeakColor,
    this.infoWeakColor,
    this.surfaceVariantColor,
    this.surfaceMutedColor,
    this.focusBorderColor,
    this.hoverColor,
    this.disabledBackgroundColor,
    this.disabledColor,
  });

  ColorSeed copyWith({
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? green,
    Color? yellow,
    Color? red,
    Color? baseTextColor,
    Color? placeholderColor,
    Color? mutedColor,
    Color? subtitleColor,
    Color? selectedItemColor,
    Color? selectedTextBackgroundColor,
    Color? selectedTextColor,
    Color? selectedItemBackgroundColor,
    Color? backgroundColor,
    Color? errorColor,
    Color? successColor,
    Color? warningColor,
    Color? infoColor,
    Color? errorWeakColor,
    Color? successWeakColor,
    Color? warningWeakColor,
    Color? infoWeakColor,
    Color? surfaceVariantColor,
    Color? surfaceMutedColor,
    Color? focusBorderColor,
    Color? hoverColor,
    Color? disabledBackgroundColor,
    Color? disabledColor,
  }) {
    return ColorSeed(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      green: green ?? this.green,
      yellow: yellow ?? this.yellow,
      red: red ?? this.red,
      baseTextColor: baseTextColor ?? this.baseTextColor,
      placeholderColor: placeholderColor ?? this.placeholderColor,
      mutedColor: mutedColor ?? this.mutedColor,
      subtitleColor: subtitleColor ?? this.subtitleColor,
      selectedItemColor: selectedItemColor ?? this.selectedItemColor,
      selectedTextBackgroundColor:
          selectedTextBackgroundColor ?? this.selectedTextBackgroundColor,
      selectedTextColor: selectedTextColor ?? this.selectedTextColor,
      selectedItemBackgroundColor:
          selectedItemBackgroundColor ?? this.selectedItemBackgroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      errorColor: errorColor ?? this.errorColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      infoColor: infoColor ?? this.infoColor,
      errorWeakColor: errorWeakColor ?? this.errorWeakColor,
      successWeakColor: successWeakColor ?? this.successWeakColor,
      warningWeakColor: warningWeakColor ?? this.warningWeakColor,
      infoWeakColor: infoWeakColor ?? this.infoWeakColor,
      surfaceVariantColor: surfaceVariantColor ?? this.surfaceVariantColor,
      surfaceMutedColor: surfaceMutedColor ?? this.surfaceMutedColor,
      focusBorderColor: focusBorderColor ?? this.focusBorderColor,
      hoverColor: hoverColor ?? this.hoverColor,
      disabledBackgroundColor:
          disabledBackgroundColor ?? this.disabledBackgroundColor,
      disabledColor: disabledColor ?? this.disabledColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ColorSeed &&
        other.primary == primary &&
        other.secondary == secondary &&
        other.accent == accent &&
        other.green == green &&
        other.yellow == yellow &&
        other.red == red &&
        other.baseTextColor == baseTextColor &&
        other.placeholderColor == placeholderColor &&
        other.mutedColor == mutedColor &&
        other.subtitleColor == subtitleColor &&
        other.selectedItemColor == selectedItemColor &&
        other.selectedTextBackgroundColor == selectedTextBackgroundColor &&
        other.selectedTextColor == selectedTextColor &&
        other.selectedItemBackgroundColor == selectedItemBackgroundColor &&
        other.backgroundColor == backgroundColor &&
        other.errorColor == errorColor &&
        other.successColor == successColor &&
        other.warningColor == warningColor &&
        other.infoColor == infoColor &&
        other.errorWeakColor == errorWeakColor &&
        other.successWeakColor == successWeakColor &&
        other.warningWeakColor == warningWeakColor &&
        other.infoWeakColor == infoWeakColor &&
        other.surfaceVariantColor == surfaceVariantColor &&
        other.surfaceMutedColor == surfaceMutedColor &&
        other.focusBorderColor == focusBorderColor &&
        other.hoverColor == hoverColor &&
        other.disabledBackgroundColor == disabledBackgroundColor &&
        other.disabledColor == disabledColor;
  }

  @override
  int get hashCode => Object.hashAll([
    primary,
    secondary,
    accent,
    green,
    yellow,
    red,
    baseTextColor,
    placeholderColor,
    mutedColor,
    subtitleColor,
    selectedItemColor,
    selectedTextBackgroundColor,
    selectedTextColor,
    selectedItemBackgroundColor,
    backgroundColor,
    errorColor,
    successColor,
    warningColor,
    infoColor,
    errorWeakColor,
    successWeakColor,
    warningWeakColor,
    infoWeakColor,
    surfaceVariantColor,
    surfaceMutedColor,
    focusBorderColor,
    hoverColor,
    disabledBackgroundColor,
    disabledColor,
  ]);
}
