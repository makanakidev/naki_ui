import 'dart:async';

import 'package:jaspr/dom.dart' hide Orientation, Position;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_icons_pack/jaspr_icons_pack.dart';
import 'package:universal_web/web.dart' show KeyboardEvent;

import '../framework/framework.dart';
import '../framework/inherited.dart';
import '../models/gesture.dart';
import '../models/naki.dart';
import '../models/styling.dart';
import '../styles/rules.dart';
import '../styles/text_style.dart';
import '../theme/tokens.dart';
import '../utilities/enums.dart';
import '../utilities/extensions.dart';
import '../utilities/helpers.dart';
import '../utilities/storage.dart';

import 'input.dart' show FormBuilder;
import 'layout.dart' show Container;
import 'scrolling.dart' show ScrollBarWrapper;

// /////////////////////////////////////////////////////////////////////////////
// BASIC & INTERACTIVE COMPONENTS
// /////////////////////////////////////////////////////////////////////////////

/// {@template Column}
/// A component that displays its children in a vertical array.
///
/// ### Example
/// ```dart
/// Column(
///   mainAxisSize: MainAxisSize.max,
///   mainAxisAlignment: MainAxisAlignment.spaceBetween,
///   children: [
///     NakiText('Hello'),
///     NakiText('World'),
///   ],
/// )
///
/// // Example of a scrollable column
/// Column(
///   scrollable: true,
///   spacing: 10,
///   crossAxisAlignment: CrossAxisAlignment.center,
///   scrollBarConfiguration: const ScrollBarConfiguration(
///     thumbColor: Color('#888888'),
///     trackColor: Color('#f0f0f0'),
///   ),
///   children: [
///     NakiText('Hello'),
///     NakiText('World'),
///     NakiText('Hello'),
///     NakiText('World'),
///   ],
/// )
/// ```
/// {@endtemplate}
class Column extends StatelessComponent {
  /// Components below this column in the tree.
  final List<Component> children;

  /// How the children should be placed along the vertical axis.
  final MainAxisAlignment mainAxisAlignment;

  /// How the children should be placed along the horizontal axis.
  final CrossAxisAlignment crossAxisAlignment;

  /// How much vertical space the column should occupy.
  final MainAxisSize mainAxisSize;

  /// Additional CSS classes applied to the column.
  final String? classes;

  /// The distance (in px) between [children] components.
  final double? spacing;

  /// Reverse the order of children.
  final bool reverse;

  /// Scrollbar configuration applied when [scrollable] is `true`.
  final ScrollBarConfiguration? scrollBarConfiguration;

  /// When `true`, the column will be scrollable.
  final bool scrollable;

  /// {@macro Column}
  const Column({
    super.key,
    required this.children,
    this.reverse = false,
    this.scrollable = false,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.min,
    this.spacing,
    this.classes,
    this.scrollBarConfiguration,
  });

  @override
  Component build(BuildContext context) {
    final _id = nakiDomId(context, 'column');

    final justify = NakiAlignProps.mapMainAxisAlignment(
      mainAxisAlignment,
    );

    final align = NakiAlignProps.mapCrossAxisAlignment(
      crossAxisAlignment,
    );

    const baseClass = 'naki-column';
    final effectiveClasses = classes.isNotNullAndEmpty
        ? '$baseClass $classes'
        : baseClass;

    final effectiveStyles = {
      'display': 'flex',
      'flex-direction': reverse ? 'column-reverse' : 'column',
      'justify-content': justify,
      'align-items': align,
      'height': ?(mainAxisSize == MainAxisSize.max ? '100%' : null),
      'row-gap': ?spacing?.toPx,
      'overflow-y': ?(scrollable ? 'auto' : null),
    };

    Component child = .element(
      key: key,
      id: _id,
      tag: 'naki-column',
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: children,
    );

    if (scrollable) {
      child = ScrollBarWrapper(
        selector: '#$_id',
        configuration: scrollBarConfiguration,
        child: child,
      );
    }

    return FlexScope(
      scrollable: scrollable,
      child: child,
    );
  }
}

