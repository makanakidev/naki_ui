part of 'index.dart';

/// {@template Card}
/// A Naki component that renders a surface used to represent related
/// information, such as an album, a product card, a task item, or
/// a settings panel.
///
/// By default, a [Card] uses an elevated surface with subtle box shadow
/// and rounded corners. Use [Card.outlined] for a card bounded by a
/// border, or [Card.filled] for a solid surface-variant card.
///
/// ### Example
/// ```dart
/// Card(
///   padding: EdgeInsets.all(Dim.px(16)),
///   child: Column(
///     children: const [
///       Heading('Material Card', level: HeadingLevel.h4),
///       NakiText('Card content goes here.'),
///     ],
///   ),
/// )
/// ```
/// {@endtemplate}
class Card extends StatelessComponent {
  /// Component to display inside the card.
  final Component child;

  /// Background color of the card.
  /// This will override [BoxDecoration.backgroundColor] if
  /// both are provided.
  final Color? color;

  /// Decoration applied to the card.
  final BoxDecoration? decoration;

  /// Background gradient of the card.
  /// This will override [BoxDecoration.gradient] if both are provided.
  ///
  /// ### Example
  /// ```dart
  /// Card(
  ///   gradient: Gradient()..applyLinear(colors: [Colors.blue, Colors.purple]),
  ///   child: NakiText('Gradient Card'),
  /// )
  /// ```
  final Gradient? gradient;

  /// Elevation of the card, controlling its shadow depth.
  ///
  /// Set to `0` or use [Card.outlined] / [Card.filled] for a flat card.
  final double? elevation;

  /// Border radius of the card corners.
  /// This will override [BoxDecoration.borderRadius] if
  /// both are provided.
  final BorderRadiusData? borderRadius;

  /// Inner padding inside the card.
  /// This will override [BoxDecoration.padding] if both are provided.
  final EdgeInsets? padding;

  /// Explicit width of the card.
  final Dim? width;

  /// Explicit height of the card.
  final Dim? height;

  /// Size constraints applied to the card.
  final SizeConstraints? constraints;

  /// Whether to clip content that overflows the card's rounded borders.
  final bool clip;

  /// Additional CSS classes applied to the card element.
  final String? classes;

  /// Optional callback invoked when the card is clicked.
  ///
  /// When provided, the card renders with an interactive
  /// pointer cursor and hover feedback.
  final FutureOr<void> Function()? onTap;

  final CardVariant _variant;
  final BorderData? _border;

  /// {@macro Card}
  const Card({
    super.key,
    required this.child,
    this.elevation = 1.0,
    this.clip = false,
    this.color,
    this.gradient,
    this.decoration,
    this.borderRadius,
    this.padding,
    this.width,
    this.height,
    this.constraints,
    this.onTap,
    this.classes,
  }) : _variant = CardVariant.elevated,
       _border = null;

  /// Creates an outlined card.
  ///
  /// Outlined cards have a default border and zero elevation shadow.
  const Card.outlined({
    super.key,
    BorderData? border,
    required this.child,
    this.clip = false,
    this.color,
    this.gradient,
    this.borderRadius,
    this.decoration,
    this.padding,
    this.width,
    this.height,
    this.constraints,
    this.classes,
    this.onTap,
  }) : elevation = 0,
       _border = border,
       _variant = CardVariant.outlined;

  /// Creates a filled card.
  ///
  /// Filled cards use a distinct surface container background color
  /// and zero elevation shadow.
  const Card.filled({
    super.key,
    this.color,
    required this.child,
    this.clip = false,
    this.gradient,
    this.borderRadius,
    this.decoration,
    this.padding,
    this.width,
    this.height,
    this.constraints,
    this.classes,
    this.onTap,
  }) : elevation = 0,
       _border = null,
       _variant = CardVariant.filled;

  /// Creates a glass card.
  ///
  /// Glass cards tint and blur the content behind them, so they
  /// need something to sit on such as an image or a gradient.
  /// [color] sets the tint, and the card turns opaque for
  /// users who ask for less transparency or more contrast.
  ///
  /// A glass surface inside this card only sees the card, not the page.
  const Card.glass({
    super.key,
    this.color,
    required this.child,
    this.clip = false,
    this.gradient,
    this.borderRadius,
    this.decoration,
    this.padding,
    this.width,
    this.height,
    this.constraints,
    this.classes,
    this.onTap,
  }) : elevation = 0,
       _border = null,
       _variant = CardVariant.glass;

  static String? _elevationToBoxShadow(double? elevation, Color? shadowColor) {
    if (elevation == null) return null;
    if (elevation <= 0) return 'none';

    final col =
        shadowColor?.value ??
        'var(${Tokens.current.shadowColor.name}, ${Tokens.current.shadowColor.value})';
    final y = (elevation * 2).clamp(1, 24).toInt();
    final blur = (elevation * 4).clamp(2, 48).toInt();
    final spread = (elevation * 0.5).clamp(0, 8).toInt();

    return '0px ${y}px ${blur}px ${spread}px $col';
  }

  @override
  Component build(BuildContext context) {
    final isInteractive = onTap != null;
    final variantClass = 'naki-card--${_variant.name}';
    final interactiveClass = isInteractive ? 'naki-card--interactive' : '';

    final effectiveClasses = joinClasses([
      ?classes,
      interactiveClass,
      variantClass,
      'naki-card',
    ]);

    final shadow = decoration?.shadow;
    final effectiveBgColor = color?.value ?? decoration?.backgroundColor?.value;

    final effectiveStyles = {
      ...?decoration?.props.without(['background-color']),
      ...?_border?.props,
      ...?constraints?.props,
      ...?borderRadius?.props,
      ...?padding?.pProps,
      ...?gradient?.props,
      if (_variant == CardVariant.glass)
        kCardGlassColorVar: ?effectiveBgColor
      else
        'background-color': ?effectiveBgColor,
      'overflow': ?(clip ? 'hidden' : null),
      'height': ?height?.cssText,
      'width': ?width?.cssText,
      if (shadow == null &&
          elevation != null &&
          _variant == CardVariant.elevated &&
          elevation != 1.0)
        'box-shadow': ?_elevationToBoxShadow(elevation, shadow?.color),
      if (elevation == 0 && _variant == CardVariant.elevated)
        'box-shadow': 'none',
    };

    return .element(
      key: key,
      tag: 'naki-card',
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      events: isInteractive
          ? Events(
              onClick: (_) async {
                final value = onTap!();
                if (value is Future) await value;
              },
              onKeyDown: (event) {
                if (event.key == 'Enter' || event.key == ' ') {
                  event.preventDefault();
                  onTap!();
                }
              },
            ).toMap
          : null,
      attributes: isInteractive ? {'tabindex': '0', 'role': 'button'} : null,
      children: [child],
    );
  }

  static List<StyleRule> get styles => LayoutStyles.card;
}
