part of 'index.dart';

/// {@template Banner}
/// A component for presenting callout notifications, banners,
/// or inline feedback messages with severity color coding.
///
/// ### Example
/// ```dart
/// Banner(
///   primary: NakiText('Success'),
///   secondary: NakiText('Your changes have been saved.'),
///   severity: BannerType.success,
/// )
/// ```
/// {@endtemplate}
class Banner extends StatelessComponent {
  /// This is the main component that is always displayed.
  ///
  /// It is usually a title component but can be any other component.
  final Component? primary;

  /// Optional component displayed below the [primary] component.
  final Component? secondary;

  /// Optional list of action components such as buttons or icons
  /// displayed below the [primary] and [secondary] components.
  final List<Component>? actions;

  /// Severity status (info, success, warning, error, neutral).
  final BannerType severity;

  /// Optional leading icon component.
  final Icon? icon;

  /// Whether the banner can be dismissed via a close icon.
  final bool dismissible;

  /// Callback executed when the close icon is clicked.
  final VoidCallback? onClose;

  /// Background color of the banner.
  final Color? backgroundColor;

  /// Background gradient of the banner.
  ///
  /// ### Example
  /// ```dart
  /// Banner(
  ///   primary: NakiText('Welcome!'),
  ///   gradient: Gradient()..applyLinear(colors: [Colors.indigo, Colors.teal]),
  /// )
  /// ```
  final Gradient? gradient;

  /// Color applied on the banner content.
  final Color? foregroundColor;

  /// Close icon color (default: red).
  final Color? closeIconColor;

  /// Border attributes of the banner container.
  final BorderData? border;

  /// Padding inside the banner container.
  final EdgeInsets? padding;

  /// Size constraints of the banner container.
  final SizeConstraints? sizeConstraints;

  /// Additional CSS classes applied to the banner.
  final String? classes;

  /// {@macro Banner}
  const Banner({
    this.severity = BannerType.info,
    this.dismissible = false,
    this.actions,
    this.icon,
    this.onClose,
    this.backgroundColor,
    this.gradient,
    this.foregroundColor,
    this.border,
    this.padding,
    this.classes,
    super.key,
    this.primary,
    this.secondary,
    this.closeIconColor,
    this.sizeConstraints,
  });

  @override
  Component build(BuildContext context) {
    final effectiveStyles = {
      Tokens.current.bannerBgColor.name: ?backgroundColor?.value,
      Tokens.current.bannerForegroundColor.name: ?foregroundColor?.value,
      Tokens.current.bannerPadding.name: ?padding?.value,
      ...?sizeConstraints?.props,
      ...?border?.props,
      ...?gradient?.props,
    };

    final baseClass = 'naki-banner banner-${severity.name}';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    final List<Component> effectiveChildren = [
      // leading icon
      ?icon,

      // content area
      div(classes: 'banner-content', [
        // primary component (e.g title)
        ?primary,

        // secondary component (e.g subtitle)
        ?secondary,

        // action buttons
        if (actions != null && actions!.isNotEmpty)
          Row(
            children: actions!,
            mainAxisSize: MainAxisSize.min,
            classes: 'banner-actions',
          ),
      ]),

      // trailing close button
      if (dismissible)
        Button.icon(
          MaterialIcons.icon_round_close,
          size: 20,
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          foregroundColor: closeIconColor ?? context.red,
          height: Dim.auto,
          width: Dim.auto,
          onTap: onClose,
          attributes: const {'aria-label': 'Dismiss banner'},
        ),
    ];

    return .element(
      tag: 'naki-banner',
      key: key,
      classes: effectiveClasses,
      attributes: const {'role': 'alert'},
      styles: Styles(raw: effectiveStyles),
      children: effectiveChildren,
    );
  }

  static List<StyleRule> get styles => BasicsStyles.banner;
}