/// {@template Row}
/// A component that displays its children in an horizontal array.
///
/// ### Example
/// ```dart
/// Row(
///   mainAxisSize: MainAxisSize.min,
///   mainAxisAlignment: MainAxisAlignment.spaceBetween,
///   children: [
///     NakiText('Hello'),
///     NakiText('World'),
///   ],
/// )
///
/// // Example of a scrollable row
/// Row(
///   scrollable: true,
///   spacing: 10,
///   crossAxisAlignment: CrossAxisAlignment.center,
///   scrollBarConfiguration: const ScrollBarConfiguration(
///     thumbColor: Color('#888888'),
///     trackColor: Color('#f0f0f0'),
///   ),
///   children: [
///     NakiText('Hello'),
///     NakiText('World'),
///     NakiText('Hello'),
///     NakiText('World'),
///   ],
/// )
/// ```
/// {@endtemplate}
class Row extends StatelessComponent {
  /// Components below this row in the tree.
  final List<Component> children;

  /// How the children should be placed along the horizontal axis.
  final MainAxisAlignment mainAxisAlignment;

  /// How the children should be placed along the vertical axis.
  final CrossAxisAlignment crossAxisAlignment;

  /// How much horizontal space the row should occupy.
  final MainAxisSize mainAxisSize;

  /// Scrollbar configuration applied when [scrollable] is `true`.
  final ScrollBarConfiguration? scrollBarConfiguration;

  /// Additional CSS classes applied to the row.
  final String? classes;

  /// The distance (in px) between [children] components.
  final double? spacing;

  /// Reverse the order of children.
  final bool reverse;

  /// When `true`, the row will be scrollable.
  final bool scrollable;

  /// {@macro Row}
  const Row({
    super.key,
    required this.children,
    this.reverse = false,
    this.scrollable = false,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.min,
    this.spacing,
    this.classes,
    this.scrollBarConfiguration,
  });

  @override
  Component build(BuildContext context) {
    final _id = nakiDomId(context, 'row');

    final justify = NakiAlignProps.mapMainAxisAlignment(
      mainAxisAlignment,
    );

    final align = NakiAlignProps.mapCrossAxisAlignment(
      crossAxisAlignment,
    );

    const baseClass = 'naki-row';
    final effectiveClasses = classes.isNotNullAndEmpty
        ? '$baseClass $classes'
        : baseClass;

    final effectiveStyles = {
      'display': 'flex',
      'flex-direction': reverse ? 'row-reverse' : 'row',
      'justify-content': justify,
      'align-items': align,
      'width': ?(mainAxisSize == MainAxisSize.max ? '100%' : null),
      'column-gap': ?spacing?.toPx,
      'overflow-x': ?(scrollable ? 'auto' : null),
    };

    Component child = .element(
      key: key,
      tag: 'naki-row',
      id: _id,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: children,
    );

    if (scrollable) {
      child = ScrollBarWrapper(
        selector: '#$_id',
        configuration: scrollBarConfiguration,
        child: child,
      );
    }

    return FlexScope(
      scrollable: scrollable,
      child: child,
    );
  }
}

/// {@template Image}
/// A component that displays an image.
///
/// ### Example
/// ```dart
/// Image(
///   'https://example.com/image.png',
///   alt: 'Image',
///   size: SizeConstraints(
///     width: Dim.px(100),
///     height: Dim.px(100),
///   ),
///   cache: true,
///   lazyLoad: true,
///   fit: BoxFit.cover,
/// )
/// ```
/// {@endtemplate}
class Image extends StatelessComponent with NakiStatelessMixin {
  /// Image source can be a remote url, base64 encoded string or an asset path.
  final String src;

  /// Semantic description of the image for accessibility.
  ///
  /// When omitted, the image is rendered with an empty `alt` attribute and is
  /// treated as decorative by assistive technologies.
  final String? alt;

  /// Image size.
  final SizeConstraints? size;

  /// When `true` and [src] is a remote URL, the image will be
  /// cached. Future rendering will use the cached source
  /// provided that cache is enabled.
  final bool cache;

  /// How to inscribe the image into the space allocated.
  final BoxFit? fit;

