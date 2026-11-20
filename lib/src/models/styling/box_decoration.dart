part of 'index.dart';

/// Box decoration attributes of a component.
class BoxDecoration implements NakiStylable {
  /// Color applied to the box background.
  final Color? backgroundColor;

  /// Image applied to the box background.
  final String? backgroundImage;

  /// How the background image should be sized to fit the box.
  final ObjectFit? imageFit;

  /// How the background image should be positioned within the box.
  final ObjectPosition? imagePosition;

  /// Gradient painted on the box.
  final Gradient? gradient;

  /// Color applied to the box child.
  final Color? foregroundColor;

  /// The CSS display value of the box.
  final Display? display;

  /// Border of the box.
  final BorderData? border;

  /// Whether to clip content that overflows the box.
  ///
  /// `null` keeps the component default (content may overflow, as with
  /// Flutter's `Clip.none`), `true` clips and `false` forces overflow to be
  /// visible. Use `true` to clip children to a rounded border.
  final bool? clip;

  /// Border radius of the box.
  final BorderRadiusData? borderRadius;

  /// Padding of the box child.
  final EdgeInsets? padding;

  /// Margin of the box.
  final EdgeInsets? margin;

  /// Alignment of the box child.
  final Alignment? alignment;

  /// Position of the box.
  final PositionData? position;

  /// Shadow applied to the box.
  final Shadow? shadow;

  /// Opacity of the box.
  final double? opacity;

  /// Create a new box decoration.
  const BoxDecoration({
    this.backgroundColor,
    this.backgroundImage,
    this.imageFit,
    this.imagePosition,
    this.gradient,
    this.display,
    this.foregroundColor,
    this.border,
    this.clip,
    this.borderRadius,
    this.padding,
    this.margin,
    this.alignment,
    this.position,
    this.shadow,
    this.opacity,
  });

  /// Converts the ObjectFit enum to a CSS background-size value.
  String? get _backgroundImageSize => switch (imageFit) {
    ObjectFit.cover => 'cover',
    ObjectFit.contain => 'contain',
    ObjectFit.fill => '100% 100%',
    ObjectFit.none => 'auto',
    ObjectFit.scaleDown => 'auto',
    _ => null,
  };

  /// Normalizes the background image to a CSS-valid format.
  String? get _normalizedBackgroundImage => switch (backgroundImage) {
    final bg? when bg.contains('gradient') => null,
    final bg? when bg.startsWith('url(') => bg,
    final bg? => 'url("$bg")',
    null => null,
  };

  /// Converts box decoration attributes to a CSS style map.
  @override
  Map<String, String> get props => {
    'display': ?display?.value,
    'background-color': ?backgroundColor?.value,
    'background-image': ?_normalizedBackgroundImage,
    'background-size': ?_backgroundImageSize,
    'background-position': ?imagePosition?.css,
    'color': ?foregroundColor?.value,
    'opacity': ?opacity?.toCleanString,
    'overflow': ?switch (clip) {
      true => 'hidden',
      false => 'visible',
      null => null,
    },
    ...?borderRadius?.props,
    ...?border?.props,
    ...?padding?.pProps,
    ...?margin?.mProps,
    ...?position?.props,
    ...?shadow?.props,
    ...?gradient?.props,
    if (alignment != null) ...{
      ...NakiAlignProps.mapAlignment(alignment!),
      'display': 'flex',
    },
  };

  @override
  String get cssText => props.cssText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoxDecoration &&
          runtimeType == other.runtimeType &&
          backgroundColor == other.backgroundColor &&
          backgroundImage == other.backgroundImage &&
          imageFit == other.imageFit &&
          imagePosition == other.imagePosition &&
          gradient == other.gradient &&
          foregroundColor == other.foregroundColor &&
          display == other.display &&
          border == other.border &&
          clip == other.clip &&
          borderRadius == other.borderRadius &&
          padding == other.padding &&
          margin == other.margin &&
          alignment == other.alignment &&
          position == other.position &&
          shadow == other.shadow &&
          opacity == other.opacity;

  @override
  int get hashCode => Object.hashAll([
    backgroundColor,
    backgroundImage,
    imageFit,
    imagePosition,
    gradient,
    foregroundColor,
    display,
    border,
    clip,
    borderRadius,
    padding,
    margin,
    alignment,
    position,
    shadow,
    opacity,
  ]);
}
