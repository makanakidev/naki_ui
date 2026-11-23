part of 'index.dart';

/// {@template Icon}
/// A component that renders an SVG icon using the generated
/// collections from `jaspr_icons_pack`.
///
/// ### Example
/// ```dart
/// Icon(
///  MaterialIcons.check_circle_outline,
///  size: 35,
///  color: Colors.green,
///  classes: 'my-icon',
/// )
/// ```
/// {@endtemplate}
class Icon extends StatelessComponent {
  /// Icon data to render.
  final IconData icon;

  /// Size of the icon (default: 24).
  final double size;

  /// Color to paint the icon.
  final Color? color;

  /// Additional CSS classes applied to the icon.
  final String? classes;

  /// Callback invoked when the icon is clicked.
  final VoidCallback? onTap;

  /// Accessible name for an interactive icon.
  final String? semanticLabel;

  /// {@macro Icon}
  const Icon(
    this.icon, {
    super.key,
    this.size = 24,
    this.color,
    this.classes,
    this.onTap,
    this.semanticLabel,
  }) : assert(
         onTap == null || (semanticLabel != null && semanticLabel != ''),
         'semanticLabel is required when an icon is interactive',
       );

  /// Creates a copy of this component with the specified
  /// properties overridden.
  Icon copyWith({
    IconData? icon,
    double? size,
    Color? color,
    String? classes,
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    return Icon(
      icon ?? this.icon,
      size: size ?? this.size,
      color: color ?? this.color,
      classes: classes ?? this.classes,
      onTap: onTap ?? this.onTap,
      semanticLabel: semanticLabel ?? this.semanticLabel,
    );
  }

  @override
  Component build(BuildContext context) {
    const String baseClass = 'naki-icon';
    final effectiveClasses = joinClasses([?classes, baseClass]);
    final hitBoxMargin = ((42 - size) / -2).toPx;

    final hasLabel = semanticLabel.isNotNullAndEmpty;

    final child = SvgIcon(
      icon,
      key: key,
      size: size,
      color: color,
      classes: effectiveClasses,
      attributes: onTap == null && hasLabel
          ? {'role': 'img', 'aria-label': semanticLabel!}
          : const {'aria-hidden': 'true'},
    );

    if (onTap == null) return child;

    return button(
      type: ButtonType.button,
      classes: 'naki-control-hitbox',
      attributes: {'aria-label': ?semanticLabel},
      styles: Styles(
        raw: {
          'margin': '0 $hitBoxMargin',
          'padding': '0',
          'border': 'none',
          'background-color': 'transparent',
          'color': 'inherit',
          'font': 'inherit',
        },
      ),
      onClick: onTap,
      [child],
    );
  }

  static List<StyleRule> get styles => BasicsStyles.icon;
}