  /// Additional CSS classes applied to the image.
  final String? classes;

  /// Radius of the image corners.
  final BorderRadiusData? radius;

  /// Background color applied to the image container.
  final Color? backgroundColor;

  /// Background gradient applied to the image container.
  ///
  /// ### Example
  /// ```dart
  /// Image(
  ///   'https://example.com/avatar.png',
  ///   gradient: Gradient()..applyLinear(colors: [Colors.purple, Colors.blue]),
  /// )
  /// ```
  final Gradient? gradient;

  /// When `true`, image loading will be deferred until it is scrolled
  /// into view.
  final bool lazyLoad;

  /// Padding applied to the image container when [backgroundColor] or [gradient] is set.
  final EdgeInsets? padding;

  /// {@macro Image}
  const Image(
    this.src, {
    super.key,
    this.lazyLoad = true,
    this.cache = false,
    this.alt,
    this.size,
    this.fit,
    this.classes,
    this.backgroundColor,
    this.gradient,
    this.radius,
    this.padding,
  });

  @override
  FutureOr<VoidCallback?> afterRender(
    BuildContext context,
  ) {
    if (cache) cacheImage(src);
    return null;
  }

  @override
  Component build(BuildContext context) {
    final _id = nakiStableKey('image', src);
    final cachedSource = NakiStorage.get<String>(_id);

    final shouldWrap =
        backgroundColor != null || gradient != null || padding != null;

    const baseClass = 'naki-image';
    final effectiveClasses = classes != null
        ? '$baseClass $classes'
        : baseClass;

    final image = img(
      key: shouldWrap ? null : key,
      src: (cache ? cachedSource : null) ?? src,
      alt: alt ?? '',
      classes: effectiveClasses,
      loading: lazyLoad ? MediaLoading.lazy : MediaLoading.eager,
      styles: Styles(
        raw: {
          'object-fit': ?fit?.name,
          ...?size?.props,
          ...?radius?.props,
        },
      ),
    );

    return shouldWrap
        ? Container(
            key: key,
            child: image,
            decoration: BoxDecoration(
              borderRadius: radius,
              backgroundColor: backgroundColor,
              gradient: gradient,
              padding: padding,
              alignment: Alignment.center,
            ),
            clip: true,
          )
        : image;
  }
}

/// {@template NakiText}
/// A Naki component that is just a run of text with single style.
///
/// ### Example
/// ```dart
/// NakiText(
///   'Hello',
///   style: TextStyle(
///     color: Colors.black,
///     fontSize: Dim.px(16),
///     fontWeight: FontWeight.bold,
///   ),
/// )
/// ```
/// {@endtemplate}
class NakiText extends StatelessComponent with NakiTextScope {
  /// Text to display.
  final String text;

  /// Style applied to the text.
  @override
  final TextStyle? style;

  /// Additional CSS classes applied to the text.
  @override
  final String? classes;

  /// {@macro NakiText}
  const NakiText(
    this.text, {
    super.key,
    this.style,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context);
    final effectiveStyles = defaultStyle.combineWith(style);

    const baseClass = 'naki-text';
    final effectiveClasses = classes.isNotNullAndEmpty
        ? '$baseClass $classes'
        : baseClass;

    return .element(
      key: key,
      tag: 'naki-text',
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles.props),
      children: [.text(text)],
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Text', [Rules.nakiTextRules]);
}

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

  /// Color applied on the button when disabled.
  final Color? disabledColor;

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

  /// Additional CSS classes applied to the button.
  final String? classes;

  /// If `true`, a spinner will be displayed when [onTap] is invoked.
  final bool showLoadingIndicator;

  /// When `true`, a native iOS spinner will be displayed
  /// if [showLoadingIndicator] is enabled.
  final bool ios;

  /// If `true` and the button is inside a [FormBuilder], the form will
  /// be validated before [onTap] is invoked.
  final bool validateForm;

