part of 'index.dart';

/// {@template Button}
/// An interactive button component that supports form validation and resetting.
///
/// To perform form-related actions, place [Button] inside
/// [FormBuilder.children] and set [validateForm] or [resetForm] to `true`.
///
/// ### Example
/// ```dart
/// Button(
///   child: NakiText('Submit'),
///   showLoadingIndicator: true,
///   onTap: () async {
///     await Future<void>.delayed(const Duration(seconds: 1));
///   },
/// )
/// ```
///
/// See also:
///   * [Button.icon] - An icon-only button.
///   * [Button.text] - A text-only button.
///   * [Button.iconText] - A button with an icon and text.
///   * [Button.filled] - A filled button.
///   * [Button.outlined] - An outlined button.
/// {@endtemplate}
class Button extends StatefulComponent {
  /// Component inside the button (e.g. [NakiText]).
  final Component child;

  /// Unique identifier of the button.
  final String? id;

  /// Function called when the button is clicked/tapped.
  final FutureOr<void> Function()? onTap;

  /// When `true`, the button will not be clickable.
  final bool disabled;

  /// Background color of the button.
  final Color? backgroundColor;

  /// Background gradient of the button.
  final Gradient? gradient;

  /// Color applied to the button content.
  final Color? foregroundColor;

  /// Color applied on the button when hovered.
  final Color? hoverColor;

  /// Color applied on the button background when disabled.
  final Color? disabledBackgroundColor;

  /// Border properties of the button.
  final BorderData? border;

  /// Padding applied to [child].
  final EdgeInsets? padding;

  /// Margin applied outside the button.
  final EdgeInsets? margin;

  /// Height of the button.
  final Dim? height;

  /// Width of the button.
  final Dim? width;

  /// Whether to apply a scaling animation when the button is tapped.
  ///
  /// By default, no animation is applied. If `true`, the button will
  /// scale down to 97% of its size when tapped.
  final bool animateOnTap;

  /// Additional CSS classes applied to the button.
  final String? classes;

  /// If `true`, a spinner will be displayed when [onTap] is invoked.
  final bool showLoadingIndicator;

  /// When `true`, a native iOS spinner will be displayed
  /// if [showLoadingIndicator] is enabled.
  final bool ios;

  /// If `true` and the button is a descendant of [FormBuilder],
  /// the form fields will be validated before [onTap] is invoked.
  final bool validateForm;

  /// If `true` and the button is a descendant of [FormBuilder],
  /// the form fields will be reset after [onTap] completes.
  final bool resetForm;

  /// Native HTML button behavior.
  final ButtonType type;

  /// Custom attributes applied to the button.
  final Map<String, String>? attributes;

  /// {@macro Button}
  const Button({
    super.key,
    required this.child,
    this.onTap,
    this.disabled = false,
    this.showLoadingIndicator = false,
    this.validateForm = false,
    this.resetForm = false,
    this.type = ButtonType.button,
    this.ios = false,
    this.animateOnTap = false,
    this.backgroundColor,
    this.gradient,
    this.foregroundColor,
    this.classes,
    this.border,
    this.padding,
    this.margin,
    this.height,
    this.width,
    this.hoverColor,
    this.disabledBackgroundColor,
    this.attributes,
    this.id,
  }) : assert(
         !(validateForm && resetForm),
         'validateForm and resetForm cannot both be true',
       );

  /// Creates a filled button.
  ///
  /// ### Example
  /// ```dart
  /// Button.filled(
  ///   Colors.blue,
  ///   child: NakiText('Add'),
  ///   gradient: Gradient()..applyLinear(colors: [Colors.blue, Colors.red]),
  ///   onTap: () {},
  /// );
  /// ```
  Button.filled(
    Color color, {
    super.key,
    required this.child,
    this.disabled = false,
    this.showLoadingIndicator = false,
    this.validateForm = false,
    this.resetForm = false,
    this.type = ButtonType.button,
    this.ios = false,
    this.animateOnTap = false,
    this.onTap,
    this.gradient,
    this.foregroundColor,
    this.hoverColor,
    this.classes,
    this.border,
    this.padding,
    this.margin,
    this.height,
    this.width,
    this.disabledBackgroundColor,
    this.attributes,
    this.id,
  }) : backgroundColor = color,
       assert(
         !(validateForm && resetForm),
         'validateForm and resetForm cannot both be true',
       );

