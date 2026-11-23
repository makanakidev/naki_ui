part of '../theme_data.dart';

/// Represents customizable global padding and margin spacing variables.
class SpacingScheme {
  /// Extra small padding.
  final Dim? paddingXs;

  /// Small padding.
  final Dim? paddingSm;

  /// Medium padding.
  final Dim? paddingMd;

  /// Large padding.
  final Dim? paddingLg;

  /// Extra small margin.
  final Dim? marginXs;

  /// Small margin.
  final Dim? marginSm;

  /// Medium margin.
  final Dim? marginMd;

  /// Large margin.
  final Dim? marginLg;

  const SpacingScheme({
    this.paddingXs,
    this.paddingSm,
    this.paddingMd,
    this.paddingLg,
    this.marginXs,
    this.marginSm,
    this.marginMd,
    this.marginLg,
  });

  SpacingScheme copyWith({
    Dim? paddingXs,
    Dim? paddingSm,
    Dim? paddingMd,
    Dim? paddingLg,
    Dim? marginXs,
    Dim? marginSm,
    Dim? marginMd,
    Dim? marginLg,
  }) {
    return SpacingScheme(
      paddingXs: paddingXs ?? this.paddingXs,
      paddingSm: paddingSm ?? this.paddingSm,
      paddingMd: paddingMd ?? this.paddingMd,
      paddingLg: paddingLg ?? this.paddingLg,
      marginXs: marginXs ?? this.marginXs,
      marginSm: marginSm ?? this.marginSm,
      marginMd: marginMd ?? this.marginMd,
      marginLg: marginLg ?? this.marginLg,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpacingScheme &&
        other.paddingXs == paddingXs &&
        other.paddingSm == paddingSm &&
        other.paddingMd == paddingMd &&
        other.paddingLg == paddingLg &&
        other.marginXs == marginXs &&
        other.marginSm == marginSm &&
        other.marginMd == marginMd &&
        other.marginLg == marginLg;
  }

  @override
  int get hashCode => Object.hash(
    paddingXs,
    paddingSm,
    paddingMd,
    paddingLg,
    marginXs,
    marginSm,
    marginMd,
    marginLg,
  );
}