  /// If `true` and the button is inside a [FormBuilder], the form will
  /// be reset.
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
    this.disabledColor,
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
    this.disabledColor,
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
    this.disabledColor,
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
    this.disabledColor,
    this.attributes,
    this.id,
  }) : child = Icon(
         icon,
         color: foregroundColor,
         size: size,
       ),
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
    this.disabledColor,
    this.attributes,
    this.id,
  }) : child = Row(
         mainAxisAlignment: mainAxisAlignment,
         mainAxisSize: mainAxisSize,
         spacing: spacing,
         children: iconPosition == Position.left
             ? [
                 Icon(
                   icon,
                   color: foregroundColor,
                   size: iconSize,
                 ),
                 NakiText(text, style: textStyle),
               ]
             : [
                 NakiText(text, style: textStyle),
                 Icon(
                   icon,
                   color: foregroundColor,
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
    this.disabledColor,
    this.attributes,
    this.id,
  }) : child = NakiText(text, style: style),
       assert(
         !(validateForm && resetForm),
         'validateForm and resetForm cannot both be true',
       );

  @override
  State<Button> createState() => _ButtonState();

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('Button', [
    Rules.nakiButtonRules,
  ]);
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

    final fn = component.onTap;

    // if the button is inside a form, validate or reset it
    final form = FormScope.of(context);
    if (form != null) {
      if (component.validateForm && !form.validate()) return;
      if (component.resetForm && fn == null) form.reset();
    }

    if (fn != null) {
      if (component.showLoadingIndicator) setState(() => _isLoading = true);

      try {
        final value = fn();
        if (value is Future) await value;
      } finally {
        if (component.resetForm) form?.reset();
        if (_isLoading) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Component build(BuildContext context) {
    const String baseClass = 'naki-button';
    final String effectiveClasses = component.classes.isNotNullAndEmpty
        ? '$baseClass ${component.classes}'
        : baseClass;

    final Map<String, String> effectiveStyles = {
      Tokens.current.buttonBackgroundColor.name:
          ?component.backgroundColor?.value,
      Tokens.current.buttonColor.name: ?component.foregroundColor?.value,
      Tokens.current.disabledBgColor.name: ?component.disabledColor?.value,
      Tokens.current.buttonHoverBgColor.name: ?component.hoverColor?.value,
      Tokens.current.buttonHeight.name: ?component.height?.cssText,
      Tokens.current.buttonWidth.name: ?component.width?.cssText,
      ...?component.border?.props,
      ...?component.padding?.pProps,
      ...?component.margin?.mProps,
      ...?component.gradient?.props,
    };

    final ButtonType effectiveType = FormScope.of(context) != null
        ? ButtonType.button
        : component.resetForm
        ? ButtonType.reset
        : component.type;

    final canHover = component.hoverColor != null && !component.disabled;

    return button(
      key: component.key,
      id: component.id,
      classes: effectiveClasses,
      type: effectiveType,
      styles: Styles(raw: effectiveStyles),
      disabled: component.disabled,
      attributes: {'hvr': ?(canHover ? '' : null), ...?component.attributes},
      onClick:
          component.onTap != null ||
              component.validateForm ||
              component.resetForm
          ? _onClick
          : null,
      [
        _isLoading ? Spinner(ios: component.ios) : component.child,
      ],
    );
  }
}

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
    final effectiveClasses = classes.isNotNullAndEmpty
        ? '$baseClass $classes'
        : baseClass;

    final child = SvgIcon(
      icon,
      key: key,
      size: size,
      color: color,
      classes: effectiveClasses,
      attributes: semanticLabel.isNotNullAndEmpty
          ? {'aria-label': semanticLabel!}
          : null,
      onClick: onTap,
    );

    return onTap != null
        ? span(classes: 'naki-control-hitbox', [child])
        : child;
  }

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('Icon', [
    Rules.nakiIconRules,
    Rules.nakiHitboxRules,
  ]);
}

/// {@template Spinner}
/// A component that renders a loading spinner with an optional
/// iOS-style or glassmorphism effect.
///
/// ### Example
/// ```dart
/// Spinner(
///   thickness: Dim.px(4),
///   color: Colors.red,
///   trackColor: Colors.black,
/// )
/// ```
///
/// See also:
/// - [Spinner.ios] constructor for iOS-style spinner.
/// - [Spinner.glass] constructor for glassmorphism-style spinner.
/// {@endtemplate}
class Spinner extends StatelessComponent {
  /// Size (diameter) of the spinner (default: Dim.px(24)).
  final Dim size;

