part of '../theme_data.dart';

/// Represents customizable font family, font size,
/// and font weight variables.
class TypographyScheme {
  /// Font family stack.
  final List<String>? fontFamily;

  /// Small font size.
  final Dim? fontSizeSm;

  /// Medium font size.
  final Dim? fontSizeMd;

  /// Large font size.
  final Dim? fontSizeLg;

  /// Extra large font size.
  final Dim? fontSizeXl;

  /// 2X large title font size.
  final Dim? fontSize2xl;

  /// 3X large title font size.
  final Dim? fontSize3xl;

  /// 4X large title font size.
  final Dim? fontSize4xl;

  /// 5X large title font size.
  final Dim? fontSize5xl;

  /// Validation error font size.
  final Dim? fontSizeError;

  /// Hint font size.
  final Dim? fontSizeHint;

  /// Label font size.
  final Dim? fontSizeLabel;

  /// Section header font size.
  final Dim? fontSizeSectionHeader;

  /// Normal font weight.
  final int? fontWeightNormal;

  /// Medium font weight.
  final int? fontWeightMedium;

  /// Semi-bold font weight.
  final int? fontWeightSemiBold;

  /// Bold font weight.
  final int? fontWeightBold;

  /// Section header font weight.
  final int? fontWeightSectionHeader;

  const TypographyScheme({
    this.fontFamily,
    this.fontSizeSm,
    this.fontSizeMd,
    this.fontSizeLg,
    this.fontSizeXl,
    this.fontSize2xl,
    this.fontSize3xl,
    this.fontSize4xl,
    this.fontSize5xl,
    this.fontSizeError,
    this.fontSizeHint,
    this.fontSizeLabel,
    this.fontSizeSectionHeader,
    this.fontWeightNormal,
    this.fontWeightMedium,
    this.fontWeightSemiBold,
    this.fontWeightBold,
    this.fontWeightSectionHeader,
  });

  TypographyScheme copyWith({
    List<String>? fontFamily,
    Dim? fontSizeSm,
    Dim? fontSizeMd,
    Dim? fontSizeLg,
    Dim? fontSizeXl,
    Dim? fontSize2xl,
    Dim? fontSize3xl,
    Dim? fontSize4xl,
    Dim? fontSize5xl,
    Dim? fontSizeError,
    Dim? fontSizeHint,
    Dim? fontSizeLabel,
    Dim? fontSizeSectionHeader,
    int? fontWeightNormal,
    int? fontWeightMedium,
    int? fontWeightSemiBold,
    int? fontWeightBold,
    int? fontWeightSectionHeader,
  }) {
    return TypographyScheme(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSizeSm: fontSizeSm ?? this.fontSizeSm,
      fontSizeMd: fontSizeMd ?? this.fontSizeMd,
      fontSizeLg: fontSizeLg ?? this.fontSizeLg,
      fontSizeXl: fontSizeXl ?? this.fontSizeXl,
      fontSize2xl: fontSize2xl ?? this.fontSize2xl,
      fontSize3xl: fontSize3xl ?? this.fontSize3xl,
      fontSize4xl: fontSize4xl ?? this.fontSize4xl,
      fontSize5xl: fontSize5xl ?? this.fontSize5xl,
      fontSizeError: fontSizeError ?? this.fontSizeError,
      fontSizeHint: fontSizeHint ?? this.fontSizeHint,
      fontSizeLabel: fontSizeLabel ?? this.fontSizeLabel,
      fontSizeSectionHeader:
          fontSizeSectionHeader ?? this.fontSizeSectionHeader,
      fontWeightNormal: fontWeightNormal ?? this.fontWeightNormal,
      fontWeightMedium: fontWeightMedium ?? this.fontWeightMedium,
      fontWeightSemiBold: fontWeightSemiBold ?? this.fontWeightSemiBold,
      fontWeightBold: fontWeightBold ?? this.fontWeightBold,
      fontWeightSectionHeader:
          fontWeightSectionHeader ?? this.fontWeightSectionHeader,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TypographyScheme &&
        listEquals(other.fontFamily, fontFamily) &&
        other.fontSizeSm == fontSizeSm &&
        other.fontSizeMd == fontSizeMd &&
        other.fontSizeLg == fontSizeLg &&
        other.fontSizeXl == fontSizeXl &&
        other.fontSize2xl == fontSize2xl &&
        other.fontSize3xl == fontSize3xl &&
        other.fontSize4xl == fontSize4xl &&
        other.fontSize5xl == fontSize5xl &&
        other.fontSizeSectionHeader == fontSizeSectionHeader &&
        other.fontSizeError == fontSizeError &&
        other.fontSizeHint == fontSizeHint &&
        other.fontSizeLabel == fontSizeLabel &&
        other.fontWeightNormal == fontWeightNormal &&
        other.fontWeightMedium == fontWeightMedium &&
        other.fontWeightSemiBold == fontWeightSemiBold &&
        other.fontWeightBold == fontWeightBold &&
        other.fontWeightSectionHeader == fontWeightSectionHeader;
  }

  @override
  int get hashCode => Object.hashAll([
    Object.hashAll(fontFamily ?? const []),
    fontSizeSm,
    fontSizeMd,
    fontSizeLg,
    fontSizeXl,
    fontSize2xl,
    fontSize3xl,
    fontSize4xl,
    fontSize5xl,
    fontSizeError,
    fontSizeHint,
    fontSizeLabel,
    fontSizeSectionHeader,
    fontWeightNormal,
    fontWeightMedium,
    fontWeightSemiBold,
    fontWeightBold,
    fontWeightSectionHeader,
  ]);
}