  /// Creates an outlined button.
  ///
  /// ### Example
  /// ```dart
  /// Button.outlined(
  ///   BorderData(
  ///     width: Dim.px(2),
  ///     radius: BorderRadiusData.all(Dim.px(8)),
  ///     color: Colors.blue,
  ///     style: BorderStyle.solid,
  ///   ),
  ///   child: NakiText('Add'),
  ///   onTap: () {},
  /// );
  /// ```
  Button.outlined(
    BorderData outline, {
    super.key,
    required this.child,
    this.disabled = false,
    this.showLoadingIndicator = false,
    this.validateForm = false,
    this.resetForm = false,
    this.type = ButtonType.button,
    this.ios = false,
    this.animateOnTap = false,
    this.onTap,
    this.gradient,
    this.foregroundColor,
    this.backgroundColor,
    this.hoverColor,
    this.classes,
    this.padding,
    this.margin,
    this.height,
    this.width,
    this.disabledBackgroundColor,
    this.attributes,
    this.id,
  }) : border = outline,
       assert(
         !(validateForm && resetForm),
         'validateForm and resetForm cannot both be true',
       );

  /// Creates an icon button.
  ///
  /// ### Example
  /// ```dart
  /// Button.icon(
  ///   MaterialIcons.add,
  ///   size: 32,
  ///   foregroundColor: Colors.white,
  ///   onTap: () {},
  /// );
  /// ```
  Button.icon(
    IconData icon, {
    super.key,
    double size = 24,
    this.disabled = false,
    this.showLoadingIndicator = false,
    this.validateForm = false,
    this.resetForm = false,
    this.type = ButtonType.button,
    this.ios = false,
    this.animateOnTap = false,
    this.onTap,
    this.backgroundColor,
    this.gradient,
    this.foregroundColor,
    this.hoverColor,
    this.classes,
    this.border,
    this.padding,
    this.margin,
    this.height,
    this.width,
    this.disabledBackgroundColor,
    Map<String, String>? attributes,
    String? semanticLabel,
    this.id,
  }) : child = Icon(
         icon,
         color: foregroundColor ?? Tokens.current.buttonForegroundColor.color,
         size: size,
       ),
       // icon-only buttons need an accessible name
       attributes = semanticLabel == null
           ? attributes
           : {'aria-label': semanticLabel, ...?attributes},
       assert(
         !(validateForm && resetForm),
         'validateForm and resetForm cannot both be true',
       );

  /// Creates an icon and text button with customizable icon position
  /// and alignment.
  ///
  /// ### Example
  /// ```dart
  /// Button.iconText(
  ///   icon: MaterialIcons.add,
  ///   text: "Add",
  ///   iconSize: 32,
  ///   iconPosition: Position.left,
  ///   foregroundColor: Colors.white,
  ///   textStyle: TextStyle(color: Colors.white),
  ///   onTap: () {},
  /// );
  /// ```
  Button.iconText({
    super.key,
    required IconData icon,
    required String text,
    Position iconPosition = Position.right,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.min,
    double iconSize = 24,
    double? spacing,
    TextStyle? textStyle,
    this.disabled = false,
    this.showLoadingIndicator = false,
    this.validateForm = false,
    this.resetForm = false,
    this.type = ButtonType.button,
    this.ios = false,
    this.animateOnTap = false,
    this.onTap,
    this.backgroundColor,
    this.gradient,
    this.foregroundColor,
    this.hoverColor,
    this.classes,
    this.border,
    this.padding,
    this.margin,
    this.height,
    this.width,
    this.disabledBackgroundColor,
    this.attributes,
    this.id,
  }) : child = Row(
         mainAxisAlignment: mainAxisAlignment,
         mainAxisSize: mainAxisSize,
         crossAxisAlignment: CrossAxisAlignment.center,
         spacing: spacing,
         children: iconPosition == Position.left
             ? [
                 Icon(
                   icon,
                   color:
                       foregroundColor ??
                       Tokens.current.buttonForegroundColor.color,
                   size: iconSize,
                 ),
                 NakiText(
                   text,
                   style: TextStyle(
                     color:
                         foregroundColor ??
                         Tokens.current.buttonForegroundColor.color,
                   ).combineWith(textStyle),
                 ),
               ]
             : [
                 NakiText(
                   text,
                   style: TextStyle(
                     color:
                         foregroundColor ??
                         Tokens.current.buttonForegroundColor.color,
                   ).combineWith(textStyle),
                 ),
                 Icon(
                   icon,
                   color:
                       foregroundColor ??
                       Tokens.current.buttonForegroundColor.color,
                   size: iconSize,
                 ),
               ],
       ),
       assert(
         !(validateForm && resetForm),
         'validateForm and resetForm cannot both be true',
       );