  /// Color of the spinner's track.
  final Color? trackColor;

  /// Width of the spinner's stroke in pixels.
  final double thickness;

  /// Color of the spinner.
  final Color? color;

  /// Color of the spinner's glass surface. When provided,
  /// a glassmorphism effect is applied behind the spinner
  /// using this color.
  ///
  /// NOTE: [ios] must be `false` to use this property.
  final Color? surfaceColor;

  /// Additional CSS classes applied to the spinner.
  final String? classes;

  /// Accessible label announced while the spinner is active.
  final String semanticLabel;

  /// Whether to render an iOS-style spinner.
  ///
  /// NOTE: [surfaceColor] must be `null` to use this property.
  final bool ios;

  /// {@macro Spinner}
  const Spinner({
    super.key,
    this.size = const Dim.px(24),
    this.thickness = 4.0,
    this.ios = false,
    this.color,
    this.trackColor,
    this.surfaceColor,
    this.classes,
    this.semanticLabel = 'Loading',
  });

  /// Creates an iOS-style spinner.
  const Spinner.ios({
    super.key,
    this.size = const Dim.px(24),
    this.thickness = 2.0,
    this.color,
    this.trackColor,
    this.classes,
    this.semanticLabel = 'Loading',
  }) : ios = true,
       surfaceColor = null;

  /// Creates a glassmorphism-style spinner.
  const Spinner.glass({
    super.key,
    required this.surfaceColor,
    this.size = const Dim.px(24),
    this.thickness = 4.0,
    this.color,
    this.trackColor,
    this.classes,
    this.semanticLabel = 'Loading',
  }) : ios = false;

  @override
  Component build(BuildContext context) {
    final iosClass = ios && surfaceColor == null ? ' ios' : '';
    final morphismClass = surfaceColor != null && !ios ? ' morphism' : '';

    final baseClass = 'naki-spinner$iosClass$morphismClass';
    final effectiveClasses = classes.isNotNullAndEmpty
        ? '$baseClass $classes'
        : baseClass;

    final effectiveStyles = {
      Tokens.current.spinnerSize.name: size.cssText,
      Tokens.current.spinnerBorderWidth.name: thickness.toPx,
      Tokens.current.spinnerColor.name: ?color?.value,
      Tokens.current.spinnerBladeColor.name: ?color?.value,
      Tokens.current.spinnerTrackColor.name: ?trackColor?.value,
      Tokens.current.spinnerSurfaceColor.name: ?surfaceColor?.value,
    };

    final spinnerBlades = List.generate(12, (index) {
      return const span(classes: 'spinner-blade', []);
    });

    return .element(
      key: key,
      tag: 'naki-spinner',
      classes: effectiveClasses,
      attributes: {
        'role': 'status',
        'aria-live': 'polite',
        'aria-label': semanticLabel,
      },
      styles: Styles(raw: effectiveStyles),
      children: [
        ...?(iosClass.isNotEmpty ? spinnerBlades : null),
      ],
    );
  }

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once(
    'Spinner',
    Rules.nakiSpinnerRules,
  );
}

/// {@template RichText}
/// A component that renders rich text with styled inline spans.
///
/// ### Example
/// ```dart
/// RichText(
///   text: TextSpan(
///     text: 'Hello ',
///     style: TextStyle(
///       fontWeight: FontWeight.bold,
///     ),
///     children: [
///       TextSpan(
///         text: 'World',
///         style: TextStyle(
///           color: Colors.blue,
///         ),
///         onTap: () => print('Clicked!'),
///       ),
///     ],
///   ),
/// )
/// ```
/// {@endtemplate}
class RichText extends StatelessComponent with NakiTextScope {
  /// The root inline span to render.
  final InlineSpan text;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  @override
  final TextStyle? style;

  @override
  final String? classes;

