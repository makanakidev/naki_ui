part of '../theme.dart';

/// Represents customizable global padding and margin spacing variables.
class SpacingScheme {
  /// Small padding.
  final Dim? paddingSm;

  /// Medium padding.
  final Dim? paddingMd;

  /// Large padding.
  final Dim? paddingLg;

  /// Small margin.
  final Dim? marginSm;

  /// Medium margin.
  final Dim? marginMd;

  /// Large margin.
  final Dim? marginLg;

  const SpacingScheme({
    this.paddingSm,
    this.paddingMd,
    this.paddingLg,
    this.marginSm,
    this.marginMd,
    this.marginLg,
  });

  SpacingScheme copyWith({
    Dim? paddingSm,
    Dim? paddingMd,
    Dim? paddingLg,
    Dim? marginSm,
    Dim? marginMd,
    Dim? marginLg,
  }) {
    return SpacingScheme(
      paddingSm: paddingSm ?? this.paddingSm,
      paddingMd: paddingMd ?? this.paddingMd,
      paddingLg: paddingLg ?? this.paddingLg,
      marginSm: marginSm ?? this.marginSm,
      marginMd: marginMd ?? this.marginMd,
      marginLg: marginLg ?? this.marginLg,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpacingScheme &&
        other.paddingSm == paddingSm &&
        other.paddingMd == paddingMd &&
        other.paddingLg == paddingLg &&
        other.marginSm == marginSm &&
        other.marginMd == marginMd &&
        other.marginLg == marginLg;
  }

  @override
  int get hashCode => Object.hash(
    paddingSm,
    paddingMd,
    paddingLg,
    marginSm,
    marginMd,
    marginLg,
  );
}