  /// Creates a text button.
  ///
  /// ### Example
  /// ```dart
  /// Button.text(
  ///   "Add",
  ///   onTap: () {},
  /// );
  /// ```
  Button.text(
    String text, {
    super.key,
    TextStyle? style,
    this.onTap,
    this.disabled = false,
    this.showLoadingIndicator = false,
    this.validateForm = false,
    this.resetForm = false,
    this.type = ButtonType.button,
    this.ios = false,
    this.animateOnTap = false,
    this.backgroundColor,
    this.gradient,
    this.foregroundColor,
    this.hoverColor,
    this.classes,
    this.border,
    this.padding,
    this.margin,
    this.height,
    this.width,
    this.disabledBackgroundColor,
    this.attributes,
    this.id,
  }) : child = NakiText(
         text,
         style: TextStyle(
           color: foregroundColor ?? Tokens.current.buttonForegroundColor.color,
         ).combineWith(style),
       ),
       assert(
         !(validateForm && resetForm),
         'validateForm and resetForm cannot both be true',
       );

  @override
  State<Button> createState() => _ButtonState();

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Button', [Rules.nakiButtonRules]);
}

class _ButtonState extends State<Button> {
  bool _isLoading = false;

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  /// Handles button click.
  Future<void> _onClick() async {
    if (component.disabled || _isLoading) return;

    final action = component.onTap;
    final form = FormScope.of(context);

    if (form != null) {
      if (component.validateForm && !form.validate()) return;
      if (component.resetForm && action == null) form.reset();
    }

    if (action != null) {
      if (component.showLoadingIndicator) setState(() => _isLoading = true);

      try {
        final result = action();
        if (result is Future) await result;
      } finally {
        if (component.resetForm) form?.reset();
        if (_isLoading) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Component build(BuildContext context) {
    const String baseClass = 'naki-button';
    final String effectiveClasses = joinClasses([
      ?component.classes,
      baseClass,
    ]);

    final Map<String, String> effectiveStyles = {
      Tokens.current.buttonBackgroundColor.name:
          ?component.backgroundColor?.value,
      Tokens.current.buttonForegroundColor.name:
          ?component.foregroundColor?.value,
      Tokens.current.disabledBgColor.name:
          ?component.disabledBackgroundColor?.value,
      Tokens.current.buttonHoverBgColor.name: ?component.hoverColor?.value,
      Tokens.current.buttonHeight.name: ?component.height?.cssText,
      Tokens.current.buttonWidth.name: ?component.width?.cssText,
      ...?component.border?.props,
      ...?component.padding?.pProps,
      ...?component.margin?.mProps,
      ...?component.gradient?.props,
    };

    final isNativeReset = component.resetForm && component.onTap == null;
    final isNativeSubmit = component.type == .submit && component.onTap == null;

    final shouldHandleClick =
        !isNativeReset &&
        !isNativeSubmit &&
        (component.onTap != null || component.validateForm);

    final ButtonType effectiveType = isNativeReset
        ? ButtonType.reset
        : shouldHandleClick
        ? ButtonType.button
        : component.type;

    final canHover = component.hoverColor != null && !component.disabled;
    final canScale = component.animateOnTap && !component.disabled;

    return button(
      key: component.key,
      id: component.id,
      classes: effectiveClasses,
      type: effectiveType,
      styles: Styles(raw: effectiveStyles),
      disabled: component.disabled,
      attributes: {
        'hvr': ?(canHover ? '' : null),
        'scl': ?(canScale ? '' : null),
        ...?component.attributes,
      },
      onClick: shouldHandleClick ? _onClick : null,
      [
        _isLoading
            ? Spinner(
                ios: component.ios,
                color: component.foregroundColor,
                thickness: 2,
              )
            : component.child,
      ],
    );
  }
}