  /// {@macro RichText}
  const RichText({
    super.key,
    required this.text,
    this.textAlign,
    this.style,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context);
    final effectiveStyles = defaultStyle.combineWith(style).props;

    const baseClass = 'naki-richtext';
    final effectiveClasses = classes.isNotNullAndEmpty
        ? '$baseClass $classes'
        : baseClass;

    final child = text is Component
        ? text as Component
        : const Component.empty();

    return .element(
      key: key,
      tag: 'naki-richtext',
      classes: effectiveClasses,
      styles: Styles(
        raw: {
          ...effectiveStyles,
          'text-align': ?textAlign?.value,
        },
      ),
      children: [child],
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Text', [Rules.nakiTextRules]);
}

/// {@template TextSpan}
/// A component that represents an inline span of text formatted
/// with a single style.
///
/// Spans can be nested by passing [children].
///
/// ### Example
/// ```dart
/// TextSpan(
///   text: 'Click ',
///   children: [
///     TextSpan(
///       text: 'here',
///       style: TextStyle(
///         color: Colors.blue,
///         decoration: TextDecoration.underline,
///       ),
///       recognizer: GestureRecognizer(
///         onLongPress: (e) => print('Clicked!')),
///     ),
///   ],
/// )
/// ```
/// {@endtemplate}
class TextSpan extends StatelessComponent implements InlineSpan {
  /// Content contained in the text span.
  final String? text;

  /// Additional inline spans contained within the text span.
  final List<InlineSpan>? children;

  /// Gesture recognizer for the text span.
  final GestureRecognizer? recognizer;

  /// Additional CSS classes applied to the text span.
  final String? classes;

  /// Style applied to the text span and its children.
  @override
  final TextStyle? style;

  /// Optional screen-reader description for the text span.
  @override
  final String? semanticsLabel;

  /// {@macro TextSpan}
  const TextSpan({
    super.key,
    this.text,
    this.style,
    this.semanticsLabel,
    this.children,
    this.recognizer,
    this.classes,
  });

  @override
  String toPlainText() {
    final buffer = StringBuffer();

    if (text.isNotNullAndEmpty) {
      buffer.write(text!);
    }

    if (children != null) {
      for (final child in children!) {
        buffer.write(child.toPlainText());
      }
    }

    return buffer.toString();
  }

  @override
  bool visitChildren(
    bool Function(InlineSpan span) visitor,
  ) {
    if (!visitor(this)) return false;

    if (children != null) {
      for (final child in children!) {
        if (!child.visitChildren(visitor)) return false;
      }
    }

    return true;
  }

  @override
  Component build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context);

    const baseClass = 'naki-text-span';
    final effectiveClasses = classes.isNotNullAndEmpty
        ? '$baseClass $classes'
        : baseClass;

    final effectiveStyles = {
      'display': 'inline',
      'cursor': ?(recognizer == null ? null : 'pointer'),
      ...defaultStyle.combineWith(style).props,
    };

    // Override display if the computed styles display property is block
    if (effectiveStyles['display'] == 'block') {
      effectiveStyles['display'] = 'inline';
    }

    final List<Component> mergedChildren = [
      // Text content
      if (text.isNotNullAndEmpty) .text(text!),

      // Inline components
      if (children != null && children!.isNotEmpty)
        for (final child in children!)
          if (child is Component) child as Component,
    ];

    return .element(
      key: key,
      tag: 'naki-textspan',
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      attributes: {'aria-label': ?semanticsLabel},
      events: recognizer?.toMap,
      children: mergedChildren,
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Text', [Rules.nakiTextRules]);
}

/// {@template ComponentSpan}
/// A component that represents an inline span of a
/// component that is embedded inline within texts.
///
/// The child component will be rendered using the given style
/// and can be aligned with text using the [baseline] property.
///
/// ### Example
/// ```dart
/// ComponentSpan(
///   child: Button(),
///   baseline: Baseline.middle,
///   style: TextStyle(
///     color: Colors.blue,
///     decoration: TextDecoration.underline,
///   ),
/// )
/// ```
/// {@endtemplate}
class ComponentSpan extends StatelessComponent implements InlineSpan {
  /// The component embedded inline within text.
  final Component child;

  /// Vertical alignment baseline of the embedded
  /// component relative to text (default: [Baseline.baseline]).
  final Baseline baseline;

  /// Additional CSS classes applied to the component span.
  final String? classes;

  /// Style applied to the component span.
  @override
  final TextStyle? style;

  /// Optional screen-reader description for the component span.
  @override
  final String? semanticsLabel;

  /// {@macro ComponentSpan}
  const ComponentSpan({
    super.key,
    required this.child,
    this.baseline = Baseline.baseline,
    this.style,
    this.semanticsLabel,
    this.classes,
  });

  @override
  String toPlainText() => semanticsLabel ?? '';

  @override
  bool visitChildren(
    bool Function(InlineSpan span) visitor,
  ) {
    return visitor(this);
  }

  @override
  Component build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context);
    final mergedStyle = defaultStyle.combineWith(style).props;

    const baseClass = 'naki-component-span';
    final effectiveClasses = classes.isNotNullAndEmpty
        ? '$baseClass $classes'
        : baseClass;

    final effectiveStyles = {
      ...mergedStyle,
      'display': 'inline-block',
      'vertical-align': baseline.value,
    };

    // Override display if the computed styles display property is block
    if (effectiveStyles['display'] == 'block') {
      effectiveStyles['display'] = 'inline-block';
    }

    return .element(
      key: key,
      tag: 'naki-componentspan',
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      attributes: {'aria-label': ?semanticsLabel},
      children: [child],
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Text', [Rules.nakiTextRules]);
}

/// {@template GestureDetector}
/// A component that detects and handles gestures on its child.
///
/// Example:
/// ```dart
/// GestureDetector(
///   gestures: GestureRecognizer(
///     onClick: (event) => print('Tapped!'),
///   ),
///   child: const NakiText('Click me'),
/// )
/// ```
/// {@endtemplate}
class GestureDetector extends StatelessComponent {
  /// Child component that receives the gestures.
  final Component child;

  /// Set of gestures to recognize.
  final Gestures gestures;

  /// Additional CSS classes applied to the gesture detector.
  final String? classes;

  /// Accessible name for an interactive gesture surface.
  final String? semanticLabel;

  /// ARIA role for the gesture surface. Defaults to `button` when clickable.
  final String? semanticRole;

  /// Additional attributes applied to the gesture surface.
  final Map<String, String>? attributes;

  /// {@macro GestureDetector}
  const GestureDetector({
    super.key,
    required this.child,
    required this.gestures,
    this.classes,
    this.semanticLabel,
    this.semanticRole,
    this.attributes,
  });

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-gesture-detector';
    final effectiveClasses = classes.isNotNullAndEmpty
        ? '$baseClass $classes'
        : baseClass;

    final isClickable = gestures.onClick != null;
    final handlers = gestures.toMap;
    final existingKeyDown = handlers['keydown'];

    // enable keyboard clicks for web accessibility
    if (isClickable) {
      handlers['keydown'] = (event) {
        existingKeyDown?.call(event);
        final key = (event as KeyboardEvent).key;

        if (key == 'Enter' || key == ' ') {
          event.preventDefault();
          gestures.onClick!.call(event);
        }
      };
    }

    return .element(
      tag: 'naki-gesturedetector',
      classes: effectiveClasses,
      attributes: {
        if (isClickable) ...{
          'role': semanticRole ?? 'button',
          'tabindex': '0',
        },
        'aria-label': ?semanticLabel,
        ...?attributes,
      },
      events: handlers,
      children: [child],
    );
  }
}

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
    final effectiveClasses = classes.isNotNullAndEmpty
        ? '$baseClass $classes'
        : baseClass;

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
            classes: 'banner-actions',
          ),
      ]),

      // trailing close icon
      if (dismissible)
        Icon(
          MaterialIcons.icon_round_close,
          size: 20,
          color: closeIconColor ?? context.red,
          onTap: onClose,
          semanticLabel: 'Dismiss',
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

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('Banner', [
    Rules.nakiBannerRules,
  ]);
}
